//
//  CFConfiguration.swift
//  CFiOSClient
//
//  Created by Dusan Juranovic on 13.1.21..
//

import Foundation

/// `CFConfiguration` is `required` in order to initialize the SDK.
/// # Defaults: #
/// - `baseUrl`:  "https://config.feature-flags.uat.harness.io/api/1.0"
/// - `streamEnabled`: `false`
/// - `pollingInterval`: `60` seconds
/// - `target`: `""`
public struct CFConfiguration {
	var baseUrl: String
	var streamEnabled: Bool
	var pollingInterval: TimeInterval
	var environmentId: String
	var target: String
	
	internal init(baseUrl: String, streamEnabled: Bool, pollingInterval:TimeInterval, environmentId: String, target: String) {
		self.baseUrl = baseUrl
		self.streamEnabled = streamEnabled
		self.pollingInterval = pollingInterval
		self.environmentId = environmentId
		self.target = target
	}
	
	public static func builder() -> CFConfigurationBuilder {
		return CFConfigurationBuilder()
	}
}

