import Foundation

import ff_ios_client_sdk

import Telegraph

class WrapperServer {
    
    private let port: Int
    private let apiKey: String
    private let target: CfTarget
    private let server = Server()
    private let configuration: CfConfiguration
    
    init(
    
        port: Int,
        apiKey: String,
        target: CfTarget,
        configuration: CfConfiguration
    ) {
        
        self.port = port
        self.apiKey = apiKey
        self.target = target
        self.configuration = configuration
    }
    
    public func initialize(callback: @escaping ((Bool)->())) {
        
        do {
        
            try self.server.start(port: self.port)
        } catch {
            
            print("Could not start the wrapper server")
            callback(false)
            return
        }
        
        if (self.server.isRunning) {
        
            self.server.route(.GET, "api/1.0/ping") { (.ok, "{\"pong\": true}") }
            self.server.route(.POST, "api/1.0/check_flag", handleFlagCheck)
            
            print("Wrapper server is running at port: ", self.port)
        
            print("FF SDK :: Initializing")
            CfClient.sharedInstance.initialize(
                
                apiKey: self.apiKey,
                configuration: self.configuration,
                target: self.target
            
            ) { [callback] result in
                
                if (CfClient.sharedInstance.isInitialized) {

                    print("FF SDK :: Initialized")
                } else {

                    print("FF SDK :: WAS NOT initialized")
                }

                callback(CfClient.sharedInstance.isInitialized)

            }
        } else {
            
            print("Wrapper server is NOT running")
            callback(false)
        }
    }
    
    public func shutdown() -> Bool {
        
        self.server.stop(immediately: true)
        CfClient.sharedInstance.destroy()
        return !self.server.isRunning && !CfClient.sharedInstance.isInitialized
    }
    
    public func isActive() -> Bool {
        
        return self.server.isRunning && CfClient.sharedInstance.isInitialized
    }
    
    func handleFlagCheck(request: HTTPRequest) -> HTTPResponse {
      
        do {
            
            let decoder = JSONDecoder()
            let check = try decoder.decode(FlagCheck.self, from: request.body)
            print(check)
            
            let key = check.flag_key
            let kind = check.flag_kind
            
            var evaluation: Evaluation?
            
            let clb: (_ result: Evaluation?)->() = { (eval) in
                
                evaluation = eval
            }
            
            switch kind {
                case "boolean":
                    CfClient.sharedInstance.boolVariation(evaluationId: key, clb)
                case "int":
                    CfClient.sharedInstance.numberVariation(evaluationId: key, clb)
                case "string":
                    CfClient.sharedInstance.stringVariation(evaluationId: key, clb)
                case "json":
                    CfClient.sharedInstance.jsonVariation(evaluationId: key, clb)
                default:
                    return HTTPResponse(error: NSError())
            }
            
            let encoder = JSONEncoder()
            let response = FlagCheckResponse(flag_key: key, flag_value: evaluation?.value.stringValue ?? "")
            
            do {
                
                return HTTPResponse(content: String(decoding: try encoder.encode(response), as: UTF8.self))
            } catch {
                
                return HTTPResponse(error: error)
            }
        } catch {
        
            return HTTPResponse(error: error)
        }
    }
}
