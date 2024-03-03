# CDDataStack

CDDataStack is an automatic Core Data management package, storing data in an internal Core Data database.

1. [CDDataStack](#cddatastack)
2. [Warnings](#warnings)
3. [Requirements](#requirements)
4. [Integration](#integration)
5. [Usage](#usage)
    - [Defining Models](#defining-models)
    - [Nested Models](#nested-models)
    - [Recommended Usage](#recommended-usage)
    - [Supported Types](#supported-types)
6. [Metadata](#metadata)

## CDDataStack

CDDataStack is an automatic persistance manager, built specifically for smaller app using just a single model to persist - for example, a game with a single shared model containing User information, like the users position and inventory.  With just one model that is shared across the app and constantly updated, managing core data can be annoying.  CDDataStack allows you to simply inherit the `CDDataModel` class, and tag any properties that should be automatically saved with `@AutoSave`, and `CDDataStack` will automatically save any changes to the property, and set the properies to the saved version when the model is initialized.
                                                                            
## Warnings

CDDataStack is in development, and currently has no shortage of bugs.  As such, the current version is not fully tested and can cause any variety of crashes and data faults if not used at outlined in the [usage](#usage) section.  Known bugs and warnings are listed below.

1. Using multiple classes inheriting from `CDAutoModel` is not currently supported, this will cause either changes to one or both models to not persist, or the app to crash.
2. Overriding the default `init() {...}` from a `CDAutoModel` class will result in either crashing or changes not persisting.

## Requirements

- iOS 16.4+, macOS 10.13+
- Xcode 15

## Integration

#### Swift Package Manager

No version out yet.  But when it is, you can use SPM as described below.

You can use [The Swift Package Manager](https://swift.org/package-manager) to install `CDDataStack` by adding the proper description to your `Package.swift` file:

```swift
// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "https://github.com/seanericksonpl12/CDDataStack.git", from: "1.0.0"),
    ]
)
```
Then run `swift build` whenever you get prepared.

#### CocoaPods

Use SPM instead

## Usage

### Defining Models

You can define a model to be saved by first inheriting from `CDAutoModel`, then tagging any properties you want to save with `@AutoSave`.  Any properties without `@AutoSave` will be ignored and not persisted.

```swift
import CDDataStack

class MyDataModel: CDAutoModel {
    @AutoSave var savedString: String = ""
    @AutoSave var savedInt: Int = 0
    var unsavedBool: Bool = false
}
```

### Nested Models

Unfortunately, CDDataStack utilizes NSObject property setters to work, so custom objects stored within your `CDAutoModel` must be classes.

You can define and store a class object similarly, but instead have it inherit `NestedModel`.

For nested models, you don't need to tag the model itself with `@AutoSave`, only tag the properties inside the nested model, as shown below.

```swift
import CDDataStack

class MyDataModel: CDAutoModel {
    @AutoSave var savedString: String = ""
    @AutoSave var savedInt: Int = 0
    
    var myObject: CustomObject = CustomObject()
}

class CustomObject: NestedModel {
    @AutoSave var customString: String = ""
    @AutoSave var customBool: Bool = false
}
```

### Recommended Usage

The use case this package was written for and works best for is having a single, shared class that contains the data to be persisted.  An example is a game app, where user information is stored in a single class.  This information is used everywhere throughout the app, but there is only one user so we can build a single `User` class with a static reference to itself.  Utilizing the `CDDataStack` package, we can now freely use and update this shared instance of `User` throughout the app, and all changes will be automatically persisted and applied on the next app launch, when the shared instance of `User` is initialized again.

Using multiple instances of the same `CDAutoModel` is supported, but it's not recommended since all data stored in Core Data is loaded into the class on init. A shared instance that is initialized once is generally a better idea if the information will be used throughout the app, rather than reloading this data from CoreData over and over whenever you want to fetch information.

### Supported Types



## Metadata

Author - Sean Erickson
seanericksonpl12@gmail.com
