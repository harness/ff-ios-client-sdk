//
//  SdkTls.swift
//  
//
//  Created by Andrew Bell on 08/06/2023.
//

import Foundation
import Security

class SdkTls {

    private static var pemArray:[String] = []

    public static func setPems(pems:[String]) {
        pemArray = pems
    }

    public static func isTlsEnabled() -> Bool {
        return !pemArray.isEmpty
    }

    public static var trustedCerts: [SecCertificate] {
        var certs = Array<SecCertificate>()
        for pem in pemArray {
            if let certData = Data(base64Encoded: stripPem(pem: pem)) {
                certs.append(SecCertificateCreateWithData(nil, certData as CFData)!)
            }
        }
        return certs
    }

    private static func stripPem(pem:String) -> String {
        var text = pem.replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "", options: NSString.CompareOptions.literal, range:nil)
        text = text.replacingOccurrences(of: "-----END CERTIFICATE-----", with: "", options: NSString.CompareOptions.literal, range:nil)
        text = text.replacingOccurrences(of: "\n", with: "", options: NSString.CompareOptions.literal, range:nil)
        text = text.replacingOccurrences(of: "\r", with: "", options: NSString.CompareOptions.literal, range:nil)
        text = text.replacingOccurrences(of: "\t", with: "", options: NSString.CompareOptions.literal, range:nil)
        return text
    }
}

class TlsURLSessionRequestBuilderFactory: RequestBuilderFactory {
    func getNonDecodableBuilder<T>() -> RequestBuilder<T>.Type {
        TlsURLSessionRequestBuilder<T>.self
    }

    func getBuilder<T: Decodable>() -> RequestBuilder<T>.Type {
        TlsURLSessionDecodableRequestBuilder<T>.self
    }
}

class TlsURLSessionRequestBuilder<T>: URLSessionRequestBuilder<T> {

    fileprivate let sessionDelegate = URLSessionTrustDelegate()

    override func createURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = buildHeaders()
        return URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: nil)
    }
}

class TlsURLSessionDecodableRequestBuilder<T: Decodable>: URLSessionDecodableRequestBuilder<T> {

    fileprivate let sessionDelegate = URLSessionTrustDelegate()
    override func createURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = buildHeaders()
        return URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: nil)
    }
}

class URLSessionTrustDelegate: NSObject, URLSessionDelegate {

    // https://developer.apple.com/library/archive/technotes/tn2232/_index.html
    // https://opensource.apple.com/source/libsecurity_keychain/libsecurity_keychain-55050.9/lib/Trust.cpp.auto.html

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if (challenge.protectionSpace.authenticationMethod != NSURLAuthenticationMethodServerTrust) {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        if let serverTrust = challenge.protectionSpace.serverTrust, let serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            let policy = SecPolicyCreateSSL(false, challenge.protectionSpace.host as CFString?)
            var trust: SecTrust!
            var status = SecTrustCreateWithCertificates([serverCert] as CFArray, policy, &trust)

            let policies = NSMutableArray();
            policies.add(policy)
            SecTrustSetPolicies(trust, policies)

            if (errSecSuccess != status) {
                logTlsError(status, "Failed to create trust with cert", challenge)
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            status = SecTrustSetAnchorCertificates(trust, SdkTls.trustedCerts as CFArray)
            if (errSecSuccess != status) {
                logTlsError(status, "Failed to set trust anchors", challenge)
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            var secResult = SecTrustResultType.invalid
            status = SecTrustEvaluate(trust, &secResult)
            if (errSecSuccess != status) {
                logTlsError(status, "Failed to evaluate trust", challenge)
                return
            }

            if [.proceed, .unspecified].contains(secResult) {
                print("TLS: Endpoint is trusted")
                completionHandler(.useCredential, URLCredential(trust: trust))
                return
            } else {
                logTlsError(secResult, "Failed to evaluate trust", challenge)
                if let resultDict = SecTrustCopyResult(trust) {
                    print("TLS: results=\(resultDict)")
                }
            }
            logTlsError(serverCert: serverCert)
        }

        completionHandler(.cancelAuthenticationChallenge, nil)
    }

    fileprivate func logTlsError(_ status: OSStatus, _ msg:String, _ challenge:URLAuthenticationChallenge) {
        print("TLS: \(msg) Status=\(status) Host=\(challenge.protectionSpace.host) Port=\(challenge.protectionSpace.port)")
    }

    fileprivate func logTlsError(_ status: SecTrustResultType, _ msg:String, _ challenge:URLAuthenticationChallenge) {
        print("TLS: \(msg) Status=\(status) Host=\(challenge.protectionSpace.host) Port=\(challenge.protectionSpace.port)")
    }

    fileprivate func logTlsError(serverCert:SecCertificate) {
        if let serverCertSummary = SecCertificateCopySubjectSummary(serverCert) {
            print("TLS: Server cert '\(serverCertSummary)' did not match any of the following trusted CAs")
            for trustedCert in SdkTls.trustedCerts {
                if let trustedSummary = SecCertificateCopySubjectSummary(trustedCert) {
                    print("TLS: Trusted=\(trustedSummary)")
                }
            }
        }
    }
}
