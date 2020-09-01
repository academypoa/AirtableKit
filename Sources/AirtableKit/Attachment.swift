import Foundation

/// An Airtable attachment.
///
/// After saved, every attachment has an ID
public struct Attachment {
    
    /// ID of the attachment.
    ///
    /// The ID is always present when the attachment is read from Airtable's API, and should be informed when updating a record and keeping an attachment on Airtable.
    public let id: String
    
    /// A URL of the attachment.
    ///
    /// When creating or updating an attachment, Airtable downloads the file on this URL and saves a copy of it.
    ///
    /// When reading an attachment, this field contains an URL that can be used to download the file.
    public var url: URL!
    
    /// An optional name for the file.
    public var filename: String?
    
    /// Additional metadata of the attachment, like thumbnails. Not guaranteed to be present.
    ///
    /// _Falsy_ values (`0`, `[]`, `null`) are not present when the record is read from Airtable.
    public var metadata: [String: Any]
}

extension Attachment {
    
    /// Creates an attachment with the required properties to be uploaded.
    ///
    /// - Parameters:
    ///   - url: An URL where the file can be downloaded by Airtable servers.
    ///   - filename: An optional name for the file.
    ///   - metadata: Additional metadata, like dimensions (if it's an image). Not required.
    public static func create(url: URL, filename: String? = nil, metadata: [String: Any] = [:]) -> Attachment {
        Attachment(id: "", url: url, filename: filename, metadata: metadata)
    }
    
    /// Creates an attachment with the required properties to update and existing attachment in Airtable.
    ///
    /// - Parameters:
    ///   - id: The ID of the existing attachment.
    ///   - url: An URL where the file can be downloaded by Airtable servers. If `nil`, the existing file content is not updated.
    ///   - filename: An optional name for the file.
    ///   - metadata: Additional metadata, like dimensions (if it's an image). Not required.
    public static func update(id: String, url: URL? = nil, filename: String? = nil, metadata: [String: Any] = [:]) -> Attachment {
        Attachment(id: id, url: url, filename: filename, metadata: metadata)
    }
}
