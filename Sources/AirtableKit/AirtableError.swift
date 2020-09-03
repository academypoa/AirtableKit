import Foundation

/// Errors thrown from the Airtable framework.
public enum AirtableError: Error, LocalizedError {
    
    /// Some of the required fields that should be present on the response are missing.
    case missingRequiredFields(String)
    
    /// The resource (table, record, attachment) doesn't exist.
    case notFound
    
    /// The response received is not a valid JSON.
    case invalidResponse(Data)
    
    /// The provided parameters can't be used to perform the requested operation.
    case invalidParameters(operation: String, parameters: [Any])
    
    /// HTTP error. See the associated `HTTPURLResponse` and `Data` payload for more info.
    case http(httpResponse: HTTPURLResponse, data: Data)
    
    /// Network error. See the associated `URLError` for more info.
    case network(URLError)
    
    /// Delete operation did not complete sucessfully for the record id
    case deleteOperationFailed(String)
    
    /// Unknown error.
    case unknown
    
    public var localizedDescription: String {
        switch self {
        case let .missingRequiredFields(fields):
            return "missing required fields: \(fields)"
        case .notFound:
            return "the requested resource could not be found"
        case let .invalidResponse(data):
            return "response is not a valid JSON: \(String(data: data, encoding: .utf8) ?? "<not utf8-encoded>")"
        case let .invalidParameters(operation, parameters):
            return """
            the provided parameters are not valid for the requested operation
            - operation: \(operation)
            - parameters: \(parameters)
            """
        case let .http(httpResponse: response, data: data):
            return """
            request failed with http status code \(response.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))
            - response headers:
                \(response.allHeaderFields)
            - response data:
                \(String(data: data, encoding: .utf8) ?? "<not utf8-encoded>")
            """
        case let .network(urlError):
            return "networking error: \(urlError.localizedDescription)"
        case let .deleteOperationFailed(id):
            return "Delete operation status returned `false` for record with id:\(id)"
        case .unknown:
            return "unknown error"
        }
    }
}
