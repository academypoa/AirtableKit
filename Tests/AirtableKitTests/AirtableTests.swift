import Foundation

import Quick
import Nimble

@testable import AirtableKit

class AirtableTests: QuickSpec {
    override func spec() {
        describe("the airtable service") {
            var service: Airtable!
            
            beforeEach {
                service = Airtable(baseID: "base123", apiKey: "key123")
            }
            
            context("auxiliary methods") {
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
