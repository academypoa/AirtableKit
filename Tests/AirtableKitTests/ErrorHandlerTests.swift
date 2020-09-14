import Foundation

import Quick
import Nimble

@testable import AirtableKit

class ErrorHandlerTests: QuickSpec {
    override func spec() {
        func httpResponse(code: Int) -> HTTPURLResponse {
            HTTPURLResponse(
                url: URL(string: "https://api.airtable.com")!,
                statusCode: code,
                httpVersion: "1.1",
                headerFields: nil
            )!
        }
        
        func _input(code: Int, data: String? = nil) -> (Data, HTTPURLResponse) {
            (data?.data(using: .utf8) ?? Data(), httpResponse(code: code))
        }
        
        describe("the error handler") {
            var handler: ErrorHandler!
            
            beforeEach {
                handler = ErrorHandler()
            }
            
            context("dealing with URLSession responses") {
                it("doesn't interfere with non-HTTP responses") {
                    let input = (Data(), URLResponse())
                    let output = try handler.mapResponse(input)
                    expect(output) == Data()
                }
                
                it("returns the data when the response is successful") {
                    let input = _input(code: 200, data: "some data")
                    expect { try handler.mapResponse(input) } == "some data".data(using: .utf8)!
                }
                
                it("handles errors specified by Airtable's API contract") {
                    let codesAndErrors: [Int: AirtableError] = [
                        400: .badRequest,
                        401: .unauthorized,
                        402: .paymentRequired,
                        403: .forbidden,
                        404: .notFound,
                        413: .requestEntityTooLarge,
                        422: .unprocessableEntity,
                    ]
                    
                    codesAndErrors.forEach { (code, error) in
                        expect { try handler.mapResponse(_input(code: code)) }.to(throwError(error))
                    }
                }
                
                it("treats other HTTP codes to an unspecified HTTP error") {
                    let input = _input(code: 405)
                    let expected = AirtableError.http(httpResponse: httpResponse(code: 405), data: Data())
                    expect { _ = try handler.mapResponse(input) }.to(throwError(expected))
                }
            }
            
            context("mapping errors") {
                it("doesn't re-map instances of AirtableError") {
                    let input = AirtableError.notFound
                    expect(handler.mapError(input)) == .notFound
                }
                
                it("treats custom NSError errors as unknown") {
                    let input = NSError(domain: "com.example", code: -1, userInfo: nil)
                    expect(handler.mapError(input)) == .unknown(input)
                }
                
                it("map URLErrors to a special case") {
                    let input = URLError(.notConnectedToInternet)
                    expect(handler.mapError(input)) == .network(input)
                }
            }
        }
    }
}
