import Foundation

@objc public class KeyValue : NSObject, Codable {
    
    public var key: String
    public var value: String
    
    init(key: String, value: String) {
        
        self.key = key
        self.value = value
    }
}
