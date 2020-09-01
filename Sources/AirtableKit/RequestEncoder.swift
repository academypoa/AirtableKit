import Foundation

/// The class responsible for creating the body for Airtable's requests.
///
/// Converts `Record`s and `Attachment`s to JSON objects.
final class RequestEncoder {
    
    /// Encodes a `Record` as a JSON object.
    ///
    /// - Parameters:
    ///   - shouldAddID: If `false`, doesn't adds the `"id"` field on the payload. Use this when updating a single record (when the payload must not contain the record's ID), for example.
    func encodeRecord(_ record: Record, shouldAddID: Bool = true) -> [String: Any] {
        var fields = record.fields.mapValues { value -> Any in
            // Attachment and [Attachment] on the `fields` property are still encoded
            if let attachments = value as? [Attachment] {
                return attachments.map(encodeAttachment)
            } else if let attachment = value as? Attachment {
                return [encodeAttachment(attachment)]
            }
            
            // URL and [URL]
            if let url = value as? URL {
                return url.absoluteString
            } else if let urls = value as? [URL] {
                return urls.map { $0.absoluteString }
            }
            
            return value
        }
        
        // encode attachments after the 'simple' fields
        record.attachments.forEach { entry in
            let (key, attachments) = entry
            fields[key] = attachments.map(encodeAttachment(_:))
        }
        
        var payload: [String: Any] = [
            "fields": fields
        ]
        
        // add id only if not empty
        if shouldAddID && !record.id.isEmpty {
            payload["id"] = record.id
        }
        
        return payload
    }
    
    /// Encodes an `Attachment` as a JSON object.
    func encodeAttachment(_ attachment: Attachment) -> [String: Any] {
        var payload = attachment.metadata
        
        payload["url"] = attachment.url?.absoluteString
        payload["filename"] = attachment.filename
        
        // add id only if not empty
        if !attachment.id.isEmpty {
            payload["id"] = attachment.id
        }
        
        return payload
    }
    
    // MARK: - Helpers
    
    /// Converts a JSON object to its binary `Data` representation.
    ///
    /// - Throws: `AirtableError`.
    func asData(json: Any) throws -> Data {
        let data: Data
        
        do {
            data = try JSONSerialization.data(withJSONObject: json)
        } catch {
            throw AirtableError.invalidParameters(operation: #function, parameters: [json])
        }
        
        return data
    }
}
