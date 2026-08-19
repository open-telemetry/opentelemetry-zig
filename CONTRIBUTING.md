# Contributing 

Welcome to the OpenTelemetry Zig repository!

Before you start, see the OpenTelemetry general
[contributing](https://github.com/open-telemetry/community/blob/main/guides/contributor/README.md)
requirements and recommendations.

## CLA and license

Review the project [license](LICENSE) and sign the
[CNCF CLA](https://identity.linuxfoundation.org/projects/cncf). A signed CLA will be enforced by
an automatic check once you submit a PR, but you can also sign it after opening your PR.

## OpenTelemetry Zig

The version of Zig used for development is declared in [`build.zig.zon`](./build.zig.zon) in the `.minimum_zig_version` field.

## Build Commands

### Building the library

Build the SDK library:

```
zig build
```

This compiles the OpenTelemetry SDK as a static library in `zig-out/lib/`.

### Running tests

Unit tests are executed as part of CI pipeline, you can run them locally while developing:

```
zig build sdk-test
```

#### Test options

The test build supports the following options:

- `-Dtest-verbose=true`: Show verbose test output with timing information (instead of dots)
- `-Dtest-fail-first=true`: Stop on first test failure
- `-Dtest-show-logs=true`: Show captured log output for tests with warnings/errors

To run only specific tests matching a pattern, use build args:

```
zig build sdk-test -- "counter"
```

Example usage:

```
# Run tests with verbose output (shows test names and timing)
zig build sdk-test -Dtest-verbose=true

# Run specific tests with verbose output and stop on first failure
zig build sdk-test -Dtest-verbose=true -Dtest-fail-first=true -- "counter"

# Show captured logs for tests with warnings/errors
zig build sdk-test -Dtest-show-logs=true
```

### Running integration tests

Integration tests verify the SDK behavior against real OpenTelemetry backends.

```shell
# Build and install the integration test binaries to zig-out/bin/integration_tests/
zig build sdk-integration

# Run them against a real OTLP collector (Docker required)
zig build sdk-run-integration

# Filter to a specific test by name
zig build sdk-run-integration -- metrics
```

Integration tests are executed as part of CI on pull requests.

> [!IMPORTANT]
> `sdk-run-integration` requires Docker to be installed and the Docker daemon to be running.
> `sdk-integration` alone does not need Docker, since it only builds and installs the binaries.

### Running examples

The example workflow follows the same two-step layout as integration tests:

```shell
# Build every example (Zig + C) and install to zig-out/bin/<category>/<name>
zig build sdk-examples

# Run the installed binaries
zig build sdk-run-examples
```

Since building always installs to `zig-out/bin/`, any example can also be run directly by hand, e.g. `./zig-out/bin/metrics/histogram`.

#### Examples options

Filter to specific examples (applies to both `sdk-examples` and `sdk-run-examples`):

```shell
# Only examples whose name contains "otlp"
zig build sdk-run-examples -Dexamples-filter=otlp

# Only histogram examples
zig build sdk-run-examples -Dexamples-filter=histogram
```

Examples are organized by signal type and language:
- `opentelemetry-sdk/examples/metrics/` - Metrics API examples
- `opentelemetry-sdk/examples/trace/` - Tracing API examples
- `opentelemetry-sdk/examples/logs/` - Logging API examples
- `opentelemetry-sdk/examples/baggage/`, `opentelemetry-sdk/examples/propagation/` - Context-propagation examples
- `opentelemetry-sdk/examples/c/` - C-API examples linking against the static library

### Running benchmarks

Benchmarks are executed as part of the pipeline on Pull Requests if they contain a label `run::benchmarks`.

They can be executed locally with:

```
zig build sdk-benchmarks -Doptimize=ReleaseFast
```

#### Benchmark options

The benchmark build supports the following options:

- `-Dbenchmark-output=<path>`: Path to write benchmark results to a file
- `-Dbenchmark-debug=true`: Enable debug build mode for benchmarks (useful for profiling)

To run only specific benchmarks matching a pattern, use build args:

```
# Run only counter benchmarks
zig build sdk-benchmarks -Doptimize=ReleaseFast -- "counter"

# Run a specific benchmark and save results
zig build sdk-benchmarks -Doptimize=ReleaseFast -Dbenchmark-output="results.txt" -- "hist.record"

# Run benchmarks in debug mode for profiling
zig build sdk-benchmarks -Dbenchmark-debug=true -- "counter"
```

> [!NOTE]
> Currently there is no good way of comparing benchmark runs across various machines,
> as the results do not include CPU information.
> Benchmarks are still useful for detecting improvements or regressions during local development.

### Generating documentation

Generate API documentation:

```
zig build sdk-docs
```

Documentation will be generated in `zig-out/docs/` and can be viewed by opening `index.html` in a browser.

### Semantic conventions

The `opentelemetry-semconv` module is generated from the OpenTelemetry
semantic conventions specification, so most of its sources must not be edited
by hand. See
[opentelemetry-semconv/README.md](./opentelemetry-semconv/README.md) for what
is generated and how to regenerate it.

```
# Run the semantic conventions tests and examples
zig build semconv-test
zig build semconv-examples

# Generate docs into zig-out/docs/semconv/
zig build semconv-docs
```

## Development Workflow

A typical development workflow:

1. Make your changes
2. Run unit tests: `zig build sdk-test`
3. Run integration tests: `zig build sdk-run-integration` (if applicable)
4. Run relevant examples: `zig build sdk-run-examples -Dexamples-filter=<signal>`
5. Run benchmarks: `zig build sdk-benchmarks -Doptimize=ReleaseFast` (if performance-critical)
6. Commit your changes


