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
                    expect(record.createdTime) == date(day: 16, month: 10, year: 2017,
                                                       hour: 11, minute: 37, second: 26)
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
            
            context("decoding a delete single record response") {
                context("when it succeeds") {
                    let data = readFile("single_record_delete", "json")
                    var record: Record!
                    
                    beforeEach {
                        record = try? decoder.decodeDeleteResponse(data: data)
                    }
                    
                    it("decodes the positive response") {
                        expect(record.id) == "rec2yKtdiltjPFu8g"
                        expect((record.fields["deleted"] as? Bool) ?? false) == true
                    }
                }
                
                context("when it fails") {
                    let data = readFile("single_record_delete_fail", "json")
                    var record: Record!
                    var err: AirtableError!
                    
                    beforeEach {
                        do {
                            record = try decoder.decodeDeleteResponse(data: data)
                        } catch {
                            err = error as? AirtableError
                        }
                    }
                    
                    it("decodes the appropriate error") {
                        expect(record).to(beNil())
                        expect(err).toNot(beNil())
                        
                        if case let AirtableError.deleteOperationFailed(value) = err! {
                            expect(value).to(equal("rec2yKtdiltjPFu8g"))
                        } else {
                            fail("Expected `Airtable.deleteOperationFailed` but got \(err!)")
                        }
                        
                    }
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
