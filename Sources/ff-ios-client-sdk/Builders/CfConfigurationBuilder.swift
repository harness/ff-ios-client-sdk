//
//  CfConfigurationBuilder.swift
//  ff-ios-client-sdk
//
//  Created by Dusan Juranovic on 19.1.21..
//

import Foundation

public class CfConfigurationBuilder {
	
    var config : CfConfiguration!
	private let minimumPollingInterval:TimeInterval = 60
	
	public init(){
		
        self.config = CfConfiguration(
            
            configUrl: CfConstants.Server.configUrl,
            streamUrl: CfConstants.Server.streamUrl,
            eventUrl:  CfConstants.Server.eventUrl,
            streamEnabled: false,
            analyticsEnabled: true,
            pollingInterval: minimumPollingInterval,
            environmentId: ""
        )
	}
	/**
	Adds `configUrl` to CfConfiguration
	- Parameter configUrl: `String`
	- Note: `build()` needs to be called as the final method in the chain
	*/
	public func setConfigUrl(_ configUrl: String) -> CfConfigurationBuilder {
		config.configUrl = configUrl
		return self
	}
	
    /**
	Adds `streamUrl` to CfConfiguration
	- Parameter streamUrl: `String`
	- Note: `build()` needs to be called as the final method in the chain
	*/
	public func setStreamUrl(_ streamUrl: String) -> CfConfigurationBuilder {
		
        config.streamUrl = streamUrl
		return self
	}
    
    /**
    Adds `eventUrl` to CfConfiguration
    - Parameter eventUrl: `String`
    - Note: `build()` needs to be called as the final method in the chain
    */
    public func setEventUrl(_ eventUrl: String) -> CfConfigurationBuilder {
        
        config.eventUrl = eventUrl
        return self
    }
    
	/**
	Adds `streamEnabled` flag  to CfConfiguration
	- Parameter isEnabled: `Bool`
	- Note: `build()` needs to be called as the final method in the chain
	*/
	public func setStreamEnabled(_ isEnabled: Bool) -> CfConfigurationBuilder {
		config.streamEnabled = isEnabled
		return self
	}
	/**
	Adds `analyticsEnabled` flag  to CfConfiguration
	- Parameter isEnabled: `Bool`
	- Note: `build()` needs to be called as the final method in the chain
	*/
	public func setAnalyticsEnabled(_ isEnabled: Bool) -> CfConfigurationBuilder {
		config.analyticsEnabled = isEnabled
		return self
	}
	/**
	Adds `pollingInterval`  to CfConfiguration
	- Parameter interval: `TimeInterval`. Minimum 60 seconds.
	- Note: `build()` needs to be called as the final method in the chain
	*/
	public func setPollingInterval(_ interval: TimeInterval) -> CfConfigurationBuilder {
		config.pollingInterval = interval < minimumPollingInterval ? minimumPollingInterval : interval
		return self
	}
	/**
	Builds CfConfiguration object by providing components or is set to default component/s.
	- `setConfigUrl(_:)`
	- `setEventUrl(_:)`
	- `setStreamEnabled(_:)`
	- `setAnalyticsEnabled(_:)`
	- `setPollingInterval(_:)`
	
	# Defaults: #
	- `configUrl`:  "https://config.ff.harness.io/api/1.0"
    - `eventUrl`: "https://events.ff.harness.io/api/1.0"
	- `streamUrl`:  "https://config.ff.harness.io/api/1.0/stream"
	- `streamEnabled`: `false`
	- `analyticsEnabled`: `true`
	- `pollingInterval`: `60` seconds
	*/
	public func build() -> CfConfiguration {
		return config
	}
}
