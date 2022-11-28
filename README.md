<!-- Title -->
# AirtableKit

<!-- Future plataform support -->
<!-- [Supported platform: iOS, macOS, tvOS, watchOS](https://img.shields.io/badge/platform-iOS%2C%20macOS%2C%20tvOS%2C%20watchOS-lightgrey) -->

<!-- Current platform support -->
![Supported platforms: iOS & macOS](https://img.shields.io/badge/platform-ios%20%7C%20macos-lightgrey)
![Language: Swift](https://img.shields.io/badge/swift-orange)
![MIT License](https://img.shields.io/badge/license-MIT-brightgreen)


<!-- Social Media -->
[![Follow us](https://img.shields.io/twitter/follow/_nicolaspn?style=social)](https://twitter.com/intent/follow?screen_name=_nicolaspn)
[![Follow us](https://img.shields.io/twitter/follow/rafaelruwer?style=social)](https://twitter.com/intent/follow?screen_name=rafaelruwer)

`AirtableKit` is a 100% Swift framework to wrap the REST API provided by [Airtable](http://api.airtable.com/). The implementation fully leverages [Combine](https://developer.apple.com/documentation/combine) to handle asynchronous operations.

## Features

- Standard CRUD operations;
- Operation batching;
- API Error forwarding.

## Instalation

`AirtableKit` only supports Swift Package Manager at the moment.

```swift
.package(url: "http://github.com/academypoa/AirtableKit.git", .upToNextMajor(from: "1.0.0"))
```

To install `AirtableKit` using Swift Package Manager look for http://github.com/academypoa/AirtableKit.git in Xcode (*File/Swift Packages/Add Package Dependency...*). 

See [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) for details.

## Usage

To use AirtableKit, create an `Airtable` with your __API Key__ and __Base ID__:

``` swift

let airtable = Airtable(baseID: apiBaseId, apiKey: apiKey)

```

### Listing records

Then, you can list items in any table in your base:

``` swift

let publisher = airtable.list(tableName: tableName)

// to get only some fields
let publisher = airtable.list(tableName: tableName,
                              fields: ["name", "age", "isCool"])
        
```

or get an individual record, providing its ID:


``` swift

let publisher = airtable.get(tableName: tableName, 
                             recordID: "YOUR_AIRTABLE_RECORD_ID")
        
```

### Creating records

You can also create a new record:

``` swift

let fields: [String: Any] = [
  "name" : "Nicolas",
  "isCool" : true
  "age" : 25,
  "updatedTime" : Date()
]

let record = Record(fields: fields)

let publisher = airtable.create(tableName: tableName, record: record)

```

or multiple records:

``` swift

let fields: [[String: Any]] = [
  [
    "name" : "Nicolas",
    "isCool" : true
    "age" : 25,
    "updatedTime" : Date()
  ],
  [
    "name" : "Rafael",
    "isCool" : true
    "age" : 22,
    "updatedTime" : Date()
  ]
]

let records = fields.map { Record(fields: $0) }

let publisher = airtable.create(tableName: tableName, records: records)

```

### Updating records

You can also update an existing record:

``` swift
let fields: [String: Any] = [
  "name" : "Nicolas",
  "isCool" : true
  "age" : 25,
  "updatedTime" : Date()
]

let record = Record(fields: fields, id: "YOUR_AIRTABLE_RECORD_ID")

let publisher = airtable.update(tableName: tableName, record: record)

```

or multiple records:

``` swift

let records = [
  Record(fields: [
    "name" : "Nicolas",
    "isCool" : true
    "age" : 25,
    "updatedTime" : Date()
  ], id: "YOUR_AIRTABLE_RECORD_ID_1"),
  
  Record(fields: [
    "name" : "Rafael",
    "isCool" : true
    "age" : 22,
    "updatedTime" : Date()
  ], id: "YOUR_AIRTABLE_RECORD_ID_2")
]
  
let publisher = airtable.update(tableName: tableName, records: records)

```

### Deleting records

And finally, you can also delete an existing record:

``` swift

let publisher = airtable.delete(tableName: tableName, recordID: "YOUR_AIRTABLE_RECORD_ID")

```

or multiple records:

``` swift

let publisher = airtable.delete(tableName: tableName, recordsIDs: ["YOUR_AIRTABLE_RECORD_ID_1", "YOUR_AIRTABLE_RECORD_ID_2"])

```

## Documentation

Full documentation of the types and methods is [available on the wiki pages](https://github.com/academypoa/AirtableKit/wiki).

## License

MIT License.
