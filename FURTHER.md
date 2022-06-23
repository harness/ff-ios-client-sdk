# Further Reading

Covers advanced topics (different config options and scenarios)

## Configuration Options

The following configuration options are available to control the behaviour of the SDK.
You can configure the URLs used to connect to Harness.

```Swift
// Configure:
let config = CfConfiguration.builder()
        .setStreamEnabled(true)
        .setAnalyticsEnabled(true)
        .setPollingInterval(60)
        .setEventUrl("https://event.ff.harness.io/api/1.0")
        .setConfigUrl("https://config.ff.harness.io/api/1.0")
        .setStreamUrl("https://config.ff.harness.io/api/1.0/stream")
        .build()

// Initialize:
CfClient.sharedInstance.initialize(

        apiKey: "YOUR_API_KEY",
        configuration: config,
        target: target

) { [weak self] result in

    // ...
}
```

| Name            | Config Option                                                | Description                                                                    | default                                     |
|-----------------|--------------------------------------------------------------|--------------------------------------------------------------------------------|---------------------------------------------|
| baseUrl         | setConfigUrl("https://config.ff.harness.io/api/1.0")         | the URL used to fetch feature flag evaluations.                                | https://config.ff.harness.io/api/1.0        |
| eventsUrl       | setEventUrl("https://event.ff.harness.io/api/1.0"),          | the URL used to post metrics data to the feature flag service.                 | https://events.ff.harness.io/api/1.0        |
| streamUrl       | setStreamUrl("https://config.ff.harness.io/api/1.0/stream"), | the URL used to connect to SSE.                                                | https://config.ff.harness.io/api/1.0/stream |
| pollInterval    | setPollingInterval(60)                                       | when running in stream mode, the interval in seconds that we poll for changes. | 60                                          |
| enableStream    | setStreamEnabled(true)                                       | Enable streaming mode.                                                         | true                                        |
| enableAnalytics | setAnalyticsEnabled(true)                                    | Enable analytics.  Metrics data is posted every 60s                            | true                                        |

## Initialization

- Setup your configuration by calling `CfConfiguration`'s static method `builder()` and pass-in your prefered configuration settings through possible chaining methods. The chaining needs to be ended with `build()` method. (See the `build()`'s description for possible chaining methods and their default values.)
- Setup your target by calling `CfTarget`'s static method `builder()` and pass-in your preferred target settings through possible chaining methods. The chaining needs to be ended with `build()` method. (See the `build()`'s description for possible chaining methods and their default values). Target's `identifier` is mandatory and represents the `Account` from which you wish to receive evaluations.
- Call `CfClient.sharedInstance.initialize(apiKey:configuration:target:cache:onCompletion:)` and pass in your Harness CF `apiKey`, previously created configuration object, target and an optional cache object adopting `StorageRepositoryProtocol`.
If `cache` object is omitted, internal built-in cache will be used. You can also omitt `onCompletion` parameter if you don't need initialization/authorization information.

**Your `ff-ios-client-sdk` is now initialized. Congratulations!!!**

Upon successful initialization and authorization, the completion block of `CfClient.sharedInstance.initialize(apiKey:configuration:target:cache:onCompletion:)` will deliver `Swift.Result<Void, CFError>` object. You can then switch through it's `.success(Void)` and `.failure(CFError)` cases and decide on further steps depending on a result.

### initialize(apiKey:configuration:cache:onCompletion:)

```Swift

let configuration = CfConfiguration.builder().setStreamEnabled(true).build()
let target = CfTarget.builder().setName("Name").setIdentifier("Identifier").build()

CfClient.sharedInstance.initialize(apiKey: "YOUR_API_KEY", configuration: configuration, target: target) { (result) in
	switch result {
		case .failure(let error):
			// Do something to gracefully handle initialization/authorization failure
		case .success:
			// Continue to the next step after successful initialization/authorization  
	}
}
```

## Implementation

The Public API exposes few methods that you can utilize:
Please note that all of the below methods are called on `CfClient.sharedInstance`

* `public func initialize(apiKey:configuration:target:cache:onCompletion:)` -> Called first as described above in the **_initialization_** section. `(Mandatory)`

* `public func registerEventsListener(events:onCompletion:)` -> Called in the ViewController where you would like to receive the events. `(Mandatory)`

* `public func destroy()`

### Fetching from cache methods

* `public func stringVariation(evaluationId:defaultValue:completion:)`

* `public func boolVariation(evaluationId:defaultValue:completion:)`

* `public func numberVariation(evaluationId:defaultValue:completion:)`

* `public func jsonVariation(evaluationId:defaultValue:completion:)`

### registerEventsListener(events:onCompletion:)

`events` is an array of events that you would like to subscribe to. It defaults to `*`, which means ALL events.
In order to be notified of the SSE events sent from the server, you need to call `CfClient.sharedInstance.registerEventsListener()` method

*Note:* Registering to events is usually done in `viewDidLoad()` method when events are required in only one ViewController _OR_ `viewDidAppear()` if there are more than one registration calls throughout the app, so the events could be re-registered for the currently visible ViewController.

The completion block of this method will deliver `Swift.Result<EventType, CFError>` object. You can use `switch` statement within it's `.success(EventType)` case to distinguish which event has been received and act accordingly as in the example below or handle the error gracefully from it's `.failure(CFError)` case.

```Swift
CfClient.sharedInstance.registerEventsListener() { (result) in
	switch result {
		case .failure(let error):
			// Gracefully handle error
		case .success(let eventType):
			switch eventType {
				case .onPolling(let evaluations):
					// Received all evaluation flags -> [Evaluation]
				case .onEventListener(let evaluation):
					// Received an evaluation flag -> Evaluation
				case .onComplete:
					// Received a completion event, meaning that the 
					// SSE has been disconnected
				case .onOpen(_):
					// SSE connection has been established and is active
				case .onMessage(let messageObj):
					// An empty Message object has been received
			}
		}
	}
}
```

## Fetching from cache methods

The following methods can be used to fetch an Evaluation from cache, by it's known key. Completion handler delivers `Evaluation` result. If `defaultValue` is specified, it will be returned if key does not exist. If `defaultValue` is omitted, `nil` will be delivered in the completion block. Fetching is done for specified target identifier during initialize() call.

Use appropriate method to fetch the desired Evaluation of a certain type.

### stringVariation(forKey:defaultValue:completion:)

```Swift
CfClient.sharedInstance.stringVariation("your_evaluation_id", defaultValue: String?) { (evaluation) in
	//Make use of the fetched `String` Evaluation
}
```

### boolVariation(forKey:defaultValue:completion:)

```Swift
CfClient.sharedInstance.boolVariation("your_evaluation_id", defaultValue: Bool?) { (evaluation) in
	//Make use of the fetched `Bool` Evaluation
}
```

### numberVariation(forKey:defaultValue:completion:)

```Swift
CfClient.sharedInstance.numberVariation("your_evaluation_id", defaultValue: Int?) { (evaluation) in
	//Make use of the fetched `Int` Evaluation
}
```

### jsonVariation(forKey:defaultValue:completion:)

```Swift
CfClient.sharedInstance.jsonVariation("your_evaluation_id", defaultValue: [String:ValueType]?) { (evaluation) in
	//Make use of the fetched `[String:ValueType]` Evaluation
}
```

The `ValueType` can be one of the following:

* `ValueType.bool(Bool)`
* `ValueType.string(String)`
* `ValueType.int(Int)`
* `ValueType.object([String:ValueType])`

## Recommended reading

[Feature Flag Concepts](https://ngdocs.harness.io/article/7n9433hkc0-cf-feature-flag-overview)

[Feature Flag SDK Concepts](https://ngdocs.harness.io/article/rvqprvbq8f-client-side-and-server-side-sdks)

## Setting up your Feature Flags

[Feature Flags Getting Started](https://ngdocs.harness.io/article/0a2u2ppp8s-getting-started-with-feature-flags)

## Variation types examples

### Bool Variation

```Swift
CfClient.sharedInstance.boolVariation(evaluationId: "sample_bool_flag", { (eval) in

    print("LOOP :: Boolean flag value: \(eval!)")
})
```

### Number Variation

```Swift
CfClient.sharedInstance.numberVariation(evaluationId: "sample_number_flag", { (eval) in
                                                                           
    print("LOOP :: Number flag value: \(eval!)")
})
```

### String Variation

```Swift
CfClient.sharedInstance.stringVariation(evaluationId: "sample_string_flag", { (eval) in

    print("LOOP :: String flag value: \(eval!)")
})
```

### JSON Variation

```Swift
CfClient.sharedInstance.jsonVariation(evaluationId: "sample_json_flag", { (eval) in

    print("LOOP :: JSON flag value: \(eval!)")
})
```

## Cleanup

To avoid potential memory leak, when SDK is no longer needed
(when the app is closed, for example), a caller should call this method:

```Swift
CfClient.sharedInstance.destroy()
```

Also, you need to call this method when changing accounts through `CfTarget` object, in order to re-initialize and fetch Evaluations for the right account.


