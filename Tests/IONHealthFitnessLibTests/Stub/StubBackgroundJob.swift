//
//  StubBackgroundJob.swift
//  IONHealthFitnessLibTests
//
//  Created by Alexandre Jacinto on 21/12/2021.
//

import Foundation
@testable import IONHealthFitnessLib

class StubBackgroundJob: IONHealthFitnessLib.BackgroundJob {
    
    convenience init(
        id: Int64,
        variable: String,
        comparison: String,
        value: Double,
        isActive: Bool,
        notification: StubNotification,
        notificationFrequency: String,
        notificationFrequencyGrouping: Int64,
        lastNotificationTimestamp: Date,
        timeUnit: String,
        timeUnitGrouping: Int64
    ) {
        self.init()
        self.stubId = id
        self.stubVariable = variable
        self.stubComparison = comparison
        self.stubValue = value
        self.stubIsActive = isActive
        self.stubNotification = notification
        self.stubNotificationFrequency = notificationFrequency
        self.stubNotificationFrequencyGrouping = notificationFrequencyGrouping
        self.stubLastNotificationTimestamp = lastNotificationTimestamp
        self.stubTimeUnit = timeUnit
        self.stubTimeUnitGrouping = timeUnitGrouping
    }
    
    var stubId: Int64 = 0
    override var id: Int64 {
        get {
            return stubId
        }
        set {}
    }
    
    var stubVariable: String?
    override var variable: String? {
        get {
            return stubVariable
        }
        set {}
    }
    
    var stubComparison: String?
    override var comparision: String? {
        get {
            return stubComparison
        }
        set {}
    }
    
    var stubValue: Double = 0
    override var value: Double {
        get {
            return stubValue
        }
        set {}
    }
    
    var stubIsActive: Bool = true
    override var isActive: Bool {
        get {
            return stubIsActive
        }
        set {}
    }
    
    var stubNotification: StubNotification?
    override var notification: IONHealthFitnessLib.Notification? {
        get {
            return stubNotification
        }
        set {}
    }

    var stubNotificationFrequency: String?
    override var notificationFrequency: String? {
        get {
            return stubNotificationFrequency
        }
        set {}
    }
    
    var stubNotificationFrequencyGrouping: Int64 = 1
    override var notificationFrequencyGrouping: Int64 {
        get {
            return stubNotificationFrequencyGrouping
        }
        set {}
    }
    
    var stubLastNotificationTimestamp: Date?
    override var lastNotificationTimestamp: Date? {
        get {
            return stubLastNotificationTimestamp
        }
        set {}
    }
    
    var stubTimeUnit: String?
    override var timeUnit: String? {
        get {
            return stubTimeUnit
        }
        set {}
    }
    
    var stubTimeUnitGrouping: Int64 = 1
    override var timeUnitGrouping: Int64 {
        get {
            return stubTimeUnitGrouping
        }
        set {}
    }
    
}
