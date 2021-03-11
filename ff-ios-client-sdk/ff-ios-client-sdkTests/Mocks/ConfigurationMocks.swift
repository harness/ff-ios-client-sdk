//
//  ConfigurationMocks.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 4.2.21..
//

import Foundation


struct ConfigurationMocks {
    static let baseUrl                           = "https://config.feature-flags.uat.harness.io/api/1.0"
    static let streamUrl                         = "https://config.feature-flags.uat.harness.io/api/1.0/stream/environments"
    static let streamEnabled                     = false
    static let allAttributesPrivate              = false
    static let privateAttributeNames: [String]   = []
}
