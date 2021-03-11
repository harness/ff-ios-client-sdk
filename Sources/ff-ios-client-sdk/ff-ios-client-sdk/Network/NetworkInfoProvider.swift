//
//  NetworkInfoProvider.swift
//  ff-ios-client-sdk
//
//  Created by Dusan Juranovic on 15.2.21..
//

import Foundation

protocol NetworkInfoProviderProtocol {
	func networkStatus(_ completion:@escaping(Bool)->())
	func startNotifier()
	func stopNotifier()
	var isReachable: Bool {get}
}
class NetworkInfoProvider: NetworkInfoProviderProtocol {
	private var reachability = try! Reachability()
	
	var isReachable: Bool {
		return reachability.connection != .unavailable
	}
	
	func networkStatus(_ completion:@escaping(Bool)->()) {
		reachability.whenReachable = { _ in
			completion(true)
		}
		
		reachability.whenUnreachable = { _ in
			completion(false)
		}
		
		do {
			try reachability.startNotifier()
		} catch {
			print("Unable to start notifier")
		}		
	}
	func startNotifier() {/*Only used in tests*/}
	func stopNotifier() {/*Only used in tests*/}
}
