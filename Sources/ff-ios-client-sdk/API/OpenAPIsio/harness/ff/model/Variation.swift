import Foundation

@objc public class Variation : NSObject, Codable {
    
    public var identifier: String
    public var value: String
    public var name: String
    
    init(
    
        identifier: String,
        value: String,
        name: String
    
    ) {
        
        self.identifier = identifier
        self.value = value
        self.name = name
    }
}
