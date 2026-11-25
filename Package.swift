// swift-tools-version:5.9
import PackageDescription

// Third-party libraries that Provenance, iFly, iCube and the shared packages all use,
// as prebuilt XCFrameworks: one copy in the app, and nobody compiles them.
// libraries.txt pins what each release is built from.
//
// Depend on a version tag. The release workflow fills this in on the tagged commit only,
// so on `main` the package has no products.
let binaryRelease: (version: String, checksums: [String: String])? = ("1.0.0", ["SQLite": "341c62016621ad56443be795faaabe5f5e587a913675bfb48a662291f3ffae73", "ZIPFoundation": "64a7b048aa2f8471e9f60b78275be5004e248b14836b1e5ca35804c11fc0db28"])

let modules = (binaryRelease?.checksums ?? [:]).sorted { $0.key < $1.key }

let package = Package(
    name: "PVDependencies",
    products: modules.map { .library(name: $0.key, targets: [$0.key]) },
    targets: modules.map { module, checksum in
        .binaryTarget(
            name: module,
            url: "https://github.com/Provenance-Emu/PVDependencies/releases/download/\(binaryRelease!.version)/\(module).xcframework.zip",
            checksum: checksum
        )
    }
)
