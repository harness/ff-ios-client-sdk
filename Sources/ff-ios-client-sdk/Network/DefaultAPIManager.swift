//
//  File.swift
//  
//
//  Created by Dusan Juranovic on 20.2.21..
//

import Foundation

protocol DefaultAPIManagerProtocol {
	
    func getEvaluations(
        
        environmentUUID: String,
        target: String,
        cluster: String,
        apiResponseQueue: DispatchQueue,
        completion: @escaping ((Swift.Result< [Evaluation], CFError>) -> ())
    )
	
    func getEvaluationByIdentifier(
        
        environmentUUID: String,
        feature: String,
        target: String,
        cluster: String,
        apiResponseQueue: DispatchQueue,
        completion: @escaping ((Swift.Result<Evaluation, CFError>) -> ())
    )
    
    func getFeatureConfig(
        
        environmentUUID: String,
        cluster: String,
        apiResponseQueue: DispatchQueue,
        completion: @escaping ((Swift.Result<[FeatureConfig], CFError>) -> ())
    )
}

class DefaultAPIManager: DefaultAPIManagerProtocol {
	
    func getEvaluations(
        
        environmentUUID: String,
        target: String,
        cluster: String,
        apiResponseQueue: DispatchQueue,
        completion: @escaping (Swift.Result<[Evaluation], CFError>) -> ()
    
    ) {
		DefaultAPI.getEvaluations(
            
            environmentUUID: environmentUUID,
            target: target,
            cluster: cluster,
            apiResponseQueue: apiResponseQueue
        
        ) { (evaluations, error) in
			guard error == nil else {
				completion(.failure(CFError.serverError(error as! ErrorResponse)))
				return
			}
			guard let evaluations = evaluations else {
				completion(.failure(CFError.noDataError))
				return
			}
			completion(.success(evaluations))
		}
	}
    
	func getEvaluationByIdentifier(
        
        environmentUUID: String,
        feature: String,
        target: String,
        cluster: String,
        apiResponseQueue: DispatchQueue,
        completion: @escaping (Swift.Result<Evaluation, CFError>) -> ()
    
    ) {
		DefaultAPI.getEvaluationByIdentifier(
            
            environmentUUID: environmentUUID,
            feature: feature,
            target: target,
            apiResponseQueue: apiResponseQueue,
            cluster: cluster
        
        ) { (evaluation, error) in
			guard error == nil else {
				completion(.failure(CFError.serverError(error as! ErrorResponse)))
				return
			}
			guard let evaluation = evaluation else {
				completion(.failure(CFError.noDataError))
				return
			}
			completion(.success(evaluation))
		}
	}
    
    func getFeatureConfig(
        
        environmentUUID: String,
        cluster: String,
        apiResponseQueue: DispatchQueue,
        completion: @escaping (Result<[FeatureConfig], CFError>) -> ()
    
    ) {
        
        DefaultAPI.getFeatureConfig(
            
            environmentUUID: environmentUUID,
            cluster: cluster,
            apiResponseQueue: apiResponseQueue
        
        ) { (featureConfig, error) in
            guard error == nil else {
                completion(.failure(CFError.serverError(error as! ErrorResponse)))
                return
            }
            guard let featureConfig = featureConfig else {
                completion(.failure(CFError.noDataError))
                return
            }
            completion(.success(featureConfig))
        }
    }
}
