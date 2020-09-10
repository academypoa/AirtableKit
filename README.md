<!-- Title -->
# AirtableKit

<!-- Future plataform support -->
<!-- [Supported platform: iOS, macOS, tvOS, watchOS](https://img.shields.io/badge/platform-iOS%2C%20macOS%2C%20tvOS%2C%20watchOS-lightgrey) -->

<!-- Current platform support -->
![Supported platform: iOS](https://img.shields.io/badge/iOS-lightgrey)
<!-- Social Media -->
[![Follow us](https://img.shields.io/twitter/follow/_nicolaspn?style=social)](https://twitter.com/intent/follow?screen_name=_nicolaspn)
[![Follow us](https://img.shields.io/twitter/follow/rafaelruwer?style=social)](https://twitter.com/intent/follow?screen_name=rafaelruwer)

`AirtableKit` is a 100% Swift framework to wrap the REST API provided by [Airtable](http://api.airtable.com/). The implementation fully leverages [Combine](https://developer.apple.com/documentation/combine) to handle asynchronous operations.

## Features
- Standard CRUD operations;
- Operation batching;
- API Error forwarding;

## Instalation

`AirtableKit` can be installed using Swift Package Manager.

To install `AirtableKit` using Swift Package Manager look for http://github.com/appledeveloperacademypucrs/AirtableKit.git in Xcode (*File/Swift Packages/Add Package Dependency...*). See [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) for details.

## Usage

To use AirtableKit, create an `Airtable` with your __API Key__ and __Base ID__:

``` swift

let airtable = Airtable(baseID: apiBaseId, apiKey: apiKey)

```

## Listing records

You can list items in any Table in your base.

``` swift

let publisher = airtable.list(tableName: tableName, 
                              fields: ["name", "age", "image", "updatedTime", "isCool"])
        
```

## Creating records

You can also create new records.

``` swift

// TODO

```

## Updating records

Updating existing records is possible

``` swift

// TODO

```

## Deleting records

Finally, you can also dele an existing record.

``` swift

// TODO

```
