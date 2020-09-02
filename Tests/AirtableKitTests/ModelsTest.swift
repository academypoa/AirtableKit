import Foundation

import Quick
import Nimble

@testable import AirtableKit

class ModelsTest: QuickSpec {
    override func spec() {
        describe("a record") {
            var record: Record!
            
            beforeEach {
                record = Record(fields: [
                    "name": "John",
                    "age": 34,
                    "photo": Attachment(url: URL(string: "https://placehold.it/300")),
                    "images": [Attachment(url: nil, id: "att123"),
                               Attachment(url: nil, id: "att456")]
                ], id: "rec123")
            }
            
            it("doesn't assign the createdTime field") {
                expect(record.createdTime).to(beNil())
            }
            
            it("doesn't remove attachments from `fields`") {
                let photo = record.fields["photo"] as? Attachment
                expect(photo).toNot(beNil())
                expect(photo?.url) == URL(string: "https://placehold.it/300")
                
                let images = record.fields["images"] as? [Attachment]
                expect(images).to(haveCount(2))
            }
            
            it("doesn't move attachments from `fields` to `attachments`") {
                expect(record.attachments["photo"]).to(beNil())
            }
        }
        
        describe("an attachment") {
            var attachment: Attachment!
            
            context("creating an empty attachment") {
                it("accepts all fields empty") {
                    attachment = Attachment(url: nil, id: nil)
                    
                    expect(attachment).toNot(beNil())
                }
            }
        }
    }
}
