import Foundation

public struct AnalyticsWrapper : Codable, Hashable {
    
    public var analytics: Analytics
    public var count: Int
    
    init (analytics: Analytics, count: Int) {
        
        self.analytics = analytics
        self.count = count
    }
}
