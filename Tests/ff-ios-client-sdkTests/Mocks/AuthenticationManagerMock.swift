//
//  AuthenticationManagerMock.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 20.2.21..
//

import Foundation
@testable import ff_ios_client_sdk

class AuthenticationManagerMock: AuthenticationManagerProtocol {
	func authenticate(authenticationRequest: AuthenticationRequest?, apiResponseQueue: DispatchQueue, completion: @escaping ((AuthenticationResponse?, ff_ios_client_sdk.CFError?) -> Void)) {
		if authenticationRequest!.apiKey == "someSuccessApiKey" {
			completion(AuthenticationResponse(authToken: JWTMocks.token), nil)
		} else {
			completion(nil, ff_ios_client_sdk.CFError.authError(.error(-1, nil, nil)))
		}
	}
	
	
}
