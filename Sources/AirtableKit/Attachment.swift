import Foundation

/// An Airtable attachment.
///
/// After saved, every attachment has an ID and download URL.
///
/// ### Add attachments to records
///
/// To add an attachment, you shouldn't assign a value to the `id` field. You must set a URL to an image hosted somewhere on the Internet, because Airtable will
/// download the image from this location.
///
/// After the record is created/updated, you don't need to host the attachment anymore. Future requests will return an URL to the attachment hosted by Airtable.
///
/// ### Add attachments on a field with already-existing attachments
///
/// When you update a record, if you want to keep the existing attachments for a field and add another attachment, you should send the existing attachment objects
/// with only their ID set. If you send a URL, Airtable will download and update the attachment data.
///
public struct Attachment {
    
    /// ID of the attachment.
    ///
    /// The ID is always present when the attachment is read from Airtable's API, and should be informed when updating a record and keeping an attachment
    /// on that record.
    public var id: String?
    
    /// A URL of the attachment.
    ///
    /// When creating or updating an attachment, Airtable downloads the file on this URL and saves a copy of it. This means that the file should be stored
    /// somewhere and publicly acessible on the Internet (i.e. like an image hosting service). If you're updating a record and want to keep a attachment without
    /// changing its contents, provide the attachment ID on `id` field and don't assign a value to this field.
    ///
    /// When reading an attachment, this field contains an URL that can be used to download the file.
    public var url: URL!
    
    /// An optional name for the file.
    public var fileName: String?
    
    /// Additional metadata of the attachment, like thumbnails. Not guaranteed to be present.
    ///
    /// All fields returned from Airtable are present here, including `id` and `url`. _Falsy_ values (`0`, `[]`, `null`) are not present when the record is read
    /// from Airtable.
    ///
    /// For a complete reference on the supported metadata, [check the Airtable documentation for attachments on your table](https://airtable.com/api).
    public var metadata: [String: Any]
    
    /// Creates an attachment object to be used when interacting with AirtableKit classes.
    ///
    /// - Parameters:
    ///   - url: The external URL hosting the attachment. Airtable will download a local copy of the attachment from this URL. Required when creating an
    ///          attachment; pass `nil` if you don't want to update the attachment contents.
    ///   - id: The ID of the attachment. Pass `nil` when creating attachments, and a non-`nil` value when updating.
    ///   - fileName: An optional name for the file.
    ///   - metadata: Additional metadata, like dimensions (if it's an image). Not required.
    public init(url: URL?, id: String? = nil, fileName: String? = nil, metadata: [String: Any] = [:]) {
        self.url = url
        self.id = id
        self.fileName = fileName
        self.metadata = metadata
    }
}
