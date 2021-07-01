import Foundation

open class MetricsAPI {
    
    /**
     Post metrics data.
     
     - parameter environmentUUID: (path) Unique identifier for the environment object in the API.
     - parameter cluster: Cluster.
     - parameter metrics: Metrics data.
     - parameter apiResponseQueue: The queue on which api response is dispatched.
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func postMetrics(
        
        environmentUUID: String,
        cluster: String,
        metrics: Metrics,
        apiResponseQueue: DispatchQueue = OpenAPIClientAPI.apiResponseQueue,
        completion: @escaping ((_ data: EmptyResponse?,_ error: Error?) -> Void)
    
    ) {
        postMetricsRequestBuilder(
            
            environmentUUID: environmentUUID,
            cluster: cluster,
            metrics: metrics
        
        ).execute(apiResponseQueue) { result -> Void in
            
            switch result {
                case let .success(response):
                    completion(response.body, nil)
                case let .failure(error):
                    completion(nil, error)
            }
        }
    }
    
    /**
     Post metrics data.
     
     - parameter environmentUUID: (path) Unique identifier for the environment object in the API.
     - parameter cluster: Cluster.
     - parameter metrics: Metrics data.
     - returns: RequestBuilder<EmptyResponse>
     */
    open class func postMetricsRequestBuilder(
        
        environmentUUID: String,
        cluster: String,
        metrics: Metrics
    
    ) -> RequestBuilder<EmptyResponse> {
        
        var path = "/metrics/{environment}?cluster=\(cluster)"
        
        let environmentUUIDPreEscape = "\(APIHelper.mapValueToPathItem(environmentUUID))"
        let environmentUUIDPostEscape = environmentUUIDPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        
        path = path.replacingOccurrences(of: "{environment}", with: environmentUUIDPostEscape, options: .literal, range: nil)
        
        let URLString = OpenAPIClientAPI.eventPath + path
        
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: metrics)

        let url = URLComponents(string: URLString)

        let requestBuilder: RequestBuilder<EmptyResponse>.Type = OpenAPIClientAPI.requestBuilderFactory.getBuilder()

        let req = requestBuilder.init(
            
            method: "POST",
            URLString: (url?.string ?? URLString),
            parameters: parameters,
            isBody: true
        )
        
        NSLog("API postMetrics: URL=\(req.URLString), HEADERS=\(req.headers), METHOD=\(req.method)")
        return req
    }
}
