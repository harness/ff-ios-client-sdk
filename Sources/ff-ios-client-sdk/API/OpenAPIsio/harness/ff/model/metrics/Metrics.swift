import Foundation

@objc public class Metrics : NSObject, Codable {
    
    public var metricsData: [MetricsData]?
    
    init(metricsData: [MetricsData]?) {
        
        self.metricsData = metricsData
    }
}
