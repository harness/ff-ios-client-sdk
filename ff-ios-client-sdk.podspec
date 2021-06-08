Pod::Spec.new do |ff|

  ff.name         = "ff-ios-client-sdk"
  ff.version      = "0.0.7"
  ff.summary      = "iOS SDK for Harness Feature Flags Management"

  ff.description  = <<-DESC
	Feature Flag Management platform from Harness. iOS SDK can be used to integrate with the platform in your iOS applications.
                   DESC

  ff.homepage     = "https://github.com/drone/ff-ios-client-sdk"
  ff.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  ff.author             =  "Harness Inc"

  ff.platform     = :ios, "10.0"
  ff.ios.deployment_target = "10.0"

  ff.source       = { :git => ff.homepage + '.git', :tag => ff.version }
  ff.source_files  = "Sources", "Sources/ff-ios-client-sdk/**/*.{h,m,swift}"
  ff.public_header_files = "Sources/ff-ios-client-sdk/**/*.{h}"

  ff.requires_arc = true
  ff.swift_versions = ['5.0', '5.1', '5.2', '5.3']
end
