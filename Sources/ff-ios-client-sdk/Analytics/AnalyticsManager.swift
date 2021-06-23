import Foundation

class AnalyticsManager : Destroyable {
    
    private let environmentID: String
    private let cluster: String
    private let authToken: String
    private let config: CfConfiguration
    private let timer: Timer
    private let ringBuffer: RingBuffer<Analytics>
    
    private var cache: [Analytics:Int]
    
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
        self.ringBuffer = RingBuffer<Analytics>(capacity: 1000)
        
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
