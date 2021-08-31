import UIKit

import ff_ios_client_sdk

class ViewController: UIViewController {
    
    /**
     * Port to be used by local server instance.
     */
    private var serverPort = 4000

    /**
     * API key used to initialize the SDK.
     */
    private var sdkKey = "YOUR_SDK_KEY"

    /**
     * Enable SSE streaming.
     */
    private var enableStreaming = true

    /**
     * SDK event URL to be used.
     */
    private var eventUrl = ""

    /**
     * SDK base URL to be used.
     */
    private var sdkBaseUrl = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Take the values from the environment:
        self.eventUrl = "https://events.ff.harness.io/api/1.0"
        self.sdkBaseUrl = "https://config.ff.harness.io/api/1.0"
        self.sdkKey = "23fdbf76-8b71-404f-b69c-de07a8c2a4a4"
        self.enableStreaming = true
        
        let config = CfConfiguration.builder()
            .setStreamEnabled(self.enableStreaming)
            .setConfigUrl(self.sdkBaseUrl)
            .setEventUrl(self.sdkBaseUrl)
            .setStreamUrl(self.eventUrl)
            .setAnalyticsEnabled(true)
            .setPollingInterval(60)
            .build()
        
        let server = WrapperServer(
        
            port: self.serverPort,
            apiKey: self.sdkKey,
            
            target: CfTarget
                .builder()
                .setName("ios_test_wrapper")
                .setIdentifier("ios_test_wrapper")
                .setAnonymous(false)
                .build(),
            
            configuration: config
        )
        
        print("Test wrapper server will be initialized")
        server.initialize() { success in
            
            if (success) {
                
                print("Test wrapper server has been initialized")
            } else {
                
                print("Test wrapper server HAS NOT been initialized")
            }
        }
    }
}

