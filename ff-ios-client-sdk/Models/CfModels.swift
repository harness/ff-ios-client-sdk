//
//  CFModels.swift
//  CFiOSClient
//
//  Created by Dusan Juranovic on 13.1.21..
//

import Foundation

public struct Message: Codable {
	public var event: String?
	public var domain: String?
	public var identifier: String?
	public var version: Double?
}

public struct CFErrorMessage: Codable {
	public var message: String?
}

public struct DummyData: Codable {
	public var data: DummyFlag
}

public struct DummyFlag: Codable {
	public var flag_id: String
	public var flag_value: String
}


