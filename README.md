This repository generates and provides Swift types for product event tracking. 

## Code generation 

### Usage 

#### Command-line Tool 

To generate Swift files from `.JSON` files using `swift-product-event-generator`, run the following command: 

```bash
swift run swift-product-event-code-generator --input path/to/your/JSON/defintions/directory --output Sources/ProductEventModels/models
```

This will parse each of the JSON files using the expected [format](https://github.com/guardian/product-event-tracking-swift/blob/main/Sources/swift-product-event-generator/Definitions/ProductEventDefinition.swift), generating a corresponding [Swift file](https://github.com/guardian/product-event-tracking-swift/blob/main/Sources/ProductEventModels/models/ProductEvent.swift) containing type safe methods which hold the correct name string and attribute keys as specified in the JSON definition files. 

## Models

As shown above, if you point the output of the code generation to the `ProductEventModels` target you can then add the models as a swift package dependency. 

```swift
dependencies: [
    .package(url: "https://github.com/guardian/product-event-tracking-swift", from: "1.0.0")
]
```

