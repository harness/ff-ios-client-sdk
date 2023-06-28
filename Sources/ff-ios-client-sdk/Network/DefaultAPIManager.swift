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
    completion: @escaping ((Swift.Result<[Evaluation], CFError>) -> Void)
  )

  func getEvaluationByIdentifier(

    environmentUUID: String,
    feature: String,
    target: String,
    cluster: String,
    apiResponseQueue: DispatchQueue,
    completion: @escaping ((Swift.Result<Evaluation, CFError>) -> Void)
  )
}

class DefaultAPIManager: DefaultAPIManagerProtocol {

  func getEvaluations(

    environmentUUID: String,
    target: String,
    cluster: String,
    apiResponseQueue: DispatchQueue,
    completion: @escaping (Swift.Result<[Evaluation], CFError>) -> Void

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
    completion: @escaping (Swift.Result<Evaluation, CFError>) -> Void

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
}
