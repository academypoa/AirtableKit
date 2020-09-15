import Foundation

import Quick
import Nimble

@testable import AirtableKit

class DateFormatterTests: QuickSpec {
    override func spec() {
        describe("The decoder date formatter") {
            var formatter: DateFormatter!
            beforeEach {
                formatter = ResponseDecoder.formatter
            }
            
            context("extracting a correctly-formated string date") {
                let stringDate = "2017-10-16T11:37:26.000Z"
                var testingDaste: Date!
                beforeEach {
                    testingDate = formatter.date(from: stringDate)!
                }
                
                it("succeeds in extracting the correct date") {
                    expect(testingDate) == date(day: 16, month: 10, year: 2017,
                                                hour: 11, minute: 37, second: 26)
                }
            }
            context("extracting a string from a date") {
                let testingDate = date(day: 16, month: 10, year: 2017,
                                       hour: 11, minute: 37, second: 26)!
                var string: String!
                beforeEach {
                    string = formatter.string(from: testingDate)
                }
                
                it("succeeds in extracting the string") {
                    expect(string) == "2017-10-16T11:37:26.000Z"
                }
            }
        }
    }
}
