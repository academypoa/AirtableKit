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
    
    // MARK: - Add records to a table
    
    /// Creates a record on a table.
    ///
    /// - Parameters:
    ///   - tableName: Name of the table where the record is.
    ///   - record: The record to be created. The record should have `id == nil`.
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
    
    /// Creates multiple records on a table.
    ///
    /// - Parameters:
    ///   - tableName: Name  of the table where the record is.
    ///   - records: The records to be created. All records should have `id == nil`.
    public func create(tableName: String, records: [Record]) -> AnyPublisher<[Record], AirtableError> {
        let batches = records.chunked(by: Self.batchLimit)
        
        let publisherForBatch = { (records: [Record]) in
            self.performBatchRequest(
                method: "POST",
                tableName: tableName,
                payload: self.requestEncoder.encodeRecords(records, shouldAddID: false),
                decoder: self.responseDecoder.decodeRecords(data:)
            )
        }
        
        return Publishers.Sequence(sequence: batches)
            .flatMap(publisherForBatch)
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
            let error = AirtableError.invalidParameters(operation: "patch",
                                                        parameters: [tableName, record, record.id as Any])
            return Fail<Record, AirtableError>(error: error).eraseToAnyPublisher()
        }
        
        var request = makeRequest(path: "\(tableName)/\(recordID)")
        request.httpMethod = replacesEntireRecord ? "PUT" : "PATCH"
        
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
        let batches = records.chunked(by: Self.batchLimit)
        
        let publisherForBatch = { (records: [Record]) in
            self.performBatchRequest(
                method: replacesEntireRecords ? "PUT" : "PATCH",
                tableName: tableName,
                payload: self.requestEncoder.encodeRecords(records, shouldAddID: true),
                decoder: self.responseDecoder.decodeRecords(data:)
            )
        }
        
        return Publishers.Sequence(sequence: batches)
            .flatMap(publisherForBatch)
            .reduce([Record](), +)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Detele records from a table
    
    /// Deletes a record from a table.
    ///
    /// - Parameters:
    ///   - tableName: Name of the table where the record is
    ///   - record: The record to delete.
    /// - Returns: A publisher with either the record which was deleted or an error
    public func delete(tableName: String, record: Record) -> AnyPublisher<Record, AirtableError> {
        guard let id = record.id else {
            let error = AirtableError.missingRequiredFields("id")
            return Fail<Record, AirtableError>(error: error).eraseToAnyPublisher()
        }
        
        var request = makeRequest(path: "\(tableName)/\(id)")
        request.httpMethod = "DELETE"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap(errorHander.mapResponse(_:))
            .tryMap(responseDecoder.decodeDeleteResponse(data:))
            .mapError(errorHander.mapError(_:))
            .eraseToAnyPublisher()
    }
    
    /// Deletes multiple records by their ID.
    ///
    /// - Parameters:
    ///   - tableName: Name of the table where the records are.
    ///   - recordIDs: IDs of the records to be deleted.
    public func delete(tableName: String, recordIDs: [String]) -> AnyPublisher<[Record], AirtableError> {
        let batches = recordIDs.map { URLQueryItem(name: "records[]", value: $0) }
            .chunked(by: Self.batchLimit)
        
        let publisherForBatch = { (queryItems: [URLQueryItem]) in
            self.performBatchRequest(
                method: "DELETE",
                tableName: tableName,
                queryItems: queryItems,
                decoder: self.responseDecoder.decodeBatchDeleteResponse(data:)
            )
        }
        
        return Publishers.Sequence(sequence: batches)
            .flatMap(publisherForBatch)
            .reduce([Record](), +)
            .eraseToAnyPublisher()
    }
    
}

extension Airtable {
    private func performBatchRequest<T>(
        method: String,
        tableName: String,
        queryItems: [URLQueryItem]? = nil,
        payload: [String: Any]? = nil,
        decoder: @escaping (Data) throws -> T
    ) -> AnyPublisher<T, AirtableError> {
        
        // prepare the request
        guard var request = makeRequest(path: tableName, queryItems: queryItems) else {
            let error = AirtableError.invalidParameters(operation: #function,
                                                        parameters: [method, tableName, queryItems as Any, payload as Any])
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        request.httpMethod = method
        
        // set the payload
        if let payload = payload {
            do {
                request.httpBody = try requestEncoder.asData(json: payload)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                let err = AirtableError.invalidParameters(operation: #function,
                                                          parameters: [method, tableName, queryItems as Any, payload])
                return Fail(error: err).eraseToAnyPublisher()
            }
        }
        
        // perform the request
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap(errorHander.mapResponse(_:))
            .tryMap(decoder)
            .mapError(errorHander.mapError(_:))
            .eraseToAnyPublisher()
    }
    
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

