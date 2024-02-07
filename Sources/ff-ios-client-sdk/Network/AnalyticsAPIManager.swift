//
//  AnalyticsAPIManagerProtocol.swift
//
//
//  Created by Milos Vasic on 22.6.21..
//

import Foundation

protocol AnalyticsAPIManagerProtocol {

  func postMetrics(

    environmentUUID: String,
    cluster: String,
    metrics: Metrics,
    apiResponseQueue: DispatchQueue,
    metricsApi: MetricsAPI,
    completion: @escaping ((EmptyResponse?, CFError?) -> Void)
  )
}

class AnalyticsAPIManager: AnalyticsAPIManagerProtocol {

  func postMetrics(

    environmentUUID: String,
    cluster: String,
    metrics: Metrics,
    apiResponseQueue: DispatchQueue,
    metricsApi: MetricsAPI,
    completion: @escaping ((EmptyResponse?, CFError?) -> Void)

  ) {

    metricsApi.postMetrics(

      environmentUUID: environmentUUID,
      cluster: cluster,
      metrics: metrics,
      apiResponseQueue: .main

    ) { (response, error) in

      guard error == nil else {

        completion(nil, CFError.serverError(.error(-1, nil, error)))
        return
      }

      completion(response, nil)
    }
  }
}
