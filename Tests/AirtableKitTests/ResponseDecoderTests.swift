@testable import AirtableKit
import Quick
import Nimble

class ResponseDecoderTests: QuickSpec {
    override func spec() {
        describe("the decoder") {
            var decoder: ResponseDecoder!
            
            beforeEach {
                decoder = ResponseDecoder()
            }
            
            context("decoding an invalid record") {
                let content = #"{ "createdTime": "2020-01-01T01:02:03T" }"#
                let data = content.data(using: .utf8)!
                
                it("throws the expected error") {
                    expect { try decoder.decodeRecord(data: data) }.to(throwError(errorType: AirtableError.self))
                }
            }
            
            context("decoding an invalid file") {
                let content = "invalid"
                let data = content.data(using: .utf8)!
                
                it("throws the expected error") {
                    expect { try decoder.decodeRecords(data: data) }.to(throwError(errorType: AirtableError.self))
                }
            }
            
            context("decoding a single record") {
                let data = readFile("single_record", "json")
                var record: Record!
                
                beforeEach {
                    record = try? decoder.decodeRecord(data: data)
                }
                
                it("decodes the metadata correctly") {
                    expect(record.id) == "rec9jki"
                    expect(record.createdTime) == date("2019-12-12T15:32:43Z")
                    expect(record.fields.count) == 4
                }
                
                it("can decode a single attachment as a list") {
                    expect(record.attachments["file"]?.count) == 1
                }
                
                it("decodes multiple attachments correctly") {
                    expect(record.attachments["many"]?.count) == 2
                    dump(record)
                }
            }
            
            context("decoding multiple records") {
                let data = readFile("multiple_records", "json")
                var records: [Record]!
                
                beforeEach {
                    records = try? decoder.decodeRecords(data: data)
                }
                
                it("decodes the correct number of records") {
                    expect(records.count) == 2
                }
                
                it("decodes the correct number of inner fields") {
                    expect(records[0].fields.count) == 4
                    expect(records[1].fields.count) == 1
                }
            }
        }
    }
}
