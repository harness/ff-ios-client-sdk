# ff-ios-client-sdk overview

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-4BC51D.svg?style=flat)](https://github.com/CocoaPods/CocoaPods)

---
[Harness](https://www.harness.io/) is a feature management platform that helps teams to build better software and to test features quicker.
&nbsp;
# _Installing the `ff-ios-client-sdk`_
Installing ff-ios-client-sdk is possible with `Swift Package Manager (SPM) & CocoaPods`

TO BE ADDED: `Carthage`

&nbsp;
## <u>_Swift Package Manager (SPM)_</u>
The [Swift Package Manager](https://swift.org/package-manager/) is a dependency manager integrated into the `swift` compiler and `Xcode`.

To integrate `ff-ios-client-sdk` into an Xcode project, go to the project editor, and select `Swift Packages`. From here hit the `+` button and follow the prompts using  `https://github.com/wings-software/ff-ios-client-sdk.git` as the URL.

To include `ff-ios-client-sdk` in a Swift package, simply add it to the dependencies section of your `Package.swift` file. And add the product "HarnessSDKiOS" as a dependency for your targets.

```Swift
dependencies: [
	.package(url: "https://github.com/drone/ff-ios-client-sdk.git", .upToNextMinor(from: "0.0.1"))
]
```
&nbsp;
## <u>_CocoaPods_</u>
The [CocoaPods](https://cocoapods.org//) CocoaPods is a dependency manager for Swift and Objective-C Cocoa projects. It has over 81 thousand libraries and is used in over 3 million apps. CocoaPods can help you scale your projects elegantly.

CocoaPods is built with Ruby and it will be installable with the default Ruby available on macOS. You can use a Ruby Version manager, however we recommend that you use the standard Ruby available on macOS unless you know what you're doing.

Using the default Ruby install will require you to use sudo when installing gems. (This is only an issue for the duration of the gem installation, though.)
```Swift
$ sudo gem install cocoapods
```

Once cocoapods are installed, from your root project folder, create a `Podfile`, which will be located in your project's root folder, by entering the next command in your terminal:
```Swift
$ pod init
```

To import `ff-ios-client-sdk` to your `.xcproject`, simply add `ff-ios-client-sdk` to your newly created Podfile and save the Podfile changes.
```Swift
platform :ios, '10.0'
use_frameworks!

target 'MyApp' do
  pod 'ff-ios-client-sdk', '~> 0.0.1'
end
```

Only thing left to do is to install your packages by running the next command.
```Swift
$ pod install
```
NOTE: A new `.xcworkspace` will be created and you should use that, instead of your `.xcodeproj` from now on in order to utilize the imported Pods.

&nbsp;
## <u>_Carthage -> TO BE ADDED_</u>

&nbsp;
# _Using the `ff-ios-client-sdk`_

In order to use `ff-ios-client-sdk` in your application, there are a few steps that you would need to take.

## **_Initialization_**
1. Setup your configuration by calling `CfConfiguration`'s static method `builder()` and pass-in your prefered configuration settings through possible chaining methods. The chaining needs to be ended with `build()` method. (See the `build()`'s description for possible chaining methods and their default values.)

2. Call `CfClient.sharedInstance.initialize(apiKey:configuration:cache:onCompletion:)` and pass in your Harness CF `apiKey`, previously created configuration object and an optional cache object adopting `StorageRepositoryProtocol`.
	
	If `cache` object is omitted, internal built-in cache will be used. You can also omitt `onCompletion` parameter if you don't need initialization/authorization information. 

**Your `ff-ios-client-sdk` is now initialized. Congratulations!!!**

&nbsp;
Upon successful initialization and authorization, the completion block of `CfClient.sharedInstance.initialize(apiKey:configuration:cache:onCompletion:)` will deliver `Swift.Result<Void, CFError>` object. You can then switch through it's `.success(Void)` and `.failure(CFError)` cases and decide on further steps depending on a result.

&nbsp;
### <u>_initialize(apiKey:configuration:cache:onCompletion:)_</u>
```Swift
let configuration = CfConfiguration.builder().setStreamEnabled(true).setTarget("Your_Account_Identifier").build()
CfClient.sharedInstance.initialize(apiKey: "YOUR_API_KEY", configuration: configuration) { (result) in
	switch result {
		case .failure(let error):
			//Do something to gracefully handle initialization/authorization failure
		case .success:
			//Continue to the next step after successful initialization/authorization  
	}
}
```
&nbsp;
## **_Implementation_**
The Public API exposes few methods that you can utilize:
Please note that all of the below methods are called on `CfClient.sharedInstance`

* `public func initialize(apiKey:configuration:cache:onCompletion:)` -> Called first as described above in the **_initialization_** section. `(Mandatory)`

* `public func registerEventsListener(events:onCompletion:)` -> Called in the ViewController where you would like to receive the events. `(Mandatory)`

* `public func destroy()`

	### Fetching from cache methods
	---
* `public func stringVariation(evaluationId:target:defaultValue:completion:)`

* `public func boolVariation(evaluationId:target:defaultValue:completion:)`

* `public func numberVariation(evaluationId:target:defaultValue:completion:)`

* `public func jsonVariation(evaluationId:target:defaultValue:completion:)`

&nbsp;
### <u>_registerEventsListener(events:onCompletion:)_</u>
`events` is an array of events that you would like to subscribe to. It defaults to `*`, which means ALL events. 
In order to be notified of the SSE events sent from the server, you need to call `CfClient.sharedInstance.registerEventsListener()` method 

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
## _Fetching from cache methods_
The following methods can be used to fetch an Evaluation from cache, by it's known key. Completion handler delivers `Evaluation` result. If `defaultValue` is specified, it will be returned if key does not exist. If `defaultValue` is omitted, `nil` will be delivered in the completion block. 

Use appropriate method to fetch the desired Evaluation of a certain type.
### <u>_stringVariation(forKey:target:defaultValue:completion:)_</u>
```Swift
CfClient.sharedInstance.stringVariation("your_evaluation_id", defaultValue: String?) { (evaluation) in
	//Make use of the fetched `String` Evaluation
}
```
### <u>_boolVariation(forKey:target:defaultValue:completion:)_</u>
```Swift
CfClient.sharedInstance.boolVariation("your_evaluation_id", defaultValue: Bool?) { (evaluation) in
	//Make use of the fetched `Bool` Evaluation
}
```
### <u>_numberVariation(forKey:target:defaultValue:completion:)_</u>
```Swift
CfClient.sharedInstance.numberVariation("your_evaluation_id", defaultValue: Int?) { (evaluation) in
	//Make use of the fetched `Int` Evaluation
}
```
### <u>_jsonVariation(forKey:target:defaultValue:completion:)_</u>
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

## _Shutting down the SDK_
### <u>_destroy()_</u>
To avoid potential memory leak, when SDK is no longer needed (when the app is closed, for example), a caller should call this method.
```Swift
CfClient.sharedInstance.destroy() 
```
