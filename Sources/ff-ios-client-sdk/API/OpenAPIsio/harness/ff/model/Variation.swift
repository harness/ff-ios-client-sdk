import Foundation

public struct Variation : Codable {
    
    public var identifier: String
    public var value: String
    public var name: String
    public var description: String
    
    init(
    
        identifier: String,
        value: String,
        name: String,
        description: String
    
    ) {
        
        self.identifier = identifier
        self.value = value
        self.name = name
        self.description = description
    }
}
