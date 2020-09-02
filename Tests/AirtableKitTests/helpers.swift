//
//  helpers.swift
//  AirtableTests
//
//  Created by Rafael Victor Ruwer Araujo on 28/01/20.
//  Copyright © 2020 Apple Developer Academy | POA. All rights reserved.
//

import Foundation

func date(_ iso: String) -> Date? {
    ISO8601DateFormatter().date(from: iso)
}

func readFile(_ resource: String?, _ ext: String?) -> Data {
    switch resource {
    case "multiple_records":
        return Mocks.multipleRecords.data(using: .utf8)!
    case "single_record":
        return Mocks.singleRecord.data(using: .utf8)!
    case "single_record_delete":
        return Mocks.singleRecordDelete.data(using: .utf8)!
    default:
        fatalError("unknown resouce: \(resource!)")
    }
    
    // TODO: fix when we start using swift 5.3 toolchain
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
