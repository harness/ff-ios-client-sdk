//
//  File.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 20.2.21..
//

import Foundation
@testable import ff_ios_client_sdk

class DefaultAPIManagerMock: DefaultAPIManagerProtocol {
    
	var replacementEnabled = false
	func getEvaluations(environmentUUID: String, target: String, cluster: String, apiResponseQueue: DispatchQueue, completion: @escaping (Swift.Result<[Evaluation], ff_ios_client_sdk.CFError>) -> ()) {
		if target == "success" {
			let evaluations = CacheMocks.createAllTypeFlagMocks()
			completion(.success(evaluations))
		} else {
			completion(.failure(CFError.storageError))
		}
	}
	
	func getEvaluationByIdentifier(environmentUUID: String, feature: String, target: String, cluster: String, apiResponseQueue: DispatchQueue, completion: @escaping (Swift.Result<Evaluation, ff_ios_client_sdk.CFError>) -> ()) {
		var found = false
 		if target == "cloud_failure_cache_failure" {
			completion(.failure(CFError.storageError))
		} else {
			if replacementEnabled {
				let evaluation = CacheMocks.createEvalForStringType(feature)!
				var modifiedEval: Evaluation?
				let value = evaluation.value
				switch value {
					case .string(let string): modifiedEval = Evaluation(flag: evaluation.flag, identifier: "test", value: .string(string + "_changed"))
					case .bool(let bool):  modifiedEval = Evaluation(flag: evaluation.flag, identifier: "test",value: .bool(!bool))
					case .int(let int): modifiedEval = Evaluation(flag: evaluation.flag, identifier: "test",value: .int(int + 5))
					case .object(_): modifiedEval = Evaluation(flag: evaluation.flag, identifier: "test", value: .object(["added":ValueType.bool(true)]))
				}
				completion(.success(modifiedEval!))
			} else {
				let evaluations = CacheMocks.createAllTypeFlagMocks()
				for eval in evaluations {
					if eval.flag == feature {
						found = true
						completion(.success(eval))
					}
				}
				if !found {
					completion(.failure(CFError.noDataError))
				}
			}
		}
	}
}
