//
//  CfConfiguration.swift
//  ff-ios-client-sdk
//
//  Created by Dusan Juranovic on 13.1.21..
//

import Foundation

/// `CfConfiguration` is `required` in order to [intialize](x-source-tag://initialize) the SDK.
/// # Defaults: #
/// - `configUrl`:  "https://config.feature-flags.uat.harness.io/api/1.0"
/// - `eventUrl`:  "https://event.feature-flags.uat.harness.io/api/1.0"
/// - `streamEnabled`: `false`
/// - `analyticsEnabled`: `true`
/// - `pollingInterval`: `60` seconds
public struct CfConfiguration {
	var configUrl: String
	var eventUrl: String
	var streamEnabled: Bool
	var analyticsEnabled: Bool
	var pollingInterval: TimeInterval
	var environmentId: String
	
	internal init(configUrl: String, eventUrl: String, streamEnabled: Bool, analyticsEnabled: Bool, pollingInterval:TimeInterval, environmentId: String) {
		self.configUrl = configUrl
		self.eventUrl = eventUrl
		self.streamEnabled = streamEnabled
		self.analyticsEnabled = analyticsEnabled
		self.pollingInterval = pollingInterval
		self.environmentId = environmentId
	}
	
	public static func builder() -> CfConfigurationBuilder {
		return CfConfigurationBuilder()
	}
}

