<!-- Title -->
# AirtableKit

<!-- Future plataform support -->
<!-- [Supported platform: iOS, macOS, tvOS, watchOS](https://img.shields.io/badge/platform-iOS%2C%20macOS%2C%20tvOS%2C%20watchOS-lightgrey) -->

<!-- Current platform support -->
![Supported platform: iOS](https://img.shields.io/badge/iOS-lightgrey)
![Language: Swift](https://img.shields.io/badge/swift-orange)


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

To install `AirtableKit` using Swift Package Manager look for http://github.com/appledeveloperacademypucrs/AirtableKit.git in Xcode (*File/Swift Packages/Add Package Dependency...*). 

See [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) for details.

## Usage

To use AirtableKit, create an `Airtable` with your __API Key__ and __Base ID__:

``` swift

let airtable = Airtable(baseID: apiBaseId, apiKey: apiKey)

```

## Listing records

Then, you can list items in any Table in your base.

``` swift

let publisher = airtable.list(tableName: tableName, 
                              fields: ["name", "age", "image", "updatedTime", "isCool"])
        
```

or get an individual record, providing its id.


``` swift

let publisher = airtable.get(tableName: tableName, 
                             recordID: "YOUR_AIRTABLE_RECORD_ID")
        
```

## Creating records

You can also create a new record.

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

or multiple records.

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
let records = fields.map{ Record(fields: fields) }

let publisher = airtable.create(tableName: tableName, records: records)

```

## Updating records

You can also updating an existing record.

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

or multiple records.

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
let records = fields.map{ Record(fields: fields) }

let publisher = airtable.update(tableName: tableName, records: records)

```

## Deleting records

And finally, you can also delete an existing record.

``` swift

let record = Record(fields: [:], id: "YOUR_AIRTABLE_RECORD_ID")

let publisher = airtable.delete(tableName: tableName, record: record)

```

or multiple records.

``` swift

let publisher = airtable.delete(tableName: tableName, recordsIDs: ["YOUR_AIRTABLE_RECORD_ID_1", "YOUR_AIRTABLE_RECORD_ID_2"])

```
