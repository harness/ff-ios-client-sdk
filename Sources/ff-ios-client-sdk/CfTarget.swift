//
//  CfTarget.swift
//  ff-ios-client-sdk
//
//  Created by Dusan Juranovic on 9.3.21..
//

import Foundation

/// `CfTarget` is `required` in order to [intialize](x-source-tag://initialize) the SDK.
/// # Defaults: #
/// - `identifier`:  ""
/// - `name`:  ""
/// - `anonymous`: `false`
/// - `attributes`: `[:]`
public struct CfTarget: Codable, Hashable {
	
    public var identifier: String
	public var name: String
	public var anonymous: Bool
	public var attributes: [String:String]
	
	public static func builder() -> CfTargetBuilder {
		
        return CfTargetBuilder()
	}
    
    func isValid() -> Bool {
        
        return !identifier.isEmpty
    }
}
