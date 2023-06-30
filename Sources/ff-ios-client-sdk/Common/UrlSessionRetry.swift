//
//  File.swift
//
//
//  Created by Andrew Bell on 29/06/2023.
//

import Foundation

class RetryHandler {
  private static let log = SdkLog.get("io.harness.ff.sdk.ios.RetryHandler")
  private var attempt = 0
  private let maxAttempts = 3
  private let delaySec = Double.random(in: 5...10)
  private let url:String

  init(_ url:String) {
    self.url = url
  }

  func taskCompletionShouldRetry(data:Data?, response:URLResponse?, error:Error?, shouldRetryCallback:@escaping (Bool) -> Void) -> Void {
    RetryHandler.log.trace("Enter retry handler")

    if (attempt >= maxAttempts) {
      RetryHandler.log.warn("Max retries reached for \(url)")
      attempt = 0
      shouldRetryCallback(false)
      return
    }

    var shouldRetry = false

    if let httpResponse = response as? HTTPURLResponse {
      if httpResponse.statusCode == 200 {
        RetryHandler.log.trace("Skip retry, got HTTP status code 200 on endpoint: \(url)")
        shouldRetry = false
      } else if shouldRetryHttpCode(httpResponse.statusCode) {
        RetryHandler.log.warn("Retrying, got HTTP status code \(httpResponse.statusCode) on endpoint: \(url)")
        shouldRetry = true
      }
    } else if let err = error {
      RetryHandler.log.warn("Endpoint \(url) got error: \(err)")
      shouldRetry =  shouldRetryError(error)
    } else {
      shouldRetry = false
    }

    if (shouldRetry) {
      attempt += 1
      let delaySec = delaySec * Double(attempt)
      RetryHandler.log.warn("Retrying request #\(attempt) of #\(maxAttempts) in \(String(format: "%.3f", delaySec)) seconds for \(url)")
      Thread.sleep(forTimeInterval: delaySec)
      shouldRetryCallback(true)
    } else {
      shouldRetryCallback(false)
    }

    RetryHandler.log.trace("Exit retry handler")
  }

  /*
   408 request timeout
   425 too early
   429 too many requests
   500 internal server error
   502 bad gateway
   503 service unavailable
   504 gateway timeout
    -1 OpenAPI error (timeout etc)
   */
  func shouldRetryHttpCode(_ code:Int) -> Bool {
    switch (code) {
    case 408,425,429,500,502,503,504,-1:
      return true
    default:
      return false
    }
  }

  func shouldRetryError(_ error:Error?) -> Bool {
    if let err = error as? NSError {
      RetryHandler.log.trace("Check if error should be retried: code=\(err.code) domain=\(err.domain)")

      if let causeErr = err.userInfo[NSUnderlyingErrorKey] as? NSError,
        let code = causeErr.userInfo["_kCFStreamErrorCodeKey"] as? Int {
        RetryHandler.log.trace("underlyingError: code=\(code) domain=\(causeErr.domain)")
        return causeErr.domain == kCFErrorDomainCFNetwork as String && code == -2102 // kCFStreamErrorRequestTimeout
      }

      return err.domain == kCFErrorDomainCFNetwork as String
    }
    return false
  }
}

class RetryURLSessionRequestBuilderFactory: RequestBuilderFactory {
  func getNonDecodableBuilder<T>() -> RequestBuilder<T>.Type {
    return RetryURLSessionRequestBuilder<T>.self
  }

  func getBuilder<T:Decodable>() -> RequestBuilder<T>.Type {
    return RetryURLSessionDecodableRequestBuilder<T>.self
  }
}

class RetryURLSessionRequestBuilder<T>: URLSessionRequestBuilder<T> {

  required public init(method: String, URLString: String, parameters: [String : Any]?, isBody: Bool, headers: [String : String] = [:]) {
    super.init(method: method, URLString: URLString, parameters: parameters, isBody: isBody, headers: headers)
    let handler = RetryHandler(URLString)
    super.taskCompletionShouldRetry = handler.taskCompletionShouldRetry
  }
}

class RetryURLSessionDecodableRequestBuilder<T: Decodable>: URLSessionDecodableRequestBuilder<T> {

  required public init(method: String, URLString: String, parameters: [String : Any]?, isBody: Bool, headers: [String : String] = [:]) {
    super.init(method: method, URLString: URLString, parameters: parameters, isBody: isBody, headers: headers)
    let handler = RetryHandler(URLString)
    super.taskCompletionShouldRetry = handler.taskCompletionShouldRetry
  }
}



