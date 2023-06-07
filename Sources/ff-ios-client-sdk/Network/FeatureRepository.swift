//
//  FeatureRepository.swift
//  ff-ios-client-sdk
//
//  Created by Dusan Juranovic on 2.2.21..
//

import Foundation

class FeatureRepository {
	
    var token: String
    var cluster: String
    var target: CfTarget
    var config: CfConfiguration
	var storageSource: StorageRepositoryProtocol
	var defaultAPIManager: DefaultAPIManagerProtocol?
	
	init(
        
        token: String?,
        cluster: String?,
        storageSource: StorageRepositoryProtocol?,
        config:CfConfiguration?,
        target: CfTarget,
        defaultAPIManager: DefaultAPIManagerProtocol = DefaultAPIManager()
        
    ) {
		
        self.token = token ?? ""
        self.cluster = cluster ?? ""
		self.storageSource = storageSource ?? CfCache()
		self.config = config ?? CfConfiguration.builder().build()
		self.defaultAPIManager = defaultAPIManager
		self.target = target
	}
	
	/// Use this method to get `[Evaluation]` for a  target specified in `CfConfiguration` during the call to initialize `CfClient`.
	/// - Parameters:
	///   - onCompletion: completion block containing `[Evaluation]?` or `CFError?` from appropriate lower level methods.
	func getEvaluations(
        
        onCompletion:@escaping(Result<[Evaluation], CFError>)->()
    ) {
		
        OpenAPIClientAPI.customHeaders = [CFHTTPHeaderField.authorization.rawValue:"Bearer \(self.token)"]
		
		Logger.log("Try to get ALL from CLOUD")
		defaultAPIManager?.getEvaluations(
            
            environmentUUID: self.config.environmentId,
            target: self.target.identifier,
            cluster: cluster,
            apiResponseQueue: .main
        
        ) { [weak self] (result) in
			guard let self = self else {return}
			
            let allKey = CfConstants.Persistance.features(self.config.environmentId, self.target.identifier).value
			switch result {
				case .failure(_):
					Logger.log("Failed getting ALL from CLOUD. Try CACHE/STORAGE")
					do {
						let evals: [Evaluation]? = try self.storageSource.getValue(forKey: allKey)
						onCompletion(.success(evals ?? []))
						Logger.log("SUCCESS: Got ALL from CACHE/STORAGE")
					} catch {
						Logger.log("FAILURE: Unable to get ALL from CACHE/STORAGE")
						onCompletion(.failure(CFError.storageError))
					}
				case .success(let evaluations):
					Logger.log("SUCCESS: Got ALL from CLOUD")
					
					for eval in evaluations {
						let key = CfConstants.Persistance.feature(self.config.environmentId, self.target.identifier, eval.flag).value
						try? self.storageSource.saveValue(eval, key: key)
					}
					
					try? self.storageSource.saveValue(evaluations, key: allKey)
					onCompletion(.success(evaluations))
			}
		}
	}
	
	/// Use this method to get `Evaluation`for a  target specified in `CfConfiguration` during the call to initialize `CfClient`.
	/// - Parameters:
	///   - feature: `Feature ID`
	///   - onCompletion: completion block containing `Evaluation?` or `CFError?` from appropriate lower level methods.
	func getEvaluationById(
        
        _ evaluationId: String,
        target: String,
        useCache: Bool = false,
        onCompletion:@escaping(Result<Evaluation, CFError>)->()
    ) {
		
        if useCache {
			do {
				let key = CfConstants.Persistance.feature(self.config.environmentId, target, evaluationId).value
				let evaluation: Evaluation? = try self.storageSource.getValue(forKey: key)
				onCompletion(.success(evaluation!))
			} catch {
				onCompletion(.failure(CFError.noDataError))
			}
			return
		}
		OpenAPIClientAPI.customHeaders = [CFHTTPHeaderField.authorization.rawValue:"Bearer \(self.token)"]
		Logger.log("Try to get Evaluation |\(evaluationId)| from CLOUD")
		defaultAPIManager?.getEvaluationByIdentifier(
            
            environmentUUID: self.config.environmentId,
            feature: evaluationId,
            target: target,
            cluster: cluster,
            apiResponseQueue: .main
        
        ) { [weak self] (result) in
			guard let self = self else {return}
			let key = CfConstants.Persistance.feature(self.config.environmentId, target, evaluationId).value
			switch result {
				case .failure(_):
					Logger.log("Failed getting |\(evaluationId)| from CLOUD. Try CACHE/STORAGE")
					do {
						if let storedFeature: Evaluation? = try self.storageSource.getValue(forKey: key) {
							onCompletion(.success(storedFeature!))
							Logger.log("SUCCESS: Got |\(evaluationId)| -> |\(storedFeature!.value)| from CACHE/STORAGE")
						} else {
							Logger.log("FAILURE: Unable to get |\(evaluationId)| from CACHE/STORAGE")
							onCompletion(.failure(CFError.noDataError))
						}
					} catch {
						onCompletion(.failure(CFError.noDataError))
					}
				case .success(let evaluation):
					Logger.log("SUCCESS: Got |\(evaluationId)| -> |\(evaluation.value)| from CLOUD")
					do {
						try self.storageSource.saveValue(evaluation, key: key)
						self.updateAll(evaluation)
					} catch {
						onCompletion(.failure(CFError.storageError))
					}
					onCompletion(.success(evaluation))
			}
		}
	}
    
    /// Use this method to save an `Evaluation`
    /// - Parameters:
    ///   - evaluation: the evaluation to save to storage
    ///   - onCompletion: completion block containing `Evaluation?` or `CFError?` from appropriate lower level methods.
    func saveEvaluation(
        evaluation: Evaluation,
        onCompletion:@escaping(Result<Evaluation, CFError>)->()
    ) {
        let key = CfConstants.Persistance.feature(self.config.environmentId, self.target.identifier, evaluation.flag).value
        do {
            try self.storageSource.saveValue(evaluation, key: key)
            self.updateAll(evaluation)
            Logger.log("SUCCESS: Saved |\(evaluation.flag)| -> |\(evaluation.value)| from SSE event")
            onCompletion(.success(evaluation))
        } catch {
            Logger.log("Failed saving |\(evaluation.flag)| to cache")
            onCompletion(.failure(CFError.storageError))
        }
        
    }
    
	private func updateAll(_ eval: Evaluation) {
		let allKey = CfConstants.Persistance.features(self.config.environmentId, self.target.identifier).value
		do {
			let all: [Evaluation]? = try self.storageSource.getValue(forKey: allKey)
			guard var evaluations = all else {return}
			for (index, evaluation) in evaluations.enumerated() {
				if evaluation.flag == eval.flag {
					evaluations.remove(at: index)
					evaluations.insert(eval, at: index)
				}
			}
			try storageSource.saveValue(evaluations, key: allKey)
		} catch {
			print("updateAll failed")
		}
	}
}
