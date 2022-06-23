iOS SDK For Harness Feature Flags
========================

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-4BC51D.svg?style=flat)](https://github.com/CocoaPods/CocoaPods)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Table of Contents
**[Intro](#Intro)**<br>
**[Requirements](#Requirements)**<br>
**[Quickstart](#Quickstart)**<br>
**[Further Reading](#Further Reading)**<br>


## Intro

Use this README to get started with our Feature Flags (FF) SDK for iOS. This guide outlines the basics of getting started with the SDK and provides a full code sample for you to try out.
This sample doesn’t include configuration options, for in depth steps and configuring the SDK, for example, disabling streaming or using our Relay Proxy, see the  [iOS SDK Reference](https://ngdocs.harness.io/article/6qt2v8g92m-ios-sdk-reference).

For a sample FF iOS SDK project, see our [test iOS project](https://github.com/drone/ff-ios-client-sample).

![FeatureFlags](https://github.com/harness/ff-java-server-sdk/raw/main/docs/images/ff-gui.png)

## Requirements

To use this SDK with [Cocoapods](https://cocoapods.org/), make sure you've installed it on your system.

To follow along with our test code sample, make sure you’ve:
- [Created a Feature Flag](https://ngdocs.harness.io/article/1j7pdkqh7j-create-a-feature-flag) on the Harness Platform called harnessappdemodarkmode
- Created a [client SDK key](https://ngdocs.harness.io/article/1j7pdkqh7j-create-a-feature-flag#step_3_create_an_sdk_key) and made a copy of it

### General Dependencies

Create a new iOS project from the Apple's XCode IDE.

### Install the SDK

Installing ff-ios-client-sdk is possible with `Swift Package Manager (SPM), CocoaPods and Carthage`

#### Swift Package Manager (SPM)

The [Swift Package Manager](https://swift.org/package-manager/) is a dependency manager integrated into the `swift` compiler and `Xcode`.

To integrate `ff-ios-client-sdk` into an Xcode project, go to the project editor, and select `Swift Packages`. From here hit the `+` button and follow the prompts using  `https://github.com/harness/ff-ios-client-sdk.git` as the URL.

To include `ff-ios-client-sdk` in a Swift package, simply add it to the dependencies section of your `Package.swift` file. And add the product `ff-ios-client-sdk` as a dependency for your targets.

```Swift
dependencies: [
	.package(url: "https://github.com/harness/ff-ios-client-sdk.git", .upToNextMinor(from: "1.0.2"))
]
```

#### CocoaPods

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
  pod 'ff-ios-client-sdk'
end
```

Only thing left to do is to install your packages by running the next command.
```Swift
$ pod install
```

*Note*: A new `.xcworkspace` will be created and you should use that, instead of your `.xcodeproj` from now on in order to utilize the imported Pods.

#### Carthage

Carthage is intended to be the simplest way to add frameworks to your Cocoa application.
Carthage builds your dependencies and provides you with binary frameworks, but you retain full control over your project structure and setup. Carthage does not automatically modify your project files or your build settings.
In order to integrate `ff-ios-client-sdk` into your app, there are a few steps to follow.
Navigate to the root folder of your project and create a `Cartfile`. This is the file where you would input all of your dependencies that you plan to use with Carthage. You can create it by entering

```Swift
$ touch Cartfile
``` 

in Terminal at your project's root folder. Once you open the `Cartfile`, you can copy/paste below line and save the changes.

```Swift
github "
/ff-ios-client-sdk"
```

Now, you need to run

```Swift
$ carthage update --no-build
```

This command will fetch the source for `ff-ios-client-sdk` from the repository specified in the `Cartfile`.

You will now have a new folder, named `Carthage` at the same location your `Cartfile` and your `.xcodeproj` are.
Within the `Carthage` folder, you will see another `Checkout` folder where the source code is located.
Next, we need to create a project for `ff-ios-client-sdk` dependency. We can do this easily by entering the following in the termial.

```Swift
// From your project's root folder
$ cd Carthage/Checkouts/ff-ios-client-sdk
```

followed by

```Swift
$ swift package generate-xcodeproj
```

... or, you can enter it all on the same line.

```Swift
//From your project's root folder
$ cd Carthage/Checkouts/ff-ios-client-sdk && swift package generate-xcodeproj
```

Go back into your project's root folder and enter the next command:

```Swift
$ carthage build --use-xcframeworks --platform iOS
```

This command will build the project and place it in the `Build` folder next to `Checkouts`.
On your application targets’ `General` settings tab, in the `Frameworks, Libraries, and Embedded Content` section, drag and drop the `.xcframework` file from the `Carthage/Build` folder. In the `"Embed"` section, select `"Embed & Sign"`.

Only thing left to do is:

```Swift
import ff_ios_client_sdk
```

... wherever you need to use `ff-ios-client-sdk`

When a new version of `ff-ios-client-sdk` is available and you wish to update this dependency, run

```Swift
$ carthage update --use-xcframeworks --platform iOS
```

And your embedded library will be updated.

## Quickstart

Here is a complete example that will connect to the feature flag service and report the flag value every 10 seconds.
Any time a flag is toggled from the feature flag service you will receive the updated value.

After several iterations the SDK will be safely terminated.

*Note:* Don't forget to update: `apiKey: "YOUR_API_KEY"` with your SDK API key value!

```Swift
import UIKit

import ff_ios_client_sdk

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let config = CfConfiguration.builder()
                .setStreamEnabled(true)
                .setAnalyticsEnabled(true)
                .build()

        let target = CfTarget.builder()
                .setName("Hello")
                .setIdentifier("Hello")
                .build()

        CfClient.sharedInstance.initialize(

                apiKey: "YOUR_API_KEY",
                configuration: config,
                target: target

        ) { [weak self] result in

            switch result {

            case .failure(let error):

                NSLog("End: Error \(error)")

            case .success():

                NSLog("Init: Ok")

                CfClient.sharedInstance.registerEventsListener() { (result) in

                    switch result {

                    case .failure(let error):
                        print(error)

                    case .success(let eventType):
                        switch eventType {

                        case .onPolling:
                            print("Event: Received all evaluation flags")

                        case .onEventListener(let evaluation):
                            print("Event: Received an evaluation flag, \(evaluation!)")

                        case .onComplete:
                            print("Event: SSE stream has completed")

                        case .onOpen:
                            print("Event: SSE stream has been opened")

                        case .onMessage(let messageObj):
                            print(messageObj?.event ?? "Event: Message received")
                        }
                    }
                }
            }
        }

        let serialQueue = DispatchQueue(label: "serialQueue")

        serialQueue.async {

            var count = 0

            while(count < 10) {

                count += 1

                Thread.sleep(forTimeInterval: 10)

                CfClient.sharedInstance.boolVariation(evaluationId: "harnessappdemodarkmode", { (eval) in

                    print("LOOP :: Flag value: \(eval!)")
                })
            }

            CfClient.sharedInstance.destroy()
        }
    }
}

```

### Running the example

Make sure that you chose as the target device newer iOS device such as: iPhone 12.
Then chose: Product > Build for > Running.
After building is completed click on the run button to start the emualtor and run the application.

## Further Reading

Further examples and config options are in the further reading section:

[Further Reading](FURTHER.md)

-------------------------

[Harness](https://www.harness.io/) is a feature management platform that helps teams to build better software and to
test features quicker.

-------------------------