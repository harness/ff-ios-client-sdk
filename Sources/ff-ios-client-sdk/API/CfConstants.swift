import Foundation

enum CFHTTPHeaderField: String {
    
    case authorization  = "Authorization"
    case contentType    = "Content-Type"
    case acceptType     = "Accept"
    case acceptEncoding = "Accept-Encoding"
    case cacheControl	= "Cache-Control"
    case apiKey			= "API-Key"
}

enum CFContentType: String {
    
    case json = "application/json"
    case form = "application/x-www-form-urlencoded"
    case eventStream = "text/event-stream"
    case noCache = "no-cache"
    case textHtml = "text/html"
}

struct CfConstants {
    
    enum Persistance {
    
        case feature(String, String, String)
        case features(String, String)
        
        var value: String {
            
            switch self {

                case let .feature(envId, target , feature): return "\(envId)_\(target)_\(feature)"
                case let .features(envId, target): return "\(envId)_\(target)_features"
            }
        }
    }
    
    struct Server {
        
        static let configUrl 	 = "https://config.ff.harness.io/api/1.0"
        static let streamUrl 	 = "https://config.ff.harness.io/api/1.0/stream"
        static let eventUrl      = "https://events.ff.harness.io/api/1.0"
    }
    
    struct ParamKey {
        
        static let authToken = "authToken"
    }
}
