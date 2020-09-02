import Combine
import Foundation

/// Client used to manipulate an Airtable base.
///
/// This is the facade of the library, used to create, modify and get records and attachments from an Airtable base.
public final class Airtable {
    
    /// ID of the base manipulated by the client.
    public let baseID: String
    
    /// API key of the user manipulating the base.
    public let apiKey: String
    
    static let airtableURL: URL = URL(string: "https://api.airtable.com/v0")!
    private var baseURL: URL { Self.airtableURL.appendingPathComponent(baseID) }
    
    private let requestEncoder: RequestEncoder = RequestEncoder()
    private let responseDecoder: ResponseDecoder = ResponseDecoder()
    private let errorHander: ErrorHandler = ErrorHandler()
    
    /// Initializes the client to work on a base using the specified API key.
    ///
    /// - Parameters:
    ///   - baseID: The ID of the base manipulated by the client.
    ///   - apiKey: The API key of the user manipulating the base.
    public init(baseID: String, apiKey: String) {
        self.baseID = baseID
        self.apiKey = apiKey
    }
    
    /// Lists all records in a table.
    ///
    /// - Parameters:
    ///   - tableName: Name of the table to list records from.
    ///   - fields: Names of the fields that should be included in the response.
    public func list(tableName: String, fields: [String] = []) -> AnyPublisher<[Record], AirtableError> {
        let queryItems = fields.isEmpty ? nil : fields.map { URLQueryItem(name: "fields[]", value: $0) }
        guard let request = makeRequest(path: tableName, queryItems: queryItems) else {
            let err = AirtableError.invalidParameters(operation: #function, parameters: [tableName, fields])
            return Fail<[Record], AirtableError>(error: err).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap(errorHander.mapResponse(_:))
            .tryMap(responseDecoder.decodeRecords(data:))
            .mapError(errorHander.mapError(_:))
            .eraseToAnyPublisher()
    }
    
    /// Gets a single record in a table.
    ///
    /// - Parameters:
    ///   - tableName: Name of the table where the record is.
    ///   - recordID: The ID of the record to be fetched.
    public func get(tableName: String, recordID: String) -> AnyPublisher<Record, AirtableError> {
        let request = makeRequest(path: "\(tableName)/\(recordID)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap(errorHander.mapResponse(_:))
            .tryMap(responseDecoder.decodeRecord(data:))
            .mapError(errorHander.mapError(_:))
            .eraseToAnyPublisher()
    }
    
    /// Creates a record on a table.
    ///
    /// - Parameters:
    ///   - tableName: Name of the table where the record is.
    ///   - record: The record to be created. Create using `Record.create`.
    public func create(tableName: String, record: Record) -> AnyPublisher<Record, AirtableError> {
        var request = makeRequest(path: tableName)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try requestEncoder.asData(json: requestEncoder.encodeRecord(record, shouldAddID: false))
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            let err = AirtableError.invalidParameters(operation: #function, parameters: [tableName, record])
            return Fail<Record, AirtableError>(error: err).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap(errorHander.mapResponse(_:))
            .tryMap(responseDecoder.decodeRecord(data:))
            .mapError(errorHander.mapError(_:))
            .eraseToAnyPublisher()
    }
    
    /// Updates a record overwriting only the fields specified in `record`.
    ///
    /// - Parameters:
    ///   - tableName: Name of the table where the record is.
    ///   - record: The record to be updated. Only the fields that should be updated need to be present. Create using `Record.update`
    public func patch(tableName: String, record: Record) -> AnyPublisher<Record, AirtableError> {
        guard let recordID = record.id else {
            let error = AirtableError.invalidParameters(operation: "patch",
                                                        parameters: [tableName, record, record.id as Any])
            return Fail<Record, AirtableError>(error: error).eraseToAnyPublisher()
        }
        
        var request = makeRequest(path: "\(tableName)/\(recordID)")
        request.httpMethod = "PATCH"
        
        do {
            request.httpBody = try requestEncoder.asData(json: requestEncoder.encodeRecord(record, shouldAddID: false))
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            let err = AirtableError.invalidParameters(operation: #function, parameters: [tableName, record])
            return Fail<Record, AirtableError>(error: err).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap(errorHander.mapResponse(_:))
            .tryMap(responseDecoder.decodeRecord(data:))
            .mapError(errorHander.mapError(_:))
            .eraseToAnyPublisher()
    }
    
    /// Deletes a record from a table.
    ///
    /// - Parameters:
    ///   - tableName: Name of the table where the record is
    ///   - record: The record to delete.
    /// - Returns: A publisher with either the record which was deleted or an error
    public func delete(tableName: String, record: Record) -> AnyPublisher<Record, AirtableError> {
        guard let id = record.id else {
            let error = AirtableError.deleteOperationFailed("Delete requires that the record object possess an id")
            return Fail<Record, AirtableError>(error: error).eraseToAnyPublisher()
        }
        var request = makeRequest(path: "\(tableName)/\(id)")
        request.httpMethod = "DELETE"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap(errorHander.mapResponse(_:))
            .tryMap(responseDecoder.decodeRecord(data:))
            .mapError(errorHander.mapError(_:))
            .eraseToAnyPublisher()
    }
}

extension Airtable {
    private func makeRequest(path: String) -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func makeRequest(path: String, queryItems: [URLQueryItem]?) -> URLRequest? {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        
        guard let url = components?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}

