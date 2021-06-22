import Foundation

class AnalyticsManager : Destroyable {
    
    private let environmentID: String
    private let cluster: String
    private let authToken: String
    private let config: CfConfiguration
    
    init (
    
        environmentID: String,
        cluster: String,
        authToken: String,
        config: CfConfiguration
        
    ) {
        
        self.environmentID = environmentID
        self.cluster = cluster
        self.authToken = authToken
        self.config = config
        
        let analyticsPublisherService = AnalyticsPublisherService(
        
            cluster: cluster,
            environmentID: environmentID,
            config: config
        )
    }
    
    func destroy() {
        
        
    }
}
