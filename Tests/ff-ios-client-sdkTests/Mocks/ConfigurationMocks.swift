//
//  ConfigurationMocks.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 4.2.21..
//

struct ConfigurationMocks {
    
    static let baseUrl                           = "https://config.ff.harness.io/api/1.0"
    static let eventUrl                          = "https://events.ff.harness.io/api/1.0"
    static let streamUrl                         = "\(baseUrl)/stream"
    static let streamEnabled                     = false
    static let allAttributesPrivate              = false
    static let privateAttributeNames: [String]   = []
}
