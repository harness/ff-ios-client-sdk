import Foundation

public struct Metrics : Codable {
    
    public var metricsData: [MetricsData]?
    
    init(metricsData: [MetricsData]?) {
        
        self.metricsData = metricsData
    }
}
