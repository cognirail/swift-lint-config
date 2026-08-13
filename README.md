# Cognirail Swift Lint Config

Opinionated SwiftLint + SwiftFormat configuration for Swift 6 projects written substantially by coding agents. Swift's compiler, API Design Guidelines, and ecosystem conventions are the baseline; the package adds stricter machine-checkable naming, structure, safety, and escape-hatch guardrails for long-term maintenance.

## Toolchain

| Responsibility | Tool | Minimum supported version |
| --- | --- | --- |
| Code quality and dangerous patterns | SwiftLint | >= 0.65.0 |
| Deterministic formatting | SwiftFormat | >= 0.62.1 |
| Types, exhaustive switches, concurrency | Swift compiler | Swift 6 language mode |

The repository does not vendor tool binaries. `Brewfile` installs current Homebrew formulae on macOS. The default format gate works with Swift Command Line Tools; the optional strict gate checks for a complete Xcode/SourceKit environment.

## Commands

```bash
make install
make lint
make lint-strict
make format
make smoke
```

`make lint` and `make format` are the lightweight daily path: they run the inline-directive guard and SwiftFormat, without requiring the full Xcode app. `make lint-strict` adds SwiftLint's naming, safety, complexity, and structure checks and requires complete Xcode/SourceKit. `make smoke` is the CI-grade strict path.

## Add to a Swift or Xcode project

Copy these single-source-of-truth files into the consumer repository:

```text
.swiftlint.yml
.swiftformat
scripts/check-inline-directives.sh
scripts/lint.sh
scripts/format.sh
Brewfile
```

Install compatible tool versions and use the shared entrypoints:

```bash
brew bundle
./scripts/lint.sh
./scripts/format.sh
```

For build-time diagnostics, optionally add SwiftLint's dedicated binary plugin package at an exact reviewed version and attach it to every target that should be checked:

```swift
.target(
    name: "AppCore",
    plugins: [
        .plugin(
            name: "SwiftLintBuildToolPlugin",
            package: "SwiftLintPlugins"
        ),
    ]
)
```

SwiftFormat remains an explicit command because automatic source rewriting during `swift build` would clear editor undo history and make builds mutate the working tree.

## Add to an Xcode project

1. Run `brew bundle` once for local command-line linting and formatting.
2. Optionally add `https://github.com/SimplyDanny/SwiftLintPlugins` at exactly `0.65.0` under Package Dependencies.
3. If added, attach `SwiftLintBuildToolPlugin` to each target's **Run Build Tool Plug-ins** phase.
4. Put `.swiftlint.yml` and `.swiftformat` at the project root.
5. Run `make lint` / `make format` locally; use `make lint-strict` in CI or on machines with complete Xcode.

CI should not use `-skipPackagePluginValidation` unless the repository explicitly accepts the supply-chain tradeoff.

## Mapping from the TypeScript preset

| TypeScript guardrail | Swift equivalent |
| --- | --- |
| Prettier, 100-column print width, LF | SwiftFormat defaults plus max width 100 and LF |
| `no-explicit-any` and strict type checks | Swift compiler + force unwrap/try/cast bans |
| Promise misuse and exhaustive unions | Swift 6 concurrency checks + compiler exhaustiveness |
| SonarJS complexity rules | SwiftLint complexity/body/file limits |
| `no-console` | No global equivalent: CLI apps legitimately use `print` |
| No `eslint-disable` comments | Repository hard gate forbids SwiftLint/SwiftFormat directives |
| Import/barrel and Nest role naming | Not translated: they are TypeScript/framework conventions, not Swift conventions |

The policy intentionally does **not** port rules one by one. It avoids magic-number bans, global declaration sorting, forced role suffixes, and other rules that fight SwiftUI, protocol extensions, or Apple framework conventions. Swift compiler diagnostics remain authoritative for type safety, exhaustive switches, actor isolation, and concurrency correctness.

Exceptions belong in the root configuration and code review. Source-level `swiftlint:disable`, `swiftlint:enable`, `swiftformat:disable`, and `swiftformat:options` directives are rejected before the linters run.

## AI maintainability policy

The configuration is stricter than a normal formatting preset where a rule can be checked reliably:

- Types use UpperCamelCase; functions, properties, variables, and parameters use lowerCamelCase through SwiftLint's native naming rules.
- Identifiers are normally 3-40 characters. Established short forms such as `id`, loop indices, coordinates, and common prepositions are explicitly allowed.
- Type and generic names have bounded lengths, preventing generated names that encode an entire implementation detail.
- Function, closure, type, and file size limits force generated code into reviewable, meaningfully named units.
- Parameter count, nesting, and cyclomatic-complexity limits discourage orchestration-heavy generated functions.
- Force unwrap, force cast, force try, implicitly unwrapped optionals, and inline lint suppression are hard failures.

Semantic naming cannot be inferred safely from syntax alone. This preset therefore does not globally ban words such as `Manager`, `Helper`, `Data`, or `Info`: Apple APIs and legitimate domain models use some of them. Projects should add narrowly scoped custom rules only after defining their own architectural roles and allowed vocabulary.

## Upgrade policy

Upgrade one tool at a time, update the minimum version in `scripts/doctor.sh`, run `make lint` locally and `make smoke` in CI, then inspect the formatter diff. SwiftLint opt-ins stay explicit; SwiftFormat upgrades require an explicit formatting-diff review because its mature default rule set can evolve.
