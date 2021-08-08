import Foundation

/// The class responsible for handling the responses received from Airtable's requests.
///
/// Converts JSON objects to `Record`s and `Attachment`s.
final class ResponseDecoder {
    
    /// Date formatter used for writing dates to JSON objects
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
    
    /// Decodes a JSON `Data` as a `Record`.
    ///
    /// - Throws: `AirtableError`.
    func decodeRecord(data: Data) throws -> Record {
        try _decodeRecord(json: asJSON(data: data))
    }
    
    /// Decodes a delete response `Data` as a `Record`.
    ///
    /// - Parameter data: Data returned from the request
    /// - Throws: `AirtableError`
    /// - Returns: The record containing the deletion operation payload.
    func decodeDeleteResponse(data: Data) throws -> Record {
        try _decodeDeleteResponse(json: asJSON(data: data))
    }
    
    /// Decodes a JSON `Data` as a list of `Record`s.
    ///
    /// - Throws: `AirtableError`.
    func decodeRecords(data: Data) throws -> [Record] {
        let json = try asJSON(data: data)
        let records = json["records"] as? [[String: Any]] ?? []
        return try records.map(_decodeRecord)
    }
    
    /// Decodes a JSON `Data` as a list of `Record`s. It keeps the offset value
    /// and returns an Airtable response object
    ///
    /// - Throws: `AirtableError`.
    func decodeRecordsWithOffset(data: Data) throws -> AirtableResponse {
        let json = try asJSON(data: data)
        let records = json["records"] as? [[String: Any]] ?? []
        let decodedRecords = try records.map(_decodeRecord)
    /// Added parsing of offset value if present
//        var off: String? = nil
//        if let offset = json["offset"] as? String
//        {
//          off = offset
//        }
        let offset = json["offset"] as? String ?? nil
        let response = AirtableResponse( records: decodedRecords , offset: offset )
       
    /// Added storage of offset value in shared delegate object
        return response
    }
    
    /// Decodes a JSON `Data` from the batch delete request as a list of `Record`s.
    ///
    /// - Throws: `AirtableError`.
    func decodeBatchDeleteResponse(data: Data) throws -> [Record] {
        let json = try asJSON(data: data)
        let records = json["records"] as? [[String: Any]] ?? []
        
        return try records.map(_decodeDeleteResponse)
    }
    
    private func _decodeAttachment(json: [String: Any]) -> Attachment? {
        guard let id = json["id"] as? String,
            let urlString = json["url"] as? String,
            let url = URL(string: urlString) else {
                return nil
        }
        
        return Attachment(url: url, id: id, fileName: json["filename"] as? String, metadata: json)
    }
    
    private func _decodeDeleteResponse(json: [String : Any]) throws -> Record {
        guard let id = json["id"] as? String,
            let deleted = json["deleted"] as? Bool else {
                throw AirtableError.missingRequiredFields("id, deleted")
        }
        
        if !deleted {
            throw AirtableError.deleteOperationFailed(id)
        } else {
            return Record(fields: ["deleted" : deleted], id: id)
        }
    }
    
    private func _decodeRecord(json: [String: Any]) throws -> Record {
        guard let id = json["id"] as? String else { throw AirtableError.missingRequiredFields("id") }
        guard let createdTimeString = json["createdTime"] as? String else { throw AirtableError.missingRequiredFields("createdTime") }
        guard let fields = json["fields"] as? [String: Any] else { throw AirtableError.missingRequiredFields("fields") }
        
        let createdTime = Self.formatter.date(from: createdTimeString) ?? Date()
        
        // convert fields to possible attachments
        let attachments = fields.compactMapValues { value -> [Attachment]? in
            // attachments are an array of json objects
            guard let values = value as? [[String: Any]] else { return nil }
            
            // map the json objects to attachments
            let mapped = values.compactMap(_decodeAttachment(json:))
            
            // if all objects could be mapped, then this field is of type "attachment"
            guard mapped.count == values.count else { return nil }
            
            return mapped
        }
        
        var record = Record(fields: fields, id: id, attachments: attachments)
        record.createdTime = createdTime
        return record
    }
    
    // MARK: - Helpers
    
    /// Converts a binary `Data` from a request's response to a JSON dictionary.
    ///
    /// - Throws: `AirtableError`.
    func asJSON(data: Data) throws -> [String: Any] {
        let json: [String: Any]?
        
        do {
            json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        } catch {
            throw AirtableError.invalidResponse(data)
        }
        
        guard let parsed = json else {
            throw AirtableError.invalidResponse(data)
        }
        
        return parsed
    }
}
