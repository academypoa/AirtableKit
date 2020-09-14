import Foundation

/// Errors thrown from the Airtable framework.
public enum AirtableError: Error, LocalizedError, Equatable {
    
    // MARK: - Framework errors
    // User error or the Airtable API changed
    
    /// Some of the required fields that should be present on the response are missing.
    case missingRequiredFields(String)
    
    /// The provided parameters can't be used to perform the requested operation.
    case invalidParameters(operation: String, parameters: [Any])
    
    // MARK: - API errors
    // Errors returned by Airtable's API
    
    /// Invalid request (not a valid JSON payload).
    ///
    /// - Note: This shouldn't happen, only if the Foundation JSON encoding (or Airtable API) breaks.
    case badRequest
    
    /// Trying to access a protected resource with an invalid API key (or without an API key).
    case unauthorized
    
    /// Quota exceeded for the account related to the API key.
    case paymentRequired
    
    /// Your API key doesn't have access to the requested resource or to perform the requested action.
    case forbidden
    
    /// The resource (table, record, attachment) doesn't exist.
    case notFound
    
    /// The payload sent was bigger than what the Airtable API supports.
    case requestEntityTooLarge
    
    /// The data sent is invalid (e.g. fails validations present on the base).
    ///
    /// You shouldn't retry the request without modifications to the payload.
    case unprocessableEntity
    
    /// Another HTTP error. See the associated `HTTPURLResponse` and `Data` payload for more info.
    case http(httpResponse: HTTPURLResponse, data: Data)
    
    // MARK: - Server errors
    // The Airtable API changed, or we got an invalid/unexpected response
    
    /// The response received is not a valid JSON.
    case invalidResponse(Data)
    
    // MARK: - Action failed
    // Errors extracted form the API's response payload (HTTP code isn't an error in these cases)
    
    /// Delete operation did not complete sucessfully for the record id
    case deleteOperationFailed(String)
    
    // MARK: - Other errors
    
    /// Network error. See the associated `URLError` for more info.
    case network(URLError)
    
    /// Unknown error.
    case unknown(Error?)
    
    public var localizedDescription: String {
        switch self {
        case let .missingRequiredFields(fields):
            return "Missing required fields: \(fields)."
        case let .invalidParameters(operation, parameters):
            return """
            The provided parameters are not valid for the requested operation:
            - operation: \(operation)
            - parameters: \(parameters)
            """
            
        case .badRequest:
            return "Invalid request encoding (this shouldn't happen; open an issue for further investigation)."
        case .unauthorized:
            return "Use a valid API key and try to access the resource again."
        case .paymentRequired:
            return "Your quota for this type of request exceeded; try upgrading your Airtable plan."
        case .forbidden:
            return "You don't have access to the requested resource or action."
        case .notFound:
            return "The requested resource could not be found."
        case .requestEntityTooLarge:
            return "Payload bigger than what the Airtable API supports."
        case .unprocessableEntity:
            return "The payload sent fails some base validations; modify the payload to conform the the validations performed and try again."
        case let .http(httpResponse: response, data: data):
            return """
            Request failed with HTTP status code \(response.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))
            - response headers:
                \(response.allHeaderFields)
            - response data:
                \(String(data: data, encoding: .utf8) ?? "<invalid encoding>")
            """
            
        case let .invalidResponse(data):
            return "Response is not a valid JSON: \(String(data: data, encoding: .utf8) ?? "<invalid encoding>")"
            
        case let .deleteOperationFailed(id):
            return "Delete operation status returned `false` for record with id: \(id)."
            
        case let .network(urlError):
            return "Networking error: \(urlError.localizedDescription)."
        case let .unknown(underlyingError):
            if let error = underlyingError {
                return "Unknown error: \(error.localizedDescription)."
            } else {
                return "Unknown error."
            }
        }
    }
    
    public static func == (lhs: AirtableError, rhs: AirtableError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}
