import Foundation

import Quick
import Nimble

@testable import AirtableKit

class ModelsTest: QuickSpec {
    override func spec() {
        describe("a record") {
            var record: Record!
            
            beforeEach {
                record = Record(id: "rec123", fields: [
                    "name": "John",
                    "age": 34,
                    "photo": Attachment(url: URL(string: "https://placehold.it/300")),
                    "images": [Attachment(id: "att123", url: nil),
                               Attachment(id: "att456", url: nil)]
                ])
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
                    attachment = Attachment(id: nil, url: nil)
                    
                    expect(attachment).toNot(beNil())
                }
            }
        }
    }
}
