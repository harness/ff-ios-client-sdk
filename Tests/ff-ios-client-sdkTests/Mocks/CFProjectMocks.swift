//
//  CfProjectMocks.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 6.2.21..
//

struct CfProjectMocks {
    static var projectInitDict: [String: Any] {
        var dict: [String: Any]   = [:]
        dict["projectIdentifier"]       = "projectIdentifier_value"
        dict["organization"]            = "organization_value"
        dict["project"]                 = "project_value"
        dict["environmentIdentifier"]   = "environmentIdentifier_value"
        dict["environment"]             = "environment_value"
        dict["accountID"]               = "accountID_value"
        dict["clusterIdentifier"]       = "clusterIdentifier_value"
        return dict
    }
}
