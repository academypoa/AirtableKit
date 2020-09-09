# Record

An Airtable record (a line in a table).

``` swift
public struct Record
```

After saved, every record has an ID and a time of creation. These fields are valid only if the record was received from the Airtable API.

## Initializers

### `init(fields:​id:​attachments:​)`

Instantiates a record to be used when interacting with AirtableKit classes.

``` swift
public init(fields:​ [String:​ Any], id:​ String? = nil, attachments:​ [String:​ [Attachment]] = [:​])
```

#### Parameters

  - id:​ - id:​ The ID of the record; this should be `nil` if you're creating a record on a table, and not-`nil` if you're updating a record.
  - fields:​ - fields:​ The fields (columns) of the table this record belongs to. Attachments should be set using the `attachments` parameter.
  - attachments:​ - attachments:​ Fields (columns) that store attachments. Attachments should be set only here or on the `attachments` property.

## Properties

### `id`

ID of the record.

``` swift
var id:​ String?
```

The ID is always present when the record is read from Airtable's API, and should be informed when updating a record.

### `createdTime`

Date and time the record was created.

``` swift
var createdTime:​ Date?
```

This field is set when fetching records from Airtable; if `nil`, the record still isn't saved on Airtable.

### `fields`

Fields (columns) of the record.

``` swift
var fields:​ [String:​ Any]
```

*Falsy* values (`0`, `[]`, `null`) are not present when the record is read from Airtable.

The fields returned are assigned *as-is* to this property (no value is removed).

### `attachments`

Fields (columns) of attachments.

``` swift
var attachments:​ [String:​ [Attachment]]
```

Any field with an array of objects with `id` and `url` keys is treated as an attachment. These fields are still present in the `fields` property.
