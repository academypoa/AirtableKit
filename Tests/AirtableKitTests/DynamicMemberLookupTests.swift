import Foundation

import Quick
import Nimble

@testable import AirtableKit

final class DMLTest: QuickSpec {
    
    static let date = Date()
    
    override func spec() {
        describe("A record that supports Dynamic Member Lookup") {
            var record: Record!
            
            beforeEach {
                record = Record(
                    fields: [
                        "name" : "Nicolas",
                        "age" : 25,
                        "isCool" : true,
                        "updatedTime" : Self.date
                    ]
                )
            }
            
            it("supports acessing string values") {
                expect(record.name) == "Nicolas"
            }
            
            
            it("supports accessing int values") {
                expect(record.age) == 25
            }
            
            it("supports acessing boolean values") {
                expect(record.isCool) == true
            }
            
            it("supports accessing  date values") {
                expect(record.updatedTime) == Self.date
            }
        }
    }
}
