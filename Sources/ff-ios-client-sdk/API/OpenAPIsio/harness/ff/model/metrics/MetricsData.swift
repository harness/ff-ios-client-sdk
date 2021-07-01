import Foundation

@objc public class MetricsData : NSObject, Codable {
    
    public var timestamp: Int64
    public var count: Int
    public var metricsType: String
    public var attributes: [KeyValue]
    
    init(
        
        timestamp: Int64,
        count: Int,
        metricsType: String,
        attributes: [KeyValue]
        
    ) {
        
        self.timestamp = timestamp
        self.count = count
        self.metricsType = metricsType
        self.attributes = attributes
    }
}
