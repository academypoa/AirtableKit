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
    
    private static let batchLimit: Int = 10
    private static let airtableURL: URL = URL(string: "https://api.airtable.com/v0")!
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
    
    // MARK: - Recover records from a table
    
    /// Lists all records in a table.
    ///
    /// - Parameters:
    ///   - tableName: Name of the table to list records from.
    ///   - fields: Names of the fields that should be included in the response.
    public func list(tableName: String, fields: [String] = []) -> AnyPublisher<[Record], AirtableError> {
        let queryItems = fields.isEmpty ? nil : fields.map { URLQueryItem(name: "fields[]", value: $0) }
        let request = buildRequest(method: "GET", path: tableName, queryItems: queryItems)
        
        return performRequest(request, decoder: responseDecoder.decodeRecords(data:))
    }
    
    /// Gets a single record in a table.
    ///
    /// - Parameters:
    ///   - tableName: Name of the table where the record is.
    ///   - recordID: The ID of the record to be fetched.
    public func get(tableName: String, recordID: String) -> AnyPublisher<Record, AirtableError> {
        let request = buildRequest(method: "GET", path: "\(tableName)/\(recordID)")
        return performRequest(request, decoder: responseDecoder.decodeRecord(data:))
    }
    
    // MARK: - Add records to a table
    
    /// Creates a record on a table.
    ///
    /// - Parameters:
    ///   - tableName: Name of the table where the record is.
    ///   - record: The record to be created. The record should have `id == nil`.
    public func create(tableName: String, record: Record) -> AnyPublisher<Record, AirtableError> {
        let request = buildRequest(
            method: "POST",
            path: tableName,
            payload: requestEncoder.encodeRecord(record, shouldAddID: false)
        )
        
        return performRequest(request, decoder: responseDecoder.decodeRecord(data:))
    }
    
    /// Creates multiple records on a table.
    ///
    /// - Parameters:
    ///   - tableName: Name  of the table where the record is.
    ///   - records: The records to be created. All records should have `id == nil`.
    public func create(tableName: String, records: [Record]) -> AnyPublisher<[Record], AirtableError> {
        let batches: [URLRequest?] = records.chunked(by: Self.batchLimit)
            .map { requestEncoder.encodeRecords($0, shouldAddID: false) }
            .map { buildRequest(method: "POST", path: tableName, payload: $0) }
        
        return Publishers.Sequence(sequence: batches)
            .flatMap { request in
                self.performRequest(request, decoder: self.responseDecoder.decodeRecords(data:))
            }
            .reduce([Record](), +)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Update records on a table
    
    /// Updates a record.
    ///
    /// If `replacesEntireRecord == false` (the default), only the fields specified by the record are overwritten (like a `PATCH`); else, all fields are
    /// overwritten and fields not present on the record are emptied on Airtable (like a `PUT`).
    ///
    /// - Parameters:
    ///   - tableName: Name of the table where the record is.
    ///   - record: The record to be updated. The `id` property **must not** be `nil`.
    ///   - replacesEntireRecord: Indicates whether the operation should replace the entire record or just updates the appropriate fields
    public func update(tableName: String, record: Record, replacesEntireRecord: Bool = false) -> AnyPublisher<Record, AirtableError> {
        guard let recordID = record.id else {
            let error = AirtableError.invalidParameters(operation: #function, parameters: [tableName, record])
            return Fail<Record, AirtableError>(error: error).eraseToAnyPublisher()
        }
        
        let request = buildRequest(
            method: replacesEntireRecord ? "PUT" : "PATCH",
            path: "\(tableName)/\(recordID)",
            payload: requestEncoder.encodeRecord(record, shouldAddID: false)
        )
        
        return performRequest(request, decoder: responseDecoder.decodeRecord(data:))
    }
    
    /// Updates multiple records.
    ///
    /// If `replacesEntireRecord == false` (the default), only the fields specified by each record is overwritten (like a `PATCH`); else, all fields are
    /// overwritten and fields not present on each record is emptied on Airtable (like a `PUT`).
    ///
    /// - Parameters:
    ///   - tableName: Name of the table where the record is.
    ///   - records: The records to be updated.
    ///   - replacesEntireRecord: Indicates whether the operation should replace the entire record or just update the appropriate fields.
    public func update(tableName: String, records: [Record], replacesEntireRecords: Bool = false) -> AnyPublisher<[Record], AirtableError> {
        let method = replacesEntireRecords ? "PUT" : "PATCH"
        
        let batches: [URLRequest?] = records
            .chunked(by: Self.batchLimit)
            .map { requestEncoder.encodeRecords($0, shouldAddID: true) }
            .map { buildRequest(method: method, path: tableName, payload: $0) }
        
        return Publishers.Sequence(sequence: batches)
            .flatMap { request in
                self.performRequest(request, decoder: self.responseDecoder.decodeRecords(data:))
            }
            .reduce([Record](), +)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Detele records from a table
    
    /// Deletes a record from a table.
    ///
    /// - Parameters:
    ///   - tableName: Name of the table where the record is
    ///   - recordID: The id of the record to delete.
    /// - Returns: A publisher with either the record which was deleted or an error
    public func delete(tableName: String, recordID: String) -> AnyPublisher<Record, AirtableError> {
        let request = buildRequest(method: "DELETE", path: "\(tableName)/\(recordID)")
        return performRequest(request, decoder: responseDecoder.decodeDeleteResponse(data:))
    }
    
    /// Deletes multiple records by their ID.
    ///
    /// - Parameters:
    ///   - tableName: Name of the table where the records are.
    ///   - recordIDs: IDs of the records to be deleted.
    public func delete(tableName: String, recordIDs: [String]) -> AnyPublisher<[Record], AirtableError> {
        let batches = recordIDs.map { URLQueryItem(name: "records[]", value: $0) }
            .chunked(by: Self.batchLimit)
            .map { buildRequest(method: "DELETE", path: tableName, queryItems: $0) }
        
        return Publishers.Sequence(sequence: batches)
            .flatMap { request in
                self.performRequest(request, decoder: self.responseDecoder.decodeBatchDeleteResponse(data:))
            }
            .reduce([Record](), +)
            .eraseToAnyPublisher()
    }
    
}

// MARK: - Helpers

extension Airtable {
    
    func performRequest<T>(_ request: URLRequest?, decoder: @escaping (Data) throws -> T) -> AnyPublisher<T, AirtableError> {
        guard let urlRequest = request else {
            let error = AirtableError.invalidParameters(operation: #function, parameters: [request as Any])
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap(errorHander.mapResponse(_:))
            .tryMap(decoder)
            .mapError(errorHander.mapError(_:))
            .eraseToAnyPublisher()
    }
    
    func buildRequest(method: String, path: String, queryItems: [URLQueryItem]? = nil, payload: [String: Any]? = nil) -> URLRequest? {
        let url: URL?
        
        if let queryItems = queryItems {
            var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            url = components?.url
        } else {
            url = baseURL.appendingPathComponent(path)
        }
        
        guard let theURL = url else { return nil }
        
        var request = URLRequest(url: theURL)
        request.httpMethod = method
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        if let payload = payload {
            do {
                request.httpBody = try requestEncoder.asData(json: payload)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                return nil
            }
        }
        
        return request
    }
}

