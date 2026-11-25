# PVDependencies

Third-party libraries that [Provenance](https://github.com/Provenance-Emu/Provenance), iFly,
iCube and their [shared packages](https://wiki.provenance-emu.com/help/shared-frameworks)
all use, as prebuilt XCFrameworks. An app links one copy of each, and nobody compiles them.

| Module | Upstream | Version |
|---|---|---|
| `ZIPFoundation` | [weichsel/ZIPFoundation](https://github.com/weichsel/ZIPFoundation) | 0.9.20 |
| `SQLite` | [stephencelis/SQLite.swift](https://github.com/stephencelis/SQLite.swift) | 0.16.0 |

```swift
dependencies: [
    .package(url: "https://github.com/Provenance-Emu/PVDependencies.git", from: "1.0.0")
],
targets: [
    .target(name: "MyTarget", dependencies: [
        .product(name: "ZIPFoundation", package: "PVDependencies"),
        .product(name: "SQLite", package: "PVDependencies")
    ])
]
```

Source code does not change: `import ZIPFoundation` and `import SQLite` as before.

## Rules

- **One source per library.** A package graph cannot hold this package's `ZIPFoundation`
  and upstream's at once (two modules of one name). Every package and app in the graph
  moves here together.
- **Depend on a version tag.** On `main` the package has no products; the release
  workflow writes the checksums into the tagged commit only.
- Frameworks are dynamic, built with library evolution and Xcode 26.3, for iOS, tvOS,
  watchOS, visionOS (devices and simulators), macOS and Mac Catalyst.

## Changing a library's version

Edit `libraries.txt`, then run **Release XCFrameworks** from the Actions tab with the next
version of this package. A library added here must compile with library evolution; one
that does not (Lighter) stays a private dependency of the package that needs it.

Each library keeps its own license; see the upstream repositories.
