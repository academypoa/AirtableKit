import Foundation

func date(_ iso: String) -> Date? {
    ISO8601DateFormatter().date(from: iso)
}

func readFile(_ resource: String) -> Data {
    switch resource {
    case "multiple_records.json":
        return Mocks.multipleRecords.data(using: .utf8)!
    case "single_record.json":
        return Mocks.singleRecord.data(using: .utf8)!
    case "single_record_delete.json":
        return Mocks.singleRecordDelete.data(using: .utf8)!
    case "single_record_delete_fail.json":
        return Mocks.singleRecordDeleteFail.data(using: .utf8)!
    case "multiple_records_delete.json":
        return Mocks.multipleRecordsDelete.data(using: .utf8)!
    default:
        fatalError("unknown resouce: \(resource)")
    }
    
    // TODO: fix when we start using swift 5.3 toolchain
//    let components = resource.components(separatedBy: ".")
//    let name = components.dropLast().joined(separator: ".")
//    let ext = components.last
//
//    class _Class {}
//
//    guard let url = Bundle(for: _Class.self).url(forResource: resource, withExtension: ext) else {
//        fatalError("unknown resource: \(resource ?? "").\(ext ?? "")")
//    }
//
//    do {
//        return try Data(contentsOf: url)
//    } catch {
//        fatalError("failed to read data for resource at \(url)")
//    }
}
