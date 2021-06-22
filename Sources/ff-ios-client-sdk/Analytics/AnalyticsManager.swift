import Foundation

class AnalyticsManager : Destroyable {
    
    private let environmentID: String
    private let cluster: String
    private let authToken: String
    private let config: CfConfiguration
    private let cache: [Analytics:Int]
    private let timer: Timer
    // TODO: Ring buffer
    
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
        self.cache = [Analytics:Int]()
        self.timer = Timer() // TODO: Timer scheduling
        
        let analyticsPublisherService = AnalyticsPublisherService(
        
            cluster: cluster,
            environmentID: environmentID,
            config: config,
            cache: cache
        )
    }
    
    func destroy() {
        
        self.timer.invalidate()
    }
}
