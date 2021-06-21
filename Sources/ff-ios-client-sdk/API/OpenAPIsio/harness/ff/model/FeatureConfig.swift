
import Foundation

public struct  FeatureConfig : Codable {
    
    public var project: String
    public var environment: String
    public var feature: String
    public var state: String
    public var kind: String
    public var version: Int64
    
    init(
    
        project: String,
        environment: String,
        feature: String,
        state: String,
        kind: String,
        version: Int64
    
    ) {
        
        self.project = project
        self.environment = environment
        self.feature = feature
        self.state = state
        self.kind = kind
        self.version = version
    }
}
