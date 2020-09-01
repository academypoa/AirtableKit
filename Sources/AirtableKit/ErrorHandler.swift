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
        case 404:
            throw AirtableError.notFound
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
        
        return .unknown
    }
}
