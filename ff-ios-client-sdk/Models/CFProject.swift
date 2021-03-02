//
//  CFProject.swift
//  CFiOSClient
//
//  Created by Dusan Juranovic on 14.1.21..
//

import Foundation

@objc public class CFProject:NSObject, Codable {
	public var projectIdentifier: String
	public var organization: String
	public var project: String
	public var environmentIdentifier: String
	public var environment: String
	public var accountID: String
	
	public init(dict:[String:Any]) {
		self.projectIdentifier = 	 dict["projectIdentifier"] as! String
		self.organization = 	 	 dict["organization"] as! String
		self.project = 			 	 dict["project"] as! String
		self.environmentIdentifier = dict["environmentIdentifier"] as! String
		self.environment = 			 dict["environment"] as! String
		self.accountID = 			 dict["accountID"] as! String
		
	}
}

