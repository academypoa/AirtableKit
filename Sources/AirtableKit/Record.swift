import Foundation

/// An Airtable record (a line in a table).
///
/// After saved, every record has an ID and a time of creation. These fields are valid only if the record was received from the Airtable API.
public struct Record {
    
    /// ID of the record.
    public let id: String
    
    /// Date and time the record was created.
    public let createdTime: Date
    
    /// Fields (columns) of the record.
    ///
    /// _Falsy_ values (`0`, `[]`, `null`) are not present when the record is read from Airtable.
    ///
    /// The fields returned are assigned _as-is_ to this property (no value is removed).
    public var fields: [String: Any]
    
    /// Fields (columns) of attachments.
    ///
    /// Any field with an array of objects with `id` and `url` keys is treated as an attachment. These fields are still present in the `fields` property.
    public var attachments: [String: [Attachment]]
}

extension Record {
    
    /// Creates a record with the required properties to be created on a table.
    ///
    /// - Parameter fields: The fields of the record being created.
    public static func create(fields: [String: Any], attachments: [String: [Attachment]] = [:]) -> Record {
        Record(id: "", createdTime: Date(), fields: fields, attachments: attachments)
    }
    
    /// Creates a record with the required properties to update an existing Airtable record.
    ///
    /// - Parameters:
    ///   - id: The ID of the record being updated.
    ///   - fields: The new values of the record.
    public static func update(id: String, fields: [String: Any], attachments: [String: [Attachment]] = [:]) -> Record {
        Record(id: id, createdTime: Date(), fields: fields, attachments: attachments)
    }
}
