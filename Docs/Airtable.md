# Airtable

Client used to manipulate an Airtable base.

``` swift
public final class Airtable
```

This is the facade of the library, used to create, modify and get records and attachments from an Airtable base.

## Initializers

### `init(baseID:​apiKey:​)`

Initializes the client to work on a base using the specified API key.

``` swift
public init(baseID:​ String, apiKey:​ String)
```

#### Parameters

  - baseID:​ - baseID:​ The ID of the base manipulated by the client.
  - apiKey:​ - apiKey:​ The API key of the user manipulating the base.

## Properties

### `baseID`

ID of the base manipulated by the client.

``` swift
let baseID:​ String
```

### `apiKey`

API key of the user manipulating the base.

``` swift
let apiKey:​ String
```

## Methods

### `list(tableName:​fields:​)`

Lists all records in a table.

``` swift
public func list(tableName:​ String, fields:​ [String] = []) -> AnyPublisher<[Record], AirtableError>
```

#### Parameters

  - tableName:​ - tableName:​ Name of the table to list records from.
  - fields:​ - fields:​ Names of the fields that should be included in the response.

### `get(tableName:​recordID:​)`

Gets a single record in a table.

``` swift
public func get(tableName:​ String, recordID:​ String) -> AnyPublisher<Record, AirtableError>
```

#### Parameters

  - tableName:​ - tableName:​ Name of the table where the record is.
  - recordID:​ - recordID:​ The ID of the record to be fetched.

### `create(tableName:​record:​)`

Creates a record on a table.

``` swift
public func create(tableName:​ String, record:​ Record) -> AnyPublisher<Record, AirtableError>
```

#### Parameters

  - tableName:​ - tableName:​ Name of the table where the record is.
  - record:​ - record:​ The record to be created. Create using `Record.create`.

### `update(tableName:​record:​replacesEntireRecord:​)`

Updates a record overwriting only the fields specified in `record`.

``` swift
public func update(tableName:​ String, record:​ Record, replacesEntireRecord:​ Bool = false) -> AnyPublisher<Record, AirtableError>
```

#### Parameters

  - tableName:​ - tableName:​ Name of the table where the record is.
  - record:​ - record:​ The record to be updated. Only the fields that should be updated need to be present. Create using `Record.update`
  - replacesEntireRecord:​ - replacesEntireRecord:​ Indicates whether the operation should replace the entire record or just updates the appropriate fields

### `delete(tableName:​record:​)`

Deletes a record from a table.

``` swift
public func delete(tableName:​ String, record:​ Record) -> AnyPublisher<Record, AirtableError>
```

#### Parameters

  - tableName:​ - tableName:​ Name of the table where the record is
  - record:​ - record:​ The record to delete.

#### Returns

A publisher with either the record which was deleted or an error
