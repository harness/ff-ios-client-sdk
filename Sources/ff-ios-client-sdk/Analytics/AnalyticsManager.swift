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
        self.ringBuffer = RingBuffer<Analytics>(capacity: config.bufferSize)
        
        let analyticsPublisherService = AnalyticsPublisherService(
        
            cluster: cluster,
            environmentID: environmentID,
            config: config,
            cache: cache
        )
    }
    
    func pushToQueue(
    
        target: CfTarget,
        featureConfig: FeatureConfig,
        variation: Variation
    
    ) {
        
        let analytics = Analytics(
        
            target: target,
            variation: variation,
            eventType: "METRICS",
            featureConfig: featureConfig
        )
        
        ringBuffer.
    }
    
    func destroy() {
        
        self.timer.invalidate()
    }
}
