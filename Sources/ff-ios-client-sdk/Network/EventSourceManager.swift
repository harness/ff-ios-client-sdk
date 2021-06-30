//
//  EventSourceManager.swift
//  
//
//  Created by Dusan Juranovic on 22.2.21..
//

import Foundation

protocol EventSourceManagerProtocol {
	
    static func shared(parameterConfig: ParameterConfig?) -> EventSourceManagerProtocol
	
    var forceDisconnected: Bool {get set}
	var parameterConfig: ParameterConfig? {get set}
	var configuration: CfConfiguration? {get set}
	var streamReady: Bool {get}
	
    func onOpen(_ completion:@escaping()->())
	func onComplete(_ completion:@escaping(Int?, Bool?, CFError?)->())
	func onMessage(_ completion:@escaping(String?, String?, String?)->())
	func addEventListener(_ event: String, completion:@escaping(String?, String?, String?)->())
	func connect(lastEventId: String?)
	func disconnect()
	func destroy()
}

class EventSourceManager: EventSourceManagerProtocol {
	
    //MARK: - Internal properties -
	var streamReady: Bool {
		switch eventSource?.readyState {
			case .connecting, .open: return true
			default: return false
		}
	}
	
	var forceDisconnected = false
	var eventSource: EventSource?
	var configuration: CfConfiguration?
	var parameterConfig: ParameterConfig? {
		
        didSet {
			
            let config = self.configuration!
            let cluster = parameterConfig?.cluster ?? ""
			let streamUrl = URL(string: "\(config.streamUrl)?cluster=\(cluster)")!
            let headers = parameterConfig?.authHeader ?? [:]
			    
            NSLog("Api, streamUrl: \(streamUrl)")
            
            if eventSource == nil {
				//Create new instance if instance is nil
				self.eventSource = EventSource(url: streamUrl, headers:headers)
			} else if (eventSource?.url != streamUrl && eventSource?.headers != headers) {
				//Update the existing instance
				self.eventSource?.url = streamUrl
				self.eventSource?.headers = headers
				//Connect to the updated stream URL
				self.forceDisconnected = true
			} else {
				self.forceDisconnected = false
			}
		}
	}
	
	static func shared(parameterConfig: ParameterConfig? = nil) -> EventSourceManagerProtocol {
		return EventSourceManager()
	}
	
	//MARK: - Private methods -
	private init() {

	}
	
	//MARK: - Internal methods -
	func onOpen(_ completion:@escaping()->()) {
		eventSource?.onOpen {
			completion()
		}
	}
	
	func onComplete(_ completion:@escaping(Int?, Bool?, CFError?)->()) {
		eventSource?.onComplete({ (statusCode, retry, error) in
			guard error == nil else {
				if let code = (error as? URLError)?.code.rawValue {
					completion(statusCode, retry, CFError.streamError(.unableToConnect(.init(code: code))))
				}
				return
			}
			completion(statusCode, retry, nil)
		})
	}
	
	func onMessage(_ completion:@escaping(String?, String?, String?)->()) {
		eventSource?.onMessage({ (id, event, data) in
			completion(id, event, data)
		})
	}
	
	func addEventListener(_ event: String, completion:@escaping(String?, String?, String?)->()) {
		eventSource?.addEventListener(event, handler: { (id, event, data) in
			completion(id, event, data)
		})
	}
	
	func connect(lastEventId: String?) {
		eventSource?.connect(lastEventId: lastEventId)
	}
	func disconnect() {
		eventSource?.disconnect()
	}
	
	func destroy() {
		eventSource?.removeEventListener("*")
		disconnect()
		eventSource = nil
	}

}

struct ParameterConfig {
	
    let authHeader: [String:String]
    let cluster: String
}
