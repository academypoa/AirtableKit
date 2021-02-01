//
//  Offset Delegate.swift
//  
//
//  Created by Joshua Botts on 1/27/21.
//

import Foundation

/// An object to pass offset values from the decoder to the request builder as Airtable returns list requests

class OffsetDelegate {
    var offset: String?
    
    static let shared = OffsetDelegate()

}
