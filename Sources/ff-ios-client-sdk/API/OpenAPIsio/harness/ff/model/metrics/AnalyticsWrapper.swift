import Foundation

@objc public class AnalyticsWrapper : NSObject, Codable {
    
    public var analytics: Analytics
    public var count: Int
    
    init (analytics: Analytics, count: Int) {
        
        self.analytics = analytics
        self.count = count
    }
}
