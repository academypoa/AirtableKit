import Foundation

/// Handles error conditions when dealing with Airtable's API.
final class ErrorHandler {
    
    /// Combine-friendly function to handle HTTP errors when a request succeeds (no `URLError`).
    ///
    /// - Parameter response: The output of `URLSession.DataTaskPublisher`.
    /// - Throws: `AirtableError`.
    func mapResponse(_ response: (data: Data, response: URLResponse)) throws -> Data {
        guard let httpResponse = response.response as? HTTPURLResponse else {
            return response.data
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return response.data
        case 400:
            throw AirtableError.badRequest
        case 401:
            throw AirtableError.unauthorized
        case 402:
            throw AirtableError.paymentRequired
        case 403:
            throw AirtableError.forbidden
        case 404:
            throw AirtableError.notFound
        case 413:
            throw AirtableError.requestEntityTooLarge
        case 422:
            throw AirtableError.unprocessableEntity
        default:
            throw AirtableError.http(httpResponse: httpResponse, data: response.data)
        }
    }
    
    /// Maps `Error` objects to `AirtableError`.
    ///
    /// Adds special treatment for `URLError`s.
    func mapError(_ error: Error) -> AirtableError {
        // if it's already an AirtableError, just return
        if let airtableError = error as? AirtableError {
            return airtableError
        }
        
        if let urlError = error as? URLError {
            return .network(urlError)
        }
        
        return .unknown(error)
    }
}
