import Foundation

class AnalyticsPublisherService {
    
    private let cluster: String
    private let environmentID: String
    private let config: CfConfiguration
    private let cache: [Analytics:Int]
    
    init(
    
        cluster: String,
        environmentID: String,
        config: CfConfiguration
    
    ) {
        
        self.cluster = cluster
        self.environmentID = environmentID
        self.config = config
        self.cache = [Analytics:Int]()
    }
}
