import Foundation

class FlagCheck: NSObject, Codable {
    
    public var flag_key: String
    public var flag_kind: String
    
    init(
    
        flag_key: String,
        flag_kind: String
    ) {
        
        self.flag_key = flag_key
        self.flag_kind = flag_kind
    }
}
