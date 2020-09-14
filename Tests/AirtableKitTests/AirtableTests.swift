import Foundation
import Combine

import Quick
import Nimble
import OHHTTPStubs
import OHHTTPStubsSwift

@testable import AirtableKit

class AirtableTests: QuickSpec {
    override func spec() {
        describe("the airtable service") {
            var service: Airtable!
            
            beforeEach {
                service = Airtable(baseID: "base123", apiKey: "key123")
            }
            
            context("auxiliary methods") {
                context("performRequest(_:decoder:)") {
                    var subscription: AnyCancellable?
                    var output: [String: Any]?
                    var completion: Subscribers.Completion<AirtableError>!
                    
                    afterEach {
                        subscription?.cancel()
                        subscription = nil
                        output = nil
                        completion = nil
                    }
                    
                    it("works with a valid request") {
                        let request = URLRequest(url: URL(string: "http://example.com")!)
                        stub(condition: isHost("example.com") && isMethodGET()) { _ in
                            HTTPStubsResponse(jsonObject: ["key": "value"], statusCode: 200, headers: nil)
                        }
                        
                        subscription = service.performRequest(request, decoder: jsonDecoder(data:))
                            .sink(receiveCompletion: { completion = $0 }) { output = $0 }
                        
                        expect(completion).toEventually(equal(.finished))
                        expect(output as? [String: String]).toEventually(equal(["key": "value"]))
                    }
                    
                    it("fails with an invalid request") {
                        let request: URLRequest? = nil
                        
                        subscription = service.performRequest(request, decoder: jsonDecoder(data:))
                            .sink(receiveCompletion: { completion = $0 }) { output = $0 }
                        
                        let error = AirtableError.invalidParameters(operation: "performRequest(_:decoder:)", parameters: [request as Any])
                        expect(completion).toEventually(equal(.failure(error)))
                        expect(output).toEventually(beNil())
                    }
                    
                    it("handles HTTP errors") {
                        let request = URLRequest(url: URL(string: "http://example.com")!)
                        stub(condition: isHost("example.com") && isMethodGET()) { _ in
                            HTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
                        }
                        
                        subscription = service.performRequest(request, decoder: jsonDecoder(data:))
                            .sink(receiveCompletion: { completion = $0 }) { output = $0 }
                        
                        expect(completion).toEventually(equal(.failure(.notFound)))
                        expect(output).toEventually(beNil())
                    }
                    
                    it("handles URLError's") {
                        let request = URLRequest(url: URL(string: "http://example.com")!)
                        stub(condition: isHost("example.com") && isMethodGET()) { _ in
                            HTTPStubsResponse(error: URLError(.notConnectedToInternet))
                        }
                        
                        subscription = service.performRequest(request, decoder: jsonDecoder(data:))
                            .sink(receiveCompletion: { completion = $0 }) { output = $0 }
                        
                        expect(completion).toEventually(equal(.failure(.network(URLError(.notConnectedToInternet)))))
                        expect(output).toEventually(beNil())
                    }
                }
                
                context("buildRequest(method:path:queryItems:payload:)") {
                    let checkAPIKey = { (request: URLRequest?) in
                        expect(request?.value(forHTTPHeaderField: "Authorization")) == "Bearer key123"
                    }
                    
                    it("creates a simple request correctly") {
                        let request = service.buildRequest(method: "DELETE", path: "users/1")
                        
                        expect(request?.httpMethod) == "DELETE"
                        expect(request?.url?.absoluteString).to(endWith("/users/1"))
                        expect(request?.httpBody).to(beNil())
                        checkAPIKey(request)
                        expect(request?.value(forHTTPHeaderField: "Content-Type")).to(beNil())
                        expect(request?.httpBody).to(beNil())
                    }
                    
                    it("creates a request with query items") {
                        let queryItems = [URLQueryItem(name: "fields[]", value: "name"), URLQueryItem(name: "fields[]", value: "email")]
                        let request = service.buildRequest(method: "GET", path: "/users", queryItems: queryItems)
                        
                        expect(request?.httpMethod) == "GET"
                        expect(request?.url?.absoluteString).to(endWith("/users?fields%5B%5D=name&fields%5B%5D=email"))
                        checkAPIKey(request)
                        expect(request?.value(forHTTPHeaderField: "Content-Type")).to(beNil())
                        expect(request?.httpBody).to(beNil())
                    }
                    
                    it("creates a request with payload") {
                        let request = service.buildRequest(method: "POST", path: "/users", payload: ["name": "John"])
                        
                        expect(request?.httpMethod) == "POST"
                        expect(request?.url?.absoluteString).to(endWith("/users"))
                        checkAPIKey(request)
                        expect(request?.httpBody) == #"{"name":"John"}"#.data(using: .utf8)
                    }
                    
                    it("creates a complete request") {
                        let queryItems = [URLQueryItem(name: "fields[]", value: "name")]
                        let request = service.buildRequest(method: "PUT", path: "users", queryItems: queryItems, payload: ["name": "Jane"])
                        
                        expect(request?.httpMethod) == "PUT"
                        expect(request?.url?.absoluteString).to(endWith("/users?fields%5B%5D=name"))
                        checkAPIKey(request)
                        expect(request?.httpBody) == #"{"name":"Jane"}"#.data(using: .utf8)
                    }
                }
            }
        }
    }
}

func jsonDecoder(data: Data) throws -> [String: Any]? {
    try JSONSerialization.jsonObject(with: data) as? [String: Any]
}
