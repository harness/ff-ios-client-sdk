import Foundation

public struct Analytics : Codable, Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        
        hasher.combine(featureConfig)
    }
    
    public static func == (lhs: Analytics, rhs: Analytics) -> Bool {
        
        return false
    }
    
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
