# iOS SDK For Harness Feature Flags

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-4BC51D.svg?style=flat)](https://github.com/CocoaPods/CocoaPods)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

---
Use this README to get started with our Feature Flags (FF) SDK for iOS. This guide outlines the basics of getting started with the SDK and provides a full code sample for your to try out.

This sample doesn't include configuration options, for in depth steps and configuring the SDK, for example, disabling streaming or using our Relay Proxy, see the [iOS SDK Reference](https://ngdocs.harness.io/article/6qt2v8g92m-ios-sdk-reference).


For a sample FF iOS SDK project, see [our test iOS project](https://github.com/drone/ff-ios-client-sample).

## Requirements
To use this SDK, make sure you've:
- Installed XCode to use the Swift Package Manager (SPM), CocoaPods, or Carthage

To follow along with our test code sample, make sure you’ve:
- [Created a Feature Flag](https://ngdocs.harness.io/article/1j7pdkqh7j-create-a-feature-flag) on the Harness Platform called `harnessappdemodarkmode`
- Created a [server/client SDK key](https://ngdocs.harness.io/article/1j7pdkqh7j-create-a-feature-flag#step_3_create_an_sdk_key) and made a copy of it

## Installing the SDK
There are multiple methods to installing the iOS SDK:
## <u>_Swift Package Manager (SPM)_</u>
The [Swift Package Manager](https://swift.org/package-manager/) is a dependency manager integrated into the `swift` compiler and `Xcode`.

To integrate `ff-ios-client-sdk` into an Xcode project, go to the `File` drop down, and select `Add Packages`. From here, search the url `https://github.com/harness/ff-ios-client-sdk.git` in the search bar and click the `Add Package` button.

OR

You can also add the `ff-ios-client-sdk` dependency locally by dragging the SDK folder into the root directory of the project and simply add it to the dependencies section of your `Package.swift` file.

```Swift
dependencies: [
	.package(url: "https://github.com/harness/ff-ios-client-sdk.git", .upToNextMinor(from: "1.0.3"))
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
  pod 'ff-ios-client-sdk'
end
```

Only thing left to do is to install your packages by running the next command.
```Swift
pod install
```
NOTE: A new `.xcworkspace` will be created and you should use that, instead of your `.xcodeproj` from now on in order to utilize the imported Pods.

## <u>_Carthage_</u>
Carthage is intended to be the simplest way to add frameworks to your Cocoa application.
Carthage builds your dependencies and provides you with binary frameworks, but you retain full control over your project structure and setup. Carthage does not automatically modify your project files or your build settings.
In order to integrate `ff-ios-client-sdk` into your app, there are a few steps to follow.
Navigate to the root folder of your project and create a `Cartfile`. This is the file where you would input all of your dependencies that you plan to use with Carthage. You can create it by entering
```Swift
touch Cartfile
```
in Terminal at your project's root folder. Once you open the `Cartfile`, you can copy/paste below line and save the changes.
```Swift
github "harness/ff-ios-client-sdk"
```

Now, you need to run
```Swift
carthage update --no-build
```
This command will fetch the source for `ff-ios-client-sdk` from the repository specified in the `Cartfile`.

You will now have a new folder, named `Carthage` at the same location your `Cartfile` and your `.xcodeproj` are.
Within the `Carthage` folder, you will see another `Checkout` folder where the source code is located.
Next, we need to create a project for `ff-ios-client-sdk` dependency. We can do this easily by entering the following in the termial.
```Swift
//From your project's root folder
cd Carthage/Checkouts/ff-ios-client-sdk
```
followed by
```Swift
swift package generate-xcodeproj
```
...or, you can enter it all on the same line.
```Swift
//From your project's root folder
cd Carthage/Checkouts/ff-ios-client-sdk && swift package generate-xcodeproj
```
Go back into your project's root folder and enter the next command:
```Swift
carthage build --use-xcframeworks --platform iOS
```
This command will build the project and place it in the `Build` folder next to `Checkouts`.
On your application targets’ `General` settings tab, in the `Frameworks, Libraries, and Embedded Content` section, drag and drop the `.xcframework` file from the `Carthage/Build` folder. In the `"Embed"` section, select `"Embed & Sign"`.

Only thing left to do is:
```Swift
import ff_ios_client_sdk
```
...wherever you need to use `ff-ios-client-sdk`

When a new version of `ff-ios-client-sdk` is available and you wish to update this dependency, run
```Swift
$ carthage update --use-xcframeworks --platform iOS
```
And your embedded library will be updated.

## Code Sample
The following is a complete code example that you can use to test the `harnessappdemodarkmode` Flag you created on the Harness Platform. When you run the code it will:
1. Connect to the FF service.
2. Report the value of the Flag every 10 seconds until the connection is closed. Every time the `harnessappdemodarkmode` Flag is toggled on or off on the Harness Platform, the updated value is reported.
3. Close the SDK.

To use this sample, copy it into your project and enter your SDK key into the `apiKey` field.

```
import UIKit
import ff_ios_client_sdk
class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    NSLog("Start")
    let config = CfConfiguration.builder()
      .setStreamEnabled(true)
      .build()
    let target = CfTarget.builder().setIdentifier("Harness").build()
    CfClient.sharedInstance.initialize(
      apiKey: "apiKey",
      configuration:config,
      target: target
    ) { [weak self] result in
      switch result {
        case .failure(let error):
          NSLog("End: Error \(error)")
        case .success():
          NSLog("Init: Ok")
          CfClient.sharedInstance.boolVariation(evaluationId: "EVALUATION_ID", { (eval) in
            print("Value: \(eval!)")
          })
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
  }
  override func viewWillDisappear(_ animated: Bool) {
    CfClient.sharedInstance.destroy()
    NSLog("End: Ok")
    super.viewWillDisappear(animated)
  }
}
```

## Additional Reading
For further examples and config options:
- See the [iOS SDK Reference](https://docs.harness.io/article/6qt2v8g92m-ios-sdk-reference)
- [Further Reading](docs/further_reading.md)

For more information about Feature Flags, see our [Feature Flags documentation](https://docs.harness.io/article/0a2u2ppp8s-getting-started-with-feature-flags).