#
#  Be sure to run `pod spec lint FFiOSClientSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |ff|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  ff.name         = "FFiOSClientSDK"
  ff.version      = "0.0.1"
  ff.summary      = "A brief description FFiOSClientSDK use cases and general purpose of the SDK."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  ff.description  = <<-DESC
	FFiOSClientSDK servers the purpose of communicating to SSE servers to fetch the latest feature flags for different environments. You can easily modify your App and present new features to your clients at the touch of a button (switch in our case) from your dedicated portal.
                   DESC

  ff.homepage     = "https://github.com/drone/ff-ios-client-sdk"
  # ff.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  # ff.license      = "MIT (example)"
  ff.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  ff.author             = { "Harness.io" => "rushabh@harness.io" }
  # Or just: ff.author    = "Dusan Juranovic"
  # ff.authors            = { "Harness.io" => "rushabh@harness.io" }
  # ff.social_media_url   = ""

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # ff.platform     = :ios
  ff.platform     = :ios, "10.0"

  #  When using multiple platforms
  # ff.ios.deployment_target = "5.0"
  # ff.osx.deployment_target = "10.7"
  # ff.watchos.deployment_target = "2.0"
  # ff.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  ff.source       = { :git => ff.homepage + '.git', :tag => ff.version }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  ff.source_files  = "ff-ios-client-sdk/**/*.{h,m,swift}"
  # ff.exclude_files = "Classes/Exclude"

  ff.public_header_files = "ff-ios-client-sdk/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # ff.resource  = "icon.png"
  # ff.resources = "Resources/*.png"

  # ff.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # ff.framework  = "SomeFramework"
  # ff.frameworks = "SomeFramework", "AnotherFramework"

  # ff.library   = "iconv"
  # ff.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  ff.requires_arc = true
  ff.swift_version = '5.0'

  # ff.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # ff.dependency "JSONKit", "~> 1.4"

end
