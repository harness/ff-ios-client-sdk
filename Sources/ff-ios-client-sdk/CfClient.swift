//
//  CfClient.swift
//  ff-ios-client-sdk
//
//  Created by Dusan Juranovic on 13.1.21..
//

import Foundation
///An enum with associated values,  representing possible event types.
/// - `case` onOpen(`String`)
/// - `case` onComplete
/// - `case` onMessage(`Message?`)
/// - `case` onEventListener(`Evaluation?`)
/// - `case` onPolling(`[Evaluation]?`)
public enum EventType: Equatable {
	
    ///Returns only a `String` message that the SSE has been opened
	case onOpen
	///Returns  a `String` message that the SSE has beeen completed.
	case onComplete
	///Returns an empty `Message` object.
	case onMessage(Message?)
	///Returns one `Evaluation?` requested upon received event from the SSE server.
	case onEventListener(Evaluation?)
	///Returns  `[Evaluation]?` on initialization and after SSE has been established.
	case onPolling([Evaluation]?)
	
	enum ComparableType: String {
		case onOpen
		case onComplete
		case onMessage
		case onEventListener
		case onPolling
	}
	
	var comparableType: ComparableType {
		switch self {
			case .onOpen: 			return .onOpen
			case .onComplete: 		return .onComplete
			case .onMessage: 		return .onMessage
			case .onEventListener: 	return .onEventListener
			case .onPolling: 		return .onPolling
		}
	}
	
	static public func ==(lhs: EventType, rhs: EventType) -> Bool {
		return lhs.comparableType.rawValue == rhs.comparableType.rawValue
	}
}

public class CfClient {
	//MARK: - Private properties -
	
	private enum State {
		case onlineStreaming
		case onlinePolling
		case offline
	}
	
	private init(authenticationManager: AuthenticationManagerProtocol = AuthenticationManager(),
				 networkInfoProvider: NetworkInfoProviderProtocol = NetworkInfoProvider()){
		self.authenticationManager = authenticationManager
		self.eventSourceManager = EventSourceManager.shared()
		self.networkInfoProvider = networkInfoProvider
	}
	
	private var lastEventId:String?
	
	///Cache and Storage provider used for in-memory and disk storage.
	///- Defaults to `CfCache` if custom provider is not specified during CfClient initialization.
	///- All providers must adopt `StorageRepositoryProtocol` in order to qualify.
	private var storageSource: StorageRepositoryProtocol?
	
	///JWT received after successfull authentication.
	/// - contains:
	///		- `header`
	///		- `authToken`
	///		- `signature`
	///separated by a `dot` (`.`)
	private var token: String?
    private var cluster: String?
	private var timer: Timer?
	
	///Provides network state
	var networkInfoProvider: NetworkInfoProviderProtocol?
	private var pollingEnabled: Bool = true
	private var apiKey: String = ""
	
	///Tracks the `ready` state of CfClient.
	///Set to `false` on `destroy()` call and `true` on `initialize(apiKey:configuration:target:cache:onCompletion)` call.
	private var ready: Bool = false
    
    private var analyticsManager: AnalyticsManager?
    private var analyticsCache = [String:AnalyticsWrapper]()
	
	//MARK: - Internal properties -
	
	var configuration: CfConfiguration!
	var target: CfTarget!
	var authenticationManager: AuthenticationManagerProtocol!
	var eventSourceManager: EventSourceManagerProtocol!
	var onPollingResultCallback: ((Swift.Result<EventType, CFError>) -> ())?
	
	///Used for cloud communication
	///Lazily instantiated during CfClient `initialize(clientID:config:cache:)` call, after it's dependencies are set.
	lazy var featureRepository = FeatureRepository(
        
        token: self.token,
        cluster: self.cluster,
        storageSource: self.storageSource,
        config: self.configuration,
        target: self.target
    )
	
	//MARK: - Public properties -
	
	struct Static {
		
        fileprivate static var instance: CfClient?
	}
    
	public static var sharedInstance: CfClient {
		if Static.instance == nil {
			Static.instance = CfClient()
		}
		return Static.instance!
	}
	
	func dispose() {
		CfClient.Static.instance = nil
	}
	
	///This flag determines if the `authToken` has been received, indicating that the Authorization has been successful.
	public var isInitialized: Bool = false
	
	//MARK: - Internal methods -
	
	///Connect to the SSE stream if the stream is ready OR continue with already connected stream.
	func connectStream() {
		guard let stream = eventSourceManager else { return }
		if !stream.streamReady {
			stream.connect(lastEventId: self.lastEventId)
		}
	}
	
	///Disconnects the SSE stream.
	func disconnectStream() {
		guard let stream = eventSourceManager else { return }
		stream.disconnect()
	}
	
	//MARK: - Public methods -
	/**
	This method needs to be run first, to initiate authorization.
	 - Parameters:
	   - apiKey: `YOUR_API_KEY`
	   - configuration: `CfConfiguration` to be used for Evaluation fetching
	   - cache: `StorageRepositoryProtocol`. Defaults to CfCache
	   - onCompletion: Optional completion block, should you want to be notified of the authorization `success/failure`
	 - NOTE: In order to use your own cache, you need to wrap your caching solution into a wrapper, that adopts `StorageRepositoryProtocol`.
	 - Tag: initialize
	*/
	public func initialize(
        
        apiKey: String,
        configuration: CfConfiguration,
        target: CfTarget,
        cache: StorageRepositoryProtocol = CfCache(),
        _ onCompletion:((Swift.Result<Void, CFError>)->())? = nil
    
    ) {
		self.configuration = configuration
		self.apiKey = apiKey
		self.target = target
		OpenAPIClientAPI.configPath = configuration.configUrl
		
        let authRequest = AuthenticationRequest(apiKey: apiKey, target: target)
		self.authenticate(authRequest, cache: cache) { (response) in
			
            switch response {
				
                case .failure(let error):
					onCompletion?(.failure(error))
			
                case .success(_):
                    
                    OpenAPIClientAPI.streamPath = configuration.streamUrl
                    self.ready = true
                    onCompletion?(.success(()))
			}
		}
	}
	/**
	Completion block of this method will be called on each SSE response event.
	This method needs to be called in order to get SSE events. Make sure to call [intialize](x-source-tag://initialize) prior to calling this method.
	- Parameters:
		- events: An optional `[String]?`, representing the Events we want to subscribe to. Defaults to `[*]`, which subscribes to all events.
		- onCompletion: Completion block containing `Swift.Result<EventType, CFError>`
		- result:
			- EventType:
				- onOpen
				- onComplete
				- onMessage(`Message?`)
				- onEventListener(`Evaluation?`)
				- onPolling(`[Evaluation]?`)
			- Error: `CFError`
	*/
	public func registerEventsListener(_ events:[String] = ["*"], onCompletion:@escaping(_ result: Swift.Result<EventType, CFError>)->()) {
		guard isInitialized else {return}
		let allKey = CfConstants.Persistance.features(self.configuration.environmentId, self.target.identifier).value
		do {
			let initialEvaluations: [Evaluation]? = try self.featureRepository.storageSource.getValue(forKey: allKey)
			onCompletion(.success(EventType.onPolling(initialEvaluations)))
		} catch {
			print("Could not fetch from cache")
		}
		if self.configuration.streamEnabled {
			
            let parameterConfig = ParameterConfig(
                
                authHeader: [CFHTTPHeaderField.authorization.rawValue:"Bearer \(self.token ?? "")",
															   CFHTTPHeaderField.apiKey.rawValue:self.apiKey],
                cluster: self.cluster!
            )
			self.eventSourceManager.configuration = self.configuration
			self.eventSourceManager.parameterConfig = parameterConfig
			
			if self.eventSourceManager.forceDisconnected {
				self.setupFlowFor(.onlinePolling)
			}
			startStream(events) { (startStreamResult) in
				switch startStreamResult {
					case .failure(let error):
						onCompletion(.failure(error))
					case .success(let eventType):
					onCompletion(.success(eventType))
				}
			}
		} else {
			self.setupFlowFor(.onlinePolling)
		}
		self.onPollingResultCallback = {(result) in
			switch result {
				case .failure(let error):
					onCompletion(.failure(error))
				case .success(let eventType):
					onCompletion(.success(eventType))
			}
		}
		self.registerForNetworkConditionNotifications()
	}
	
	/**
	Fetch `String` `Evaluation` from cache.
	Make sure to call [intialize](x-source-tag://initialize) prior to calling this method.
	If called prior to calling [intialize](x-source-tag://initialize), `defaultValue` will be returned or `nil`, if `defaultValue` was not specified.
	- Parameters:
	   - evaluationId: ID of the `Evaluation` you want to fetch.
	   - target: The account name for which this `Evaluation` is evaluated.
	   - defaultValue: Value to be returned if no such `Evaluation` exists in the cache.
	   - completion: Contains an optional `Evaluation`. `nil` is returned if no such value exists and no `defaultValue` was specified
	   - result: `Evaluation?`
	*/
	public func stringVariation(evaluationId: String, defaultValue: String? = nil, _ completion:@escaping(_ result:Evaluation?)->()) {
		self.fetchIfReady(evaluationId: evaluationId, defaultValue: defaultValue, completion)
	}
	
	/**
	Fetch `Bool` `Evaluation` from cache.
	Make sure to call [intialize](x-source-tag://initialize) prior to calling this method.
	If called prior to calling [intialize](x-source-tag://initialize), `defaultValue` will be returned or `nil`, if `defaultValue` was not specified.
	- Parameters:
	   - evaluationId: ID of the `Evaluation` you want to fetch.
	   - target: The account name for which this `Evaluation` is evaluated.
	   - defaultValue: Value to be returned if no such `Evaluation` exists in the cache.
	   - completion: Contains an optional `Evaluation`. `nil` is returned if no such value exists and no `defaultValue` was specified
	   - result: `Evaluation?`
	*/
	public func boolVariation(evaluationId: String, defaultValue: Bool? = nil, _ completion:@escaping(_ result: Evaluation?)->()) {
		self.fetchIfReady(evaluationId: evaluationId, defaultValue: defaultValue, completion)
	}
	
	/**
	Fetch `Number` `Evaluation` from cache.
	Make sure to call [intialize](x-source-tag://initialize) prior to calling this method.
	If called prior to calling [intialize](x-source-tag://initialize), `defaultValue` will be returned or `nil`, if `defaultValue` was not specified.
	- Parameters:
	   - evaluationId: ID of the `Evaluation` you want to fetch.
	   - target: The account name for which this `Evaluation` is evaluated.
	   - defaultValue: Value to be returned if no such `Evaluation` exists in the cache.
	   - completion: Contains an optional `Evaluation`. `nil` is returned if no such value exists and no `defaultValue` was specified
	   - result: `Evaluation?`
	*/
	public func numberVariation(evaluationId: String, defaultValue:Int? = nil, _ completion:@escaping(_ result: Evaluation?)->()) {
		self.fetchIfReady(evaluationId: evaluationId, defaultValue: defaultValue, completion)
	}
	
	/**
	Fetch `[String:ValueType]` `Evaluation` from cache.
	Make sure to call [intialize](x-source-tag://initialize) prior to calling this method.
	If called prior to calling [intialize](x-source-tag://initialize), `defaultValue` will be returned or `nil`, if `defaultValue` was not specified.
	 - Note:
	 `ValueType` can be one of the following:
	   	- `ValueType.bool(Bool)`
	   	- `ValueType.string(String)`
	   	- `ValueType.int(Int)`
	   	- `ValueType.object([String:ValueType])`
	 - Parameters:
	 	- evaluationId: ID of the `Evaluation` you want to fetch.
	 	- target: The account name for which this `Evaluation` is evaluated.
		- defaultValue: Value to be returned if no such `Evaluation` exists in the cache.
		- completion: Contains an optional `Evaluation`. `nil` is returned if no such value exists and no `defaultValue` was specified
		- result: `Evaluation?`
	*/
	public func jsonVariation(evaluationId: String, defaultValue:[String:ValueType]? = nil, _ completion:@escaping(_ result: Evaluation?)->()) {
		self.fetchIfReady(evaluationId: evaluationId, defaultValue: defaultValue, completion)
	}
	
	/**
	 Clears the occupied resources and shuts down the sdk.
	 After calling this method, the [intialize](x-source-tag://initialize) must be called again. It will also
	 remove any registered event listeners.
	*/
	public func destroy() {
		if self.configuration != nil {
			
            self.pollingEnabled = false
			self.eventSourceManager.destroy()
			self.setupFlowFor(.offline)
			self.configuration.streamEnabled = false
			self.isInitialized = false
			self.lastEventId = nil
			self.onPollingResultCallback = nil
			self.featureRepository.defaultAPIManager = nil
            self.analyticsManager?.destroy()
			self.ready = false
			CfClient.sharedInstance.dispose()
        } else {
			
            Logger.log("destroy() already called. Please reinitialize the SDK.")
		}
	}
	
	//MARK: - Private methods -
	
	/// Initializes authentication and fetches initial Evaluations from the cloud, after successful  authorization.
	/// - Parameters:
	///   - authRequest: `AuthenticationRequest`, containing `apiKey` property.
	///   - cache: Cache to be used. Defaults to internal `CfCache`.
	///   - onCompletion: Completion block containing `Swift.Result<Void, CFError>?`
	///	  - result:
	///	  	- Void: ()
	///	  	- Error: `CFError`
	private func authenticate(_ authRequest: AuthenticationRequest, cache: StorageRepositoryProtocol, onCompletion:@escaping(_ result: Swift.Result<Void, CFError>)->()) {
		authenticationManager.authenticate(authenticationRequest: authRequest, apiResponseQueue: .main) { [weak self] (response, error) in
			guard let self = self else {return}
			guard error == nil else {
				onCompletion(.failure(error!))
				self.isInitialized = false
				Logger.log("AUTHENTICATION FAILURE")
				return
			}
			Logger.log("AUTHENTICATION SUCCESS")
			
			//Set storage to provided cache or CfCache by default
			self.storageSource = cache
			
			//Extract info from retrieved JWT
			let dict = JWTDecoder().decode(jwtToken: response!.authToken)
			let project = CfProject(dict:dict ?? [:])
			
            self.isInitialized = true
			self.configuration.environmentId = project.environment
			self.token = response!.authToken
            self.cluster = project.clusterIdentifier
			
			//Assign retrieved values to lazily instantiated `featureRepository`
			self.featureRepository.token = self.token!
			self.featureRepository.storageSource = self.storageSource!
			self.featureRepository.config = self.configuration
			self.featureRepository.target = self.target
            self.featureRepository.cluster = self.cluster!
			
			// Initial getEvaluations to be stored in cache
			self.featureRepository.getEvaluations(onCompletion: { [weak self] (result) in
				guard let self = self else {return}
				let allKey = CfConstants.Persistance.features(self.configuration.environmentId, self.target.identifier).value
				switch result {
					case .success(let evaluations):
						do {
							try self.storageSource?.saveValue(evaluations, key: allKey)
							onCompletion(.success(()))
						} catch {
							//If saving to cache fails, pass success for authorization and continue
							onCompletion(.success(()))
							print("Could not save to cache")
						}
					case .failure(let error):
						onCompletion(.failure(error))
				}
			})
		}
	}
	
	private func fetchIfReady(
        
        evaluationId: String,
        defaultValue:Any? = nil,
        _ completion:@escaping(_ result: Evaluation?)->()
    
    ) {
		
        var valueType: ValueType?
		switch defaultValue {
			case is String: valueType = ValueType.string(defaultValue as! String)
			case is Bool: valueType = ValueType.bool(defaultValue as! Bool)
			case is Int: valueType = ValueType.int(defaultValue as! Int)
			case is [String:ValueType]: valueType = ValueType.object(defaultValue as! [String:ValueType])
			default: valueType = nil
		}
		if ready {
			self.getEvaluationById(forKey: evaluationId, target: target.identifier, defaultValue: valueType, completion: completion)
		} else {
			guard let defaultValue = valueType else {
				completion(nil)
				return
			}
			completion(Evaluation(flag: evaluationId, identifier: evaluationId, value: defaultValue))
		}
	}
	
	///Make sure to call [initialize](x-source-tag://initialize) prior to calling this method.
	private func getEvaluationById(
        
        forKey key: String,
        target: String,
        defaultValue: ValueType? = nil,
        completion:@escaping(Evaluation?)->()
    
    ) {
		self.featureRepository.getEvaluationById(key, target: target, useCache: true) { (result) in
			
            switch result {
				case .failure(_):
					guard let defaultValue = defaultValue else {
						
                        completion(nil)
						return
					}
					
                    let evaluation = Evaluation(flag:key, identifier: key, value: defaultValue)
                    self.pushToAnalyticsQueue(key: key, evaluation: evaluation)
                    completion(evaluation)
				
            case .success(let evaluation):
					
                    self.pushToAnalyticsQueue(key: key, evaluation: evaluation)
                    completion(evaluation)
			}
		}
	}
    
    private func pushToAnalyticsQueue(key: String, evaluation: Evaluation) {
        
        if (!evaluation.isValid()) {
            
            Logger.log("Evaluation will not be pushed to analytics queue, invalid: \(evaluation)")
            return
        }
        
        let manager = self.getAnalyticsManager()
            
        if (self.configuration.analyticsEnabled && self.target.isValid()) {

            let variation = Variation(

                identifier: evaluation.identifier,
                value: evaluation.value.stringValue ?? "",
                name: key
            )
            
            manager.push(
                
                target: self.target,
                variation: variation
            )
        }
    }
	
	// Setup event observing flow based on `State`
	private func setupFlowFor(_ state: State) {
		switch state {
			case .offline:
				self.stopPolling()
				self.disconnectStream()
			case .onlinePolling:
				self.disconnectStream()
				if self.pollingEnabled {
					self.startPolling { (result) in
						switch result {
							case .failure(let error):
								self.onPollingResultCallback?(.failure(error))
							case .success(let eventType):
								self.onPollingResultCallback?(.success(eventType))
						}
					}
				} else {
					Logger.log("POLLING disabled due to destroy() call")
				}
			case .onlineStreaming:
				self.stopPolling()
				self.startStreaming()
		}
	}
	
	//Setup network condition observing
	private func registerForNetworkConditionNotifications() {
		if self.networkInfoProvider?.isReachable == true {
			if self.configuration.streamEnabled {
				self.setupFlowFor(.onlineStreaming)
			}
		}
		self.networkInfoProvider?.networkStatus { [weak self] (isOnline) in
			guard let self = self else {return}
			self.pollingEnabled = isOnline
			if isOnline {
				if self.configuration.streamEnabled {
					self.setupFlowFor(.onlineStreaming)
				}
				Logger.log("Polling ENABLED due to NETWORK AVAILABLE")
			} else {
				self.setupFlowFor(.offline)
				Logger.log("Polling/Streaming DISABLED due to NO NETWORK")
			}
		}
	}
	
	//MARK: STREAMING
	/// Initiates SSE listening
	/// - Parameters:
	///   - events: Optional `[String]`
	///   - onCompletion: completion block containing `Swift.Result<EventType, CFError>`
	private func startStream(_ events:[String], onCompletion:@escaping(Swift.Result<EventType, CFError>)->()) {
		registerStreamCallbacks(environmentId: self.configuration!.environmentId, events: events) { (eventType, error) in
			guard error == nil else {
				onCompletion(.failure(error!))
				return
			}
			onCompletion(.success(eventType))
		}
	}
	
	//Handle SSE callbacks
	private func registerStreamCallbacks(environmentId: String, events:[String], onEvent:@escaping(EventType, CFError?)->()) {
		//ON OPEN
		eventSourceManager.onOpen() {
			Logger.log("SSE connection has been opened")
			onEvent(EventType.onOpen, nil)
            
			self.featureRepository.getEvaluations(onCompletion: { (result) in
				switch result {
					case .success(let evaluations):
						onEvent(EventType.onPolling(evaluations), nil)
					case .failure(_):
						//If error occurs while fetching evaluations, we just ignore this failure and continue with SSE.
						break
				}
			})
			self.setupFlowFor(.onlineStreaming)
		}
		
		//ON COMPLETE
		eventSourceManager.onComplete() {(statusCode, retry, error) in
			self.setupFlowFor(.onlinePolling)
			guard error == nil else {
				
                NSLog("Api, eventSourceManager.onComplete: \(error!)")
                onEvent(EventType.onComplete, error)
				return
			}
            
            NSLog("Api, eventSourceManager.onComplete: \(statusCode!)")
			onEvent(EventType.onComplete, nil)
		}
		
		//ON MESSAGE
		eventSourceManager.onMessage() {(id, event, data) in
			print("Got message with empty data \(Date())")
			guard let stringData = data else {
				onEvent(EventType.onMessage(Message(event: "message", domain: "", identifier: "", version: 0)), nil)
				return
			}
			do {
				let data = stringData.data(using: .utf8)
				let decoded = try JSONDecoder().decode(Message.self, from: data!)
				onEvent(EventType.onMessage(decoded), nil)
			} catch {
				onEvent(EventType.onMessage(nil), CFError.parsingError)
			}
		}
		
		for event in events {
			//ON EVENT
			eventSourceManager.addEventListener(event) { [weak self] (id, event, data) in
				guard let self = self else {return}
				Logger.log("An Event has been received")
				guard let stringData = data else {
					onEvent(EventType.onEventListener(nil), CFError.noDataError)
					return
				}
				do {
					
                    let data = stringData.data(using: .utf8)
					let decoded = try JSONDecoder().decode(Message.self, from: data!)
                    
                    Logger.log("Message: \(decoded)")
                    
					self.lastEventId = decoded.event
					self.featureRepository.getEvaluationById(decoded.identifier ?? "", target: self.target.identifier, useCache: false, onCompletion: { (result) in
						switch result {
							case .failure(let error): onEvent(EventType.onEventListener(nil), error)
							case .success(let evaluation): onEvent(EventType.onEventListener(evaluation), nil)
						}
					})
				} catch {
					onEvent(EventType.onEventListener(nil), CFError.parsingError)
				}
			}
		}
	}
	
	//MARK: STREAMING/POLLING SWITCH METHODS
	private func startStreaming(_ events:[String]? = nil) {
		Logger.log("POLLING stopped / STREAM starting")
		self.connectStream()
	}
	
	private func stopPolling() {
		if self.timer != nil {
			self.timer!.invalidate()
			self.timer = nil
		}
	}
	
	//Initiate polling sequence and retry SSE connection if SSE is enabled, every `pollingInterval`
	private func startPolling(onCompletion:@escaping(Swift.Result<EventType, CFError>)->()) {
		Logger.log("Try reconnecting to STREAM with retry interval of \(self.configuration.pollingInterval) seconds")
		if timer == nil {
			DispatchQueue.main.async {
				self.timer = Timer.scheduledTimer(withTimeInterval: self.configuration.pollingInterval, repeats: true) {[weak self] _ in
					if self?.configuration.streamEnabled == true {
						self?.setupFlowFor(.onlineStreaming)
					}
                    
					self?.featureRepository.getEvaluations() { (result) in
						switch result {
							case .failure(let error):
								onCompletion(.failure(error))
							case .success(let evaluations):
								onCompletion(.success(EventType.onPolling(evaluations)))
						}
					}
				}
			}
		}
	}
    
    private func getAnalyticsManager() -> AnalyticsManager {
        
        if let manager = analyticsManager {
            
            return manager
        }
        
        let manager = AnalyticsManager(
        
            environmentID: self.configuration.environmentId,
            cluster: self.cluster  ?? "",
            authToken: self.token ?? "",
            config: self.configuration,
            cache: &self.analyticsCache
        )
        
        self.analyticsManager = manager
        return manager
    }
}
