# Logs emit flow

This document traces what happens from `Logger.emit` through to wire transmission.
Items marked **(spec)** are mandated by the [OTel Logs SDK spec](https://opentelemetry.io/docs/specs/otel/logs/sdk/);
unmarked items are implementation choices.

## Overview

```
Logger.emit(severity, body, options)
  └─ ReadWriteLogRecord (stack, borrowed data)          ← one, shared by all processors  [impl]
       ├─ Processor[0].onEmit(rw_record)                ← mutate, return                 [spec]
       ├─ Processor[1].onEmit(rw_record)                ← sees Processor[0]'s mutations  [spec]
       └─ Processor[N].onEmit(rw_record)                ← exporting processor
            ├─ asReadable() or toReadable(arena)        ← view or owned copy             [impl]
            └─ exporter.exportLogs(readable)            ← exporter receives ReadableLogRecord [spec]
  └─ (ReadWriteLogRecord freed when emit returns)       [impl]
```

## Step-by-step

### 1. `Logger.emit` — stack allocation, borrowed data *(impl)*

`emit` stack-allocates a `ReadWriteLogRecord` and stores caller-provided slices directly as
pointers (no copy):

- `log_record.body = body` — points into the caller's string
- `log_record.severity_text = options.severity_text` — same
- `options.attributes` are bulk-copied into `log_record.attributes`
  (`ArrayListUnmanaged(Attribute)`) via `appendSlice`, which copies the `Attribute` structs
  (key slice header + value union) but does **not** dupe the pointed-to bytes

At this point all string data is still owned by the caller.

### 2. `LogRecordProcessor.onEmit` — pipeline *(spec)*

Processors are a chain: each receives the same `*ReadWriteLogRecord` in registration order
and may mutate it — the spec mandates that *"logRecord mutations MUST be visible in next
registered processors"* and that `OnEmit` *"is called synchronously on the thread that
emitted the LogRecord"*. The last processor in the chain is typically an exporting processor
(`SimpleLogRecordProcessor`, `BatchingLogRecordProcessor`), which converts to a
`ReadableLogRecord` and forwards it to its exporter. Earlier processors just mutate and return.

### 3. `ReadWriteLogRecord` → `ReadableLogRecord` — two paths *(impl)*

`ReadableLogRecord` is a plain non-owning view struct — it carries no arena and has no
`deinit`. Ownership of the underlying data depends on which conversion path was used:

#### `asReadable()` — zero-allocation borrow

Returns a `ReadableLogRecord` whose string fields point directly into the
`ReadWriteLogRecord` (and thus into the caller's data). No allocation occurs.
Valid only for the duration of `onEmit` — i.e. while the `ReadWriteLogRecord` is still
alive on the stack.

#### `toReadable(allocator)` — deep copy

Deep-copies all string data into the provided allocator:

| Field                                | Handling                                                           |
|--------------------------------------|--------------------------------------------------------------------|
| `body`                               | `allocator.dupe(u8, b)`                                            |
| `severity_text`                      | `allocator.dupe(u8, text)`                                         |
| `attributes` (string values)         | `allocator.dupe(u8, s)` per string value and key                   |
| `attributes` (non-string values)     | copied by value (no heap)                                          |
| `trace_id`, `span_id`, `trace_flags` | copied by value (`[16]u8` / `[8]u8` arrays, `u8`)                  |
| `resource`                           | shallow pointer copy (owned by the provider, outlives all records) |
| `scope`                              | copied by value                                                    |

The caller's strings only need to remain valid for the duration of this call.

### 4a. `SimpleLogRecordProcessor` — synchronous export *(spec names this processor)*

Uses `asReadable()` — zero allocations. The borrowed view is valid for the entire
synchronous `exportLogs` call since the `ReadWriteLogRecord` is still alive on the emit
stack:

```zig
var readable = [1]ReadableLogRecord{log_record.asReadable()};
exporter.exportLogs(&readable);
// no deinit — ReadableLogRecord is a non-owning view
```

The exporter must complete synchronously and must not retain pointers past the call.

### 4b. `BatchingLogRecordProcessor` — deferred export *(spec names this processor)*

The processor owns two `std.heap.ArenaAllocator`s and an index to the active one. In `onEmit`,
`toReadable` is called with the active arena's allocator to deep-copy the record while the
`ReadWriteLogRecord` is still valid. The resulting `ReadableLogRecord` (whose strings point into
the arena) is pushed onto the internal `LogRecordQueue`:

```zig
const readable = try log_record.toReadable(self.arenas[self.active_arena].allocator());
self.queue.push(readable);
```

`exportQueued` exports every record queued when it is called, in batches of at most
`max_export_batch_size`. First it makes the other arena the active one, so records emitted
during the export are copied there and are left for the next export. Once all the records that
were queued have been exported, their arena is reset — freeing all their data at once while
retaining the backing pages for reuse:

```zig
const exported_arena = &self.arenas[self.active_arena];
self.active_arena +%= 1;
// ... pop and export the records queued so far ...
_ = exported_arena.reset(.retain_capacity);
```

Resetting after every export, rather than when the queue is empty, keeps memory bounded under
sustained load, when the queue may never be empty.

### 5. `OTLPExporter.exportLogs` — conversion to protobuf

`logsToOTLPRequest` walks the `ReadableLogRecord` slice and allocates protobuf structs:

- `body` → `pbcommon.AnyValue { .string_value = body }` (string slice reused, not duped)
- `attributes` / `resource` → `pbcommon.KeyValue` list (string slices reused)
- `trace_id` / `span_id` → copied into `[]const u8` fields via `allocator.dupe`

The OTLP request owns the `ArrayList` allocations. `otlp.Export` serialises to bytes and
sends. `cleanupRequest` frees the request's heap allocations.

## Lifetime summary

| Data                                             | Must stay valid until                               |
|--------------------------------------------------|-----------------------------------------------------|
| `body` passed to `emit`                          | `emit` returns                                      |
| `options.severity_text`                          | `emit` returns                                      |
| `options.attributes` slice and its string values | `emit` returns                                      |
| `options.span_context`                           | `emit` returns (copied by value)                    |
| `ReadableLogRecord` strings (Simple)             | `exportLogs` returns — borrowed from the emit stack |
| `ReadableLogRecord` strings (Batching)           | its export completes (its arena is then reset)      |
| OTLP protobuf request                            | `cleanupRequest`                                    |

## Known shallow copies

- **All string data** with `asReadable()` (Simple processor): every field is borrowed from
  the caller. Must remain valid until `emit` returns.
- **`resource`** pointer: the provider owns the resource slice and it outlives all records.
- **`scope`** strings: `InstrumentationScope` fields are string literals; copied by value.
