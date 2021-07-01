import Foundation

@objc public class Analytics : NSObject, Codable {
    
    public var target: CfTarget
    public var variation: Variation
    public var eventType: String
    
    init (
    
        target: CfTarget,
        variation: Variation,
        eventType: String
        
    ) {
        
        self.target = target
        self.variation = variation
        self.eventType = eventType
    }
}
