//
//  FeatureRepository.swift
//  ff-ios-client-sdk
//
//  Created by Dusan Juranovic on 2.2.21..
//

import Foundation

class FeatureRepository {

  private static let logger = SdkLog.get("io.harness.ff.sdk.ios.FeatureRepository")

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
    config: CfConfiguration?,
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

    onCompletion: @escaping (Result<[Evaluation], CFError>) -> Void
  ) {
    FeatureRepository.logger.debug("Try to get ALL from CLOUD")

    defaultAPIManager?.getEvaluations(

      environmentUUID: self.config.environmentId,
      target: self.target.identifier,
      cluster: cluster,
      apiResponseQueue: .main

    ) { [weak self] (result) in
      guard let self = self else { return }

      let allKey = CfConstants.Persistance.features(
        self.config.environmentId, self.target.identifier
      ).value
      switch result {
      case .failure(_):
        FeatureRepository.logger.warn("Failed getting ALL from CLOUD. Try CACHE/STORAGE")
        do {
          let evals: [Evaluation]? = try self.storageSource.getValue(forKey: allKey)
          onCompletion(.success(evals ?? []))
          FeatureRepository.logger.debug("SUCCESS: Got ALL from CACHE/STORAGE")
        } catch {
          FeatureRepository.logger.warn("FAILURE: Unable to get ALL from CACHE/STORAGE")
          onCompletion(.failure(CFError.storageError))
        }
      case .success(let evaluations):
        FeatureRepository.logger.debug("SUCCESS: Got ALL from CLOUD")

        for eval in evaluations {
          let key = CfConstants.Persistance.feature(
            self.config.environmentId, self.target.identifier, eval.flag
          ).value
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
    onCompletion: @escaping (Result<Evaluation, CFError>) -> Void
  ) {

    if useCache {
      do {
        let key = CfConstants.Persistance.feature(self.config.environmentId, target, evaluationId)
          .value
        let evaluation: Evaluation? = try self.storageSource.getValue(forKey: key)
        onCompletion(.success(evaluation!))
      } catch {
        FeatureRepository.logger.warn("ERROR: \(error)")
        onCompletion(.failure(CFError.noDataError))
      }
      return
    }

    FeatureRepository.logger.debug("Try to get Evaluation |\(evaluationId)| from CLOUD")

    defaultAPIManager?.getEvaluationByIdentifier(
      environmentUUID: self.config.environmentId,
      feature: evaluationId,
      target: target,
      cluster: cluster,
      apiResponseQueue: .main

    ) { [weak self] (result) in
      guard let self = self else { return }
      let key = CfConstants.Persistance.feature(self.config.environmentId, target, evaluationId)
        .value
      switch result {
      case .failure(_):
        FeatureRepository.logger.warn(
          "Failed getting |\(evaluationId)| from CLOUD. Try CACHE/STORAGE")
        do {
          if let storedFeature: Evaluation? = try self.storageSource.getValue(forKey: key) {
            onCompletion(.success(storedFeature!))
            FeatureRepository.logger.debug(
              "SUCCESS: Got |\(evaluationId)| -> |\(storedFeature!.value)| from CACHE/STORAGE")
          } else {
            FeatureRepository.logger.warn(
              "FAILURE: Unable to get |\(evaluationId)| from CACHE/STORAGE")
            onCompletion(.failure(CFError.noDataError))
          }
        } catch {
          onCompletion(.failure(CFError.noDataError))
        }
      case .success(let evaluation):
        FeatureRepository.logger.debug(
          "SUCCESS: Got |\(evaluationId)| -> |\(evaluation.value)| from CLOUD")
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
    onCompletion: @escaping (Result<Evaluation, CFError>) -> Void
  ) {
    let key = CfConstants.Persistance.feature(
      self.config.environmentId, self.target.identifier, evaluation.flag
    ).value
    do {
      try self.storageSource.saveValue(evaluation, key: key)
      self.updateAll(evaluation)
      FeatureRepository.logger.debug(
        "SUCCESS: Saved |\(evaluation.flag)| -> |\(evaluation.value)| from SSE event")
      onCompletion(.success(evaluation))
    } catch {
      FeatureRepository.logger.warn("Failed saving |\(evaluation.flag)| to cache")
      onCompletion(.failure(CFError.storageError))
    }

  }
    
    func deleteEvaluations(forFlagId flagId: String, target: String, onCompletion: @escaping (Result<Void, CFError>) -> Void) {
        let allKey = CfConstants.Persistance.features(self.config.environmentId, target).value

        do {
            if var allEvaluations: [Evaluation] = try self.storageSource.getValue(forKey: allKey) {
                // Filter out the evaluations that match the flag ID to delete
                allEvaluations.removeAll { $0.flag == flagId }
                
                try self.storageSource.saveValue(allEvaluations, key: allKey)
            }
            FeatureRepository.logger.debug("Deleted evaluations from cache because flag '\(flagId)' was deleted")
            onCompletion(.success(()))
        } catch {
            FeatureRepository.logger.warn("Flag |\(flagId)| was deleted, but failed to remove its evaluations from cache")
            onCompletion(.failure(CFError.storageError))
        }
    }



  private func updateAll(_ eval: Evaluation) {
    let allKey = CfConstants.Persistance.features(self.config.environmentId, self.target.identifier)
      .value
    do {
      let all: [Evaluation]? = try self.storageSource.getValue(forKey: allKey)
      guard var evaluations = all else { return }
      for (index, evaluation) in evaluations.enumerated() {
        if evaluation.flag == eval.flag {
          evaluations.remove(at: index)
          evaluations.insert(eval, at: index)
        }
      }
      try storageSource.saveValue(evaluations, key: allKey)
    } catch {
      FeatureRepository.logger.warn("updateAll failed")
    }
  }
}
