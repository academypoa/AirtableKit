import Foundation

import Quick
import Nimble

@testable import AirtableKit

class ExtensionsTests: QuickSpec {
    override func spec() {
        describe("the Array extension") {
            context("the method chunked(by:)") {
                
                it("chunks arrays larger than chunkSize") {
                    let input = [1, 2, 3, 4, 5]
                    let output = input.chunked(by: 3)
                    expect(output) == [[1, 2, 3], [4, 5]]
                }
                
                it("chunks into more than one chunk") {
                    let input = (1..<25).map { $0 }
                    let output = input.chunked(by: 10)
                    expect(output) == [(1...10).map { $0 }, (11...20).map { $0 }, [21, 22, 23, 24]]
                }
                
                it("doesn't create chunks for empty arrays") {
                    let input = [Int]()
                    let output = input.chunked(by: 5)
                    expect(output) == []
                }
                
                it("doesn't create zero-length chunks") {
                    let input = [1, 2, 3]
                    let output = input.chunked(by: 3)
                    expect(output) == [[1, 2, 3]]
                }
                
                it("doesn't break arrays smaller than the chunk size") {
                    let input = [1, 2, 3]
                    let output = input.chunked(by: 5)
                    expect(output) == [[1, 2, 3]]
                }
                
                it("doesn't accept non-positive chunks") {
                    let input = [1, 2, 3]
                    expect { _ = input.chunked(by: 0) }.to(throwAssertion())
                    expect { _ = input.chunked(by: -1) }.to(throwAssertion())
                }
            }
        }
    }
}
