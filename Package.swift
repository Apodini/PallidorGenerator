// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PallidorGenerator",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "PallidorGenerator",
            targets: ["PallidorGenerator"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/mattpolzin/OpenAPIKit.git", from: "2.0.0"),
        .package(url: "https://github.com/kylef/PathKit.git", .exact("0.9.2")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "PallidorGenerator",
            dependencies: [
                .product(name: "OpenAPIKit", package: "OpenAPIKit"),
                .product(name: "PathKit", package: "PathKit"),
                .product(name: "Yams", package: "Yams")
            ],
            resources: [
                .process("NetworkingTemplates/HTTPAuthorizationModel.md"),
                .process("NetworkingTemplates/NetworkManagerModel.md"),
                .process("MetaModels/TestFileModel.md"),
                .process("MetaModels/PackageModel.md"),
                .process("MetaModels/TestManifestModel.md"),
                .process("MetaModels/LinuxMainModel.md")
            ]),
        .testTarget(
            name: "PallidorGeneratorTests",
            dependencies: ["PallidorGenerator", "OpenAPIKit"],
            resources: [
                .process("Resources/petstore.md"),
                .process("Resources/petstore_httpMethodChanged.md"),
                .process("Resources/petstore_minMax.md"),
                .process("Resources/lufthansa.md"),
                .process("Resources/wines.md"),
                .process("Resources/wines_any.md"),
                .process("Resources/Results/Pet.md"),
                .process("Resources/Results/MessageLevel.md"),
                .process("Resources/Results/PaymentInstallmentSchedule.md"),
                .process("Resources/Results/PaymentInstallmentSchedule_Any.md"),
                .process("Resources/Results/PeriodOfOperation.md"),
                .process("Resources/Results/FlightAggregate.md"),
                .process("Resources/Results/LH_GetPassengerFlights.md"),
                .process("Resources/Results/Pet_addPet.md"),
                .process("Resources/Results/Pet_updatePetWithForm.md"),
                .process("Resources/Results/Pet_Endpoint.md"),
                .process("Resources/Results/Pet_updatePetChangedHTTPMethod.md"),
                .process("Resources/Results/Pet_getPetByIdMinMax.md")
            ])
    ]
)
