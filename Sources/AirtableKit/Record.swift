import Foundation

/// An Airtable record (a line in a table).
///
/// After saved, every record has an ID and a time of creation. These fields are valid only if the record was received from the Airtable API.
public struct Record {
    
    /// ID of the record.
    ///
    /// The ID is always present when the record is read from Airtable's API, and should be informed when updating a record.
    public var id: String?
    
    /// Date and time the record was created.
    ///
    /// This field is set when fetching records from Airtable; if `nil`, the record still isn't saved on Airtable.
    public internal(set) var createdTime: Date?
    
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
    
    /// Instantiates a record to be used when interacting with AirtableKit classes.
    ///
    /// - Parameters:
    ///   - id: The ID of the record; this should be `nil` if you're creating a record on a table, and not-`nil` if you're updating a record.
    ///   - fields: The fields (columns) of the table this record belongs to. Attachments should be set using the `attachments` parameter.
    ///   - attachments: Fields (columns) that store attachments. Attachments should be set only here or on the `attachments` property.
    public init(id: String? = nil, fields: [String: Any], attachments: [String: [Attachment]] = [:]) {
        self.id = id
        self.fields = fields
        self.attachments = attachments
    }
}
