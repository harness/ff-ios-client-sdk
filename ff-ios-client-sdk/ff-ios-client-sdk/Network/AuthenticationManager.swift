//
//  AuthenticationManager.swift
//  
//
//  Created by Dusan Juranovic on 20.2.21..
//

import Foundation

protocol AuthenticationManagerProtocol {
	func authenticate(authenticationRequest: AuthenticationRequest?, apiResponseQueue: DispatchQueue, completion: @escaping ((_ data: AuthenticationResponse?,_ error: CFError?) -> Void))
}

class AuthenticationManager: AuthenticationManagerProtocol {
	func authenticate(authenticationRequest: AuthenticationRequest?, apiResponseQueue: DispatchQueue, completion: @escaping ((AuthenticationResponse?, CFError?) -> Void)) {
		DefaultAPI.authenticate(authenticationRequest: authenticationRequest, apiResponseQueue: .main) { (response, error) in
			guard error == nil else {
				completion(nil, CFError.authError(.error(-1, nil, error)))
				return
			}
			
			completion(response, nil)
		}
	}
}

