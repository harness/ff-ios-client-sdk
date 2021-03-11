//
//  CfTargetBuilder.swift
//  ff-ios-client-sdk
//
//  Created by Dusan Juranovic on 9.3.21..
//

import Foundation

public class CfTargetBuilder {
	var target: CfTarget!
	
	public init(){
		self.target = CfTarget(identifier: "",
							   name: "",
							   anonymous: false,
							   attributes: [:])
	}
	/**
	Adds `identifier` to CfTarget
	- Parameter identifier: `String`
	- Note: `build()` needs to be called as the final method in the chain
	*/
	public func setIdentifier(_ identifier: String) -> CfTargetBuilder {
		target.identifier = identifier
		return self
	}
	/**
	Adds `name` to CfTarget
	- Parameter name: `String`
	- Note: `build()` needs to be called as the final method in the chain
	*/
	public func setName(_ name: String) -> CfTargetBuilder {
		target.name = name
		return self
	}
	/**
	Adds `anonymous` flag  to CfTarget
	- Parameter anonymous: `Bool`
	- Note: `build()` needs to be called as the final method in the chain
	*/
	public func setAnonymous(_ anonymous: Bool) -> CfTargetBuilder {
		target.anonymous = anonymous
		return self
	}
	/**
	Adds `attributes` flag  to CfTarget
	- Parameter attributes: `[String:String]`
	- Note: `build()` needs to be called as the final method in the chain
	*/
	public func setAttributes(_ attributes: [String:String]) -> CfTargetBuilder {
		target.attributes = attributes
		return self
	}
	/**
	Builds CfTarget object by providing components or is set to default component/s.
	- `setIdentifier(_:)`
	- `setName(_:)`
	- `setAnonymous(_:)`
	- `setAttributes(_:)`
	
	# Defaults: #
	- `identifier`:  ""
	- `name`:  `nil`
	- `anonymous`: `nil`
	- `attributes`:  `nil`
	*/
	public func build() -> CfTarget {
		return target
	}
}
