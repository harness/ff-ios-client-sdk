//
//  WrapperServer.swift
//  test_wrapper
//
//  Created by Milos Vasic on 12.8.21..
//

import Foundation

import ff_ios_client_sdk

class WrapperServer {
    
    private let port: Int
    private let apiKey: String
    private let target: CfTarget
    private let configuration: CfConfiguration
    
    init(
    
        port: Int,
        apiKey: String,
        target: CfTarget,
        configuration: CfConfiguration
    ) {
        
        self.port = port
        self.apiKey = apiKey
        self.target = target
        self.configuration = configuration
    }
}
