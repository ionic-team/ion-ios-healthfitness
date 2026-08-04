//
//  StubNotification.swift
//  IONHealthFitnessLibTests
//
//  Created by Alexandre Jacinto on 21/12/2021.
//

import Foundation
@testable import IONHealthFitnessLib

class StubNotification: IONHealthFitnessLib.Notification {
    
    convenience init(id: Int64, title: String, body: String) {
        self.init()
        self.stubId = id
        self.stubTitle = title
        self.stubBody = body
    }
    
    var stubId: Int64 = 0
    override var id: Int64 {
        get {
            return stubId
        }
        set {}
    }
    
    var stubTitle: String?
    override var title: String? {
        get {
            return stubTitle
        }
        set {}
    }
    
    var stubBody: String?
    override var body: String? {
        get {
            return stubBody
        }
        set {}
    }

}
