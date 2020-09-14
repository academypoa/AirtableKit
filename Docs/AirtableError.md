# AirtableError

Errors thrown from the Airtable framework.

``` swift
public enum AirtableError
```

## Inheritance

`Error`, `LocalizedError`

## Enumeration Cases

### `missingRequiredFields`

Some of the required fields that should be present on the response are missing.

``` swift
case missingRequiredFields(:​ String)
```

### `notFound`

The resource (table, record, attachment) doesn't exist.

``` swift
case notFound
```

### `invalidResponse`

The response received is not a valid JSON.

``` swift
case invalidResponse(:​ Data)
```

### `invalidParameters`

The provided parameters can't be used to perform the requested operation.

``` swift
case invalidParameters(operation:​ String, parameters:​ [Any])
```

### `http`

HTTP error. See the associated `HTTPURLResponse` and `Data` payload for more info.

``` swift
case http(httpResponse:​ HTTPURLResponse, data:​ Data)
```

### `network`

Network error. See the associated `URLError` for more info.

``` swift
case network(:​ URLError)
```

### `deleteOperationFailed`

Delete operation did not complete sucessfully for the record id

``` swift
case deleteOperationFailed(:​ String)
```

### `unknown`

Unknown error.

``` swift
case unknown
```

## Properties

### `localizedDescription`

``` swift
var localizedDescription:​ String
```
