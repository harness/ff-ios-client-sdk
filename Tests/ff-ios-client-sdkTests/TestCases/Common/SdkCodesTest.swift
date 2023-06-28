//
//  SdkCodesTest.swift
//  ff-ios-client-sdk
//
//  Created by Andrew Bell on 23/06/2023.
//

import Foundation
import XCTest

@testable import ff_ios_client_sdk

class SdkCodesTest: XCTestCase {

  func testSdkErrorCodes() {

    let target = CfTarget.builder().setIdentifier("ident").setName("name").build()

    SdkCodes.info_sdk_init_ok()
    SdkCodes.warn_sdk_auth_error("dummy")
    SdkCodes.warn_sdk_init_ok()
    SdkCodes.info_sdk_auth_ok()
    SdkCodes.warn_auth_failed()
    SdkCodes.warn_auth_failed_missing_token()
    SdkCodes.error_auth_retying(123)
    SdkCodes.info_poll_started(321)
    SdkCodes.info_polling_stopped()
    SdkCodes.info_stream_connected()
    SdkCodes.warn_stream_disconnected("dummy")
    SdkCodes.info_stream_event_received("{\"dummy\":\"json\"}")
    SdkCodes.info_metrics_thread_started()
    SdkCodes.info_metrics_thread_exited()
    SdkCodes.warn_post_metrics_failed("dummy")
    SdkCodes.warn_default_variation_served("id", target.identifier, "defVal")
  }
}
