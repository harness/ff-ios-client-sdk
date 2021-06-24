
import Foundation

@objc public class  FeatureConfig : NSObject, Codable {
    
    public var project: String
    public var environment: String
    public var feature: String
    public var state: String
    public var kind: String
    public var version: Double
    
    init(
    
        project: String,
        environment: String,
        feature: String,
        state: String,
        kind: String,
        version: Double
    
    ) {
        
        self.project = project
        self.environment = environment
        self.feature = feature
        self.state = state
        self.kind = kind
        self.version = version
    }
}
