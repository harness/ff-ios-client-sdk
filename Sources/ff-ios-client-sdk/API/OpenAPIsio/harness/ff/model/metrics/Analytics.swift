import Foundation

public struct Analytics : Codable {
    
    public var target: CfTarget
    public var variation: Variation
    public var eventType: String
    public var featureConfig: FeatureConfig
    
    init (
    
        target: CfTarget,
        variation: Variation,
        eventType: String,
        featureConfig: FeatureConfig
    
    ) {
        
        self.target = target
        self.variation = variation
        self.eventType = eventType
        self.featureConfig = featureConfig
    }
}
