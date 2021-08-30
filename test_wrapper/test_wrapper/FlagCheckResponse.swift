import Foundation

class FlagCheckResponse: NSObject, Codable {
    
    public var flag_key: String
    public var flag_value: String
    
    init(
    
        flag_key: String,
        flag_value: String
    ) {
        
        self.flag_key = flag_key
        self.flag_value = flag_value
    }
}
