//
//  RequestEncoderTests.swift
//  AirtableTests
//
//  Created by Rafael Victor Ruwer Araujo on 04/02/20.
//  Copyright © 2020 Apple Developer Academy | POA. All rights reserved.
//

@testable import AirtableKit
import Quick
import Nimble
import Foundation

class RequestEncoderTests: QuickSpec {
    override func spec() {
        describe("the encoder") {
            var encoder: RequestEncoder!
            
            beforeEach {
                encoder = RequestEncoder()
            }
            
            context("encoding a record for creation") {
                var record: Record!
                var encoded: [String: Any]!
                
                beforeEach {
                    record = Record.create(fields: ["some_data": 3.1415])
                    encoded = encoder.encodeRecord(record)
                }
                
                it("doesn't encode the record's id") {
                    expect(encoded["id"]).to(beNil())
                }
            }
            
            context("encoding a record for update") {
                var record: Record!
                var encoded: [String: Any]!
                var fields: [String: Any]!
                
                beforeEach {
                    record = Record.update(id: "rec222", fields: [
                        "id": 9124,
                        "Name": "John Doe",
                        "url": URL(string: "https://apple.com")!,
                        "multi": ["a", "lp"],
                        "bool_data": true,
                        "dbl_data": 1.2,
                    ])
                    
                    encoded = encoder.encodeRecord(record)
                    fields = encoded["fields"] as? [String: Any]
                }
                
                it("encodes the expected number of top-level fields") {
                    expect(encoded.count) == 2
                }
                
                it("encodes the required top-level fields") {
                    expect(encoded["id"]).toNot(beNil())
                    expect(encoded["fields"]).toNot(beNil())
                }
                
                it("doesn't encode the read-only field createdTime") {
                    expect(encoded["createdTime"]).to(beNil())
                }
                
                it("encodes the expected number of fields") {
                    expect(fields.count) == 6
                }
                
                it("encodes an URL field as a string") {
                    expect(fields["url"] as? String) == "https://apple.com"
                }
                
                it("encodes the remaining fields correctly") {
                    expect(fields["id"] as? Int) == 9124
                    expect(fields["Name"] as? String) == "John Doe"
                    expect(fields["multi"] as? [String]) == ["a", "lp"]
                    expect(fields["bool_data"] as? Bool) == true
                    expect(fields["dbl_data"] as? Double) == 1.2
                }
            }
            
            context("encoding an attachment for creation") {
                var attachment: Attachment!
                var encoded: [String: Any]!
                
                beforeEach {
                    attachment = Attachment.create(url: URL(string: "https://placehold.it/200")!)
                    encoded = encoder.encodeAttachment(attachment)
                }
                
                it("doesn't have the 'id' field") {
                    expect(encoded["id"]).to(beNil())
                }
                
                it("has a single field") {
                    expect(encoded.count) == 1
                }
            }
            
            context("encoding an attachment for update") {
                var attachment: Attachment!
                var encoded: [String: Any]!
                
                beforeEach {
                    attachment = Attachment.update(
                        id: "att382",
                        metadata: ["additional_data": 3982]
                    )
                    
                    encoded = encoder.encodeAttachment(attachment)
                }
                
                it("encodes the expected number of fields") {
                    expect(encoded.count) == 2
                }
                
                it("encodes the required 'id' field") {
                    expect(encoded["id"] as? String) == "att382"
                }
                
                it("encodes the remaining fields correctly") {
                    expect(encoded["additional_data"] as? Int) == 3982
                }
            }
            
            context("encoding a record with attachments") {
                var attachment: Attachment!
                var record: Record!
                var encoded: [String: Any]!
                var fields: [String: Any]!
                
                beforeEach {
                    attachment = Attachment.create(url: URL(string: "https://placehold.it/200")!)
                    record = Record.create(fields: [
                        "single": attachment as Any,
                        "multiple": [attachment, attachment]
                    ])
                    
                    encoded = encoder.encodeRecord(record)
                    fields = encoded["fields"] as? [String: Any] ?? [:]
                }
                
                it("encodes the 'single' field as an array") {
                    expect(fields["single"] as? [[String: Any]]).toNot(beNil())
                }
                
                it("encodes the 'multiple' field correctly") {
                    let multiple = fields["multiple"] as? [Any]
                    expect(multiple?.count) == 2
                }
            }
        }
    }
}
