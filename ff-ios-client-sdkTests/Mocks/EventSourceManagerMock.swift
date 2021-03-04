//
//  EventSourceManagerMock.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 5.2.21..
//

import Foundation
@testable import ff_ios_client_sdk

class EventSourceManagerMock: EventSourceManagerProtocol {
	var forceDisconnected: Bool
	var configuration: CfConfiguration?
	var parameterConfig: ParameterConfig?
	
	static func shared(parameterConfig: ParameterConfig? = nil) -> EventSourceManagerProtocol {
		return EventSourceManagerMock()!
	}
	
	var streamReady: Bool
	
	init?() {
		self.streamReady = false
		self.forceDisconnected = false
	}
	func connect(lastEventId: String?) {
		self.streamReady = true
	}
	
	func disconnect() {
		self.streamReady = false
	}
	
	func onComplete(_ completion: @escaping (Int?, Bool?, ff_ios_client_sdk.CFError?) -> ()) {
		completion(200,false,nil)
	}
	
	func onMessage(_ completion: @escaping (String?, String?, String?) -> ()) {
        completion(nil,nil,nil)
    }

	func onOpen(_ completion: @escaping () -> ()) {
        completion()
    }

	func addEventListener(_ event: String, completion: @escaping (String?, String?, String?) -> ()) {
		if event == "event-success" {
			let successMessage = Message(event: "someEvent", domain: "someDomain", identifier: "success", version: 3000)
			let messageData = try? JSONEncoder().encode(successMessage)
			let stringMessage = String(data: messageData!, encoding: .utf8)
			completion("someId",event,stringMessage)
		} else {
			completion(nil, nil, nil)
		}
    }
	
	func destroy() {
		self.streamReady = false
	}
}
