//
//  Logger.swift
//  CFiOSClient
//
//  Created by Dusan Juranovic on 11.2.21..
//

import Foundation

struct Logger {
	static var logsEnabled = true
	static func log(_ string:String, spaceBelow:Int? = 1, enabled:Bool? = true) {
		if logsEnabled {
			if enabled! {
				let date = "\(Date.time()) -> "
				let dash = String(repeating: "-", count: string.count + date.count)
				let lowerSpace = String(repeating: "\n", count: spaceBelow!)
				print ("""
			       \(dash)
			       \(date)\(string)
			       \(dash)\(lowerSpace)
			       """)
			}
		}
	}
}

fileprivate extension Date {
	static func time() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm:ss"
		let date = dateFormatter.string(from: Date())
		return date
	}
}
