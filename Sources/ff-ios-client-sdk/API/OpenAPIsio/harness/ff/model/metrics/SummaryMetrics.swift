import Foundation

@objc public class SummaryMetrics : NSObject, Codable {
    
    public var featureName: String
    public var variationValue: String
    public var variationIdentifier: String
    public var target: String
    
    init (
    
        featureName: String,
        variationValue: String,
        variationIdentifier: String,
        target: String
    
    ) {
        
        self.featureName = featureName
        self.variationValue = variationValue
        self.variationIdentifier = variationIdentifier
        self.target = target
    }
}
