import Foundation

/// `CfConfiguration` is `required` in order to [intialize](x-source-tag://initialize) the SDK.
/// # Defaults: #
/// - `configUrl`:  "https://config.ff.harness.io/api/1.0"
/// - `eventUrl`:  "https://config.ff.harness.io/api/1.0/stream"
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
    var bufferSize: Int
	
	internal init(
        
        configUrl: String,
        eventUrl: String,
        streamEnabled: Bool,
        analyticsEnabled: Bool,
        bufferSize: Int,
        pollingInterval:TimeInterval,
        environmentId: String
        
    ) {
		
        self.configUrl = configUrl
		self.eventUrl = eventUrl
		self.streamEnabled = streamEnabled
		self.analyticsEnabled = analyticsEnabled
        self.bufferSize = bufferSize
		self.pollingInterval = pollingInterval
		self.environmentId = environmentId
	}
	
	public static func builder() -> CfConfigurationBuilder {
		
        return CfConfigurationBuilder()
	}
}

