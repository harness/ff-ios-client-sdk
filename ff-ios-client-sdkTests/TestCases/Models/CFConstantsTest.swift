//
//  CFConstantsTest.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 6.2.21..
//

import XCTest
@testable import ff_ios_client_sdk


class CFConstantsTest: XCTestCase {
    var sut: CFConstants.Persistance!
    
    override func setUp() {
        super.setUp()

    }
    override func tearDown() {
        super.tearDown()
    }
    
    func testFeatureKey() {
		// Given
		var feature = sut
		
		// When
        feature = .feature("envID", "target", "feature")
		
		// Then
		XCTAssertEqual(feature!.value, "envID_target_feature")
    }
	
	func testFeaturesKey() {
		// Given
		var features = sut
		
		// When
		features = .features("envID", "target")
		
		// Then
		XCTAssertEqual(features!.value, "envID_target_features")
	}
    
}
