//
//  File.swift
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
        completion: @escaping ((Swift.Result<Void, CFError>) -> ())
    )
}
