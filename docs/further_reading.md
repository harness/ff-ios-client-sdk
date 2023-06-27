# Further Reading

## **Initialization**
1. Setup your configuration by calling `CfConfiguration`'s static method `builder()` and pass-in your prefered configuration settings through possible chaining methods. The chaining needs to be ended with `build()` method. (See the `build()`'s description for possible chaining methods and their default values.)
2. Setup your target by calling `CfTarget`'s static method `builder()` and pass-in your prefered target settings through possible chaining methods. The chaining needs to be ended with `build()` method. (See the `build()`'s description for possible chaining methods and their default values). Target's `identifier` is mandatory and represents the `Account` from which you wish to receive evaluations.

2. Call `CfClient.sharedInstance.initialize(apiKey:configuration:target:cache:onCompletion:)` and pass in your Harness CF `apiKey`, previously created configuration object, target and an optional cache object adopting `StorageRepositoryProtocol`.

	If `cache` object is omitted, internal built-in cache will be used. You can also omitt `onCompletion` parameter if you don't need initialization/authorization information.

**Your `ff-ios-client-sdk` is now initialized. Congratulations!!!**

&nbsp;
Upon successful initialization and authorization, the completion block of `CfClient.sharedInstance.initialize(apiKey:configuration:target:cache:onCompletion:)` will deliver `Swift.Result<Void, CFError>` object. You can then switch through it's `.success(Void)` and `.failure(CFError)` cases and decide on further steps depending on a result.

&nbsp;
### <u>_initialize(apiKey:configuration:cache:onCompletion:)_</u>
```Swift
let configuration = CfConfiguration.builder().setStreamEnabled(true).build()
let target = CfTarget.builder().setIdentifier("YOUR_ACCOUNT_IDENTIFIER").build()
CfClient.sharedInstance.initialize(apiKey: "YOUR_API_KEY", configuration: configuration, target: target) { (result) in
	switch result {
		case .failure(let error):
			//Do something to gracefully handle initialization/authorization failure
		case .success:
			//Continue to the next step after successful initialization/authorization
	}
}
```

## **Implementation**
The Public API exposes few methods that you can utilize:
Please note that all of the below methods are called on `CfClient.sharedInstance`

* `public func initialize(apiKey:configuration:target:cache:onCompletion:)` -> Called first as described above in the **_initialization_** section. `(Mandatory)`

* `public func registerEventsListener(events:onCompletion:)` -> Called in the ViewController where you would like to receive the events. `(Mandatory)`

* `public func destroy()`

	### Fetching from cache methods
	---
* `public func stringVariation(evaluationId:defaultValue:completion:)`

* `public func boolVariation(evaluationId:defaultValue:completion:)`

* `public func numberVariation(evaluationId:defaultValue:completion:)`

* `public func jsonVariation(evaluationId:defaultValue:completion:)`

&nbsp;
### <u>_registerEventsListener(events:onCompletion:)_</u>
`events` is an array of events that you would like to subscribe to. It defaults to `*`, which means ALL events.
In order to be notified of the SSE events sent from the server, you need to call `CfClient.sharedInstance.registerEventsListener()` method.

<u style="color:red">**NOTE**</u>: Registering to events is usually done in `viewDidLoad()` method when events are required in only one ViewController _OR_ `viewDidAppear()` if there are more than one registration calls throughout the app, so the events could be re-registered for the currently visible ViewController.

The completion block of this method will deliver `Swift.Result<EventType, CFError>` object. You can use `switch` statement within it's `.success(EventType)` case to distinguish which event has been received and act accordingly as in the example below or handle the error gracefully from it's `.failure(CFError)` case.
```Swift
CfClient.sharedInstance.registerEventsListener() { (result) in
	switch result {
		case .failure(let error):
			//Gracefully handle error
		case .success(let eventType):
			switch eventType {
				case .onPolling(let evaluations):
					//Received all evaluation flags -> [Evaluation]
				case .onEventListener(let evaluation):
					//Received an evaluation flag -> Evaluation
				case .onComplete:
					//Received a completion event, meaning that the
					//SSE has been disconnected
				case .onOpen(_):
					//SSE connection has been established and is active
				case .onMessage(let messageObj):
					//An empty Message object has been received
			}
		}
	}
}
```
## Fetching from cache methods
The following methods can be used to fetch an Evaluation from cache, by it's known key. Completion handler delivers `Evaluation` result. If `defaultValue` is specified, it will be returned if key does not exist. If `defaultValue` is omitted, `nil` will be delivered in the completion block. Fetching is done for specified target identifier during initialize() call.

Use appropriate method to fetch the desired Evaluation of a certain type.
### <u>_stringVariation(forKey:defaultValue:completion:)_</u>
```Swift
CfClient.sharedInstance.stringVariation("your_evaluation_id", defaultValue: String?) { (evaluation) in
	//Make use of the fetched `String` Evaluation
}
```
### <u>_boolVariation(forKey:defaultValue:completion:)_</u>
```Swift
CfClient.sharedInstance.boolVariation("your_evaluation_id", defaultValue: Bool?) { (evaluation) in
	//Make use of the fetched `Bool` Evaluation
}
```
### <u>_numberVariation(forKey:defaultValue:completion:)_</u>
```Swift
CfClient.sharedInstance.numberVariation("your_evaluation_id", defaultValue: Int?) { (evaluation) in
	//Make use of the fetched `Int` Evaluation
}
```
### <u>_jsonVariation(forKey:defaultValue:completion:)_</u>
```Swift
CfClient.sharedInstance.jsonVariation("your_evaluation_id", defaultValue: [String:ValueType]?) { (evaluation) in
	//Make use of the fetched `[String:ValueType]` Evaluation
}
```
`ValueType` can be one of the following:

* `ValueType.bool(Bool)`
* `ValueType.string(String)`
* `ValueType.int(Int)`
* `ValueType.object([String:ValueType])`


## Custom Loggers
The SDK comes with a basic default logger that logs to info level via [os_log()](https://developer.apple.com/documentation/os/os_log). You can configure debug and trace logs to be shown as
well by setting `setDebug(true)` on the configuration builder. However if you need more control over logs or have your own logging system you can integrate with that system by providing
a factory class which instantiates logger instances. The example below uses Apple's [swift-log](https://github.com/apple/swift-log) you can use any framework you want.



```Swift
import Logging

class SwiftLogLogger : SdkLogger {
    var logger:Logger

    init( label:String) {
        logger = Logger(label: label)
        logger.logLevel = .trace
    }

    func trace(_ msg: String) {
        logger.trace("🔍 \(msg)")
    }

    func debug(_ msg: String) {
        logger.debug("📗 \(msg)")
    }

    func info(_ msg: String) {
        logger.info("📘 \(msg)")
    }

    func warn(_ msg: String) {
        logger.warning("📕 \(msg)")
    }

    func error(_ msg: String) {
        logger.error("💥 \(msg)")
    }
}

class SwiftLogSdkLoggerFactory : SdkLoggerFactory {
    func createSdkLogger(_ label: String) -> ff_ios_client_sdk.SdkLogger {
        return SwiftLogLogger(label: label)
    }
}

let config = CfConfiguration.builder()
    .setStreamEnabled(true)
    .setAnalyticsEnabled(true)
    .setSdkLoggerFactory(SwiftLogSdkLoggerFactory())
    .build()

```

**_NOTE:_** Currently only messages originating from the main SDK code are logged. HTTP log messages generated by OpenAPI are not redirected.


## Shutting down the SDK
### <u>_destroy()_</u>
To avoid potential memory leak, when SDK is no longer needed (when the app is closed, for example), a caller should call this method.
Also, you need to call this method when changing accounts through `CfTarget` object, in order to re-initialize and fetch Evaluations for the right account.
```Swift
CfClient.sharedInstance.destroy()
```