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
            environmentId: "",
            tlsTrustedCAs: [],
            loggerFactory: nil,
            debug: false
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
    Adds `TlsTrustedCAs`  to CfConfiguration
    - Parameter tlsTrustedCAs: Array of trusted Certificate Authority X.509 certificates (in PEM format) that will be used when connecting to the config, stream and event endpoints, you should include any intermediate CAs.
    - Note: `build()` needs to be called as the final method in the chain
    */
    public func setTlsTrustedCAs(_ tlsTrustedCAs:[String]) -> CfConfigurationBuilder {
        config.tlsTrustedCAs = tlsTrustedCAs
        return self
    }
    
    /**
    Redirect SDK logs to a custom logging framework.
     - Parameter factory: `SdkLoggerFactory`. A factory implementation that returns custom SdkLogger instances (which in turn implement trace(), debug(), info(), warn() and so on methods)
     - Note: Currently OpenAPI REST and HTTP log messages are not reported via this mechanism.
     */
    public func setSdkLoggerFactory(_ factory:SdkLoggerFactory) -> CfConfigurationBuilder {
        config.loggerFactory = factory
        return self
    }
    /**
    Enable debug/trace diagnostic messages on the internal default logger.
     - Parameter debug: true to enable additional logging. Set to `false` by default.
     - Note: Only applies to the default internal logger and has no effect if you've configured a customer logger with `setSdkLoggerFactory`.
     */
    public func setDebug(_ debug:Bool) -> CfConfigurationBuilder {
        config.debug = debug
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
