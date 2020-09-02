import Foundation

/// The class responsible for handling the responses received from Airtable's requests.
///
/// Converts JSON objects to `Record`s and `Attachment`s.
final class ResponseDecoder {
    
    /// Date formatter used for writing dates to JSON objects
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    /// Decodes a JSON `Data` as a `Record`.
    ///
    /// - Throws: `AirtableError`.
    func decodeRecord(data: Data) throws -> Record {
        try _decodeRecord(json: asJSON(data: data))
    }
    
    /// Decodes a JSON `Data` as a list of `Record`s.
    ///
    /// - Throws: `AirtableError`.
    func decodeRecords(data: Data) throws -> [Record] {
        let json = try asJSON(data: data)
        let records = json["records"] as? [[String: Any]] ?? []
        
        return try records.map(_decodeRecord)
    }
    
    private func _decodeAttachment(json: [String: Any]) -> Attachment? {
        guard let id = json["id"] as? String,
            let urlString = json["url"] as? String,
            let url = URL(string: urlString) else {
                return nil
        }
        
        return Attachment(id: id, url: url, fileName: json["filename"] as? String, metadata: json)
    }
    
    private func _decodeRecord(json: [String: Any]) throws -> Record {
        guard let id = json["id"] as? String,
            let createdTimeString = json["createdTime"] as? String,
            let createdTime = Self.formatter.date(from: createdTimeString),
            let fields = json["fields"] as? [String: Any] else {
                throw AirtableError.missingRequiredFields("id, createdTime, fields")
        }
        
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
        
        var record = Record(id: id, fields: fields, attachments: attachments)
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
