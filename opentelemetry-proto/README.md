## OpenTelemetry Protobuf Zig

[OpenTelemetry Protobuf definitions](https://github.com/open-telemetry/opentelemetry-proto)
packaged for Zig.

The generated Zig bindings under `src/` are committed and exposed as the
`opentelemetry-proto` module of the `opentelemetry-zig` package, wired into the
repo build by `build/proto/build.zig` (steps: `proto-test`, `proto-update-tag`,
`proto-generate`).

### Import the package

Fetch the `opentelemetry-zig` repository as a dependency:

```bash
zig fetch --save "git+https://github.com/open-telemetry/opentelemetry-zig"
```

This adds an `opentelemetry` entry to your `build.zig.zon`. Wire the
`opentelemetry-proto` module into your artifact in `build.zig`:

```zig
const otel = b.dependency("opentelemetry", .{});
exe.root_module.addImport("opentelemetry-proto", otel.module("opentelemetry-proto"));
```

Then import the generated types in your code:

```zig
const proto = @import("opentelemetry-proto");
const trace = proto.trace_v1;
```

### Regenerating the bindings

The upstream `.proto` definitions are a lazy dependency (`opentelemetry_proto`
in `build.zig.zon`), pinned to a release of the official
[open-telemetry/opentelemetry-proto](https://github.com/open-telemetry/opentelemetry-proto)
repository. Being lazy, it is only fetched when regenerating, never during a
plain build or by consumers of the package.

To regenerate the bindings against a newer OpenTelemetry proto release (run from
the repo root; requires `protoc`):

```bash
# Re-pin build.zig.zon to a tag (or omit -Dtag for the tracked branch, main).
zig build proto-update-tag -Dtag=vX.Y.Z
# Fetch the pinned sources (on demand) and regenerate src/*.pb.zig.
zig build proto-generate
```

Commit both the `build.zig.zon` bump and the regenerated `src/`.

### Dependencies

The [`zig-protobuf`](https://github.com/Arwalk/zig-protobuf/) library from @Arwalk.
