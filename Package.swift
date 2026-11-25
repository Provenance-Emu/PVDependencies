// swift-tools-version:5.9
import PackageDescription

// Third-party libraries that Provenance, iFly, iCube and the shared packages all use,
// as prebuilt XCFrameworks: one copy in the app, and nobody compiles them.
// libraries.txt pins what each release is built from.
//
// Depend on a version tag. The release workflow fills this in on the tagged commit only,
// so on `main` the package has no products.
let binaryRelease: (version: String, checksums: [String: String])? = nil

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
