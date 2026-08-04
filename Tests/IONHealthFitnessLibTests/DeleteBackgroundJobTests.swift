//
//  DeleteBackgroundJobTests.swift
//  IONHealthFitnessLibTests
//
//  Created by Alexandre Jacinto on 21/12/2021.
//

import XCTest
@testable import IONHealthFitnessLib

class DeleteBackgroundJobsTests: XCTestCase {
    
    func test_Given_NonExistentBackgroundJob_When_DeletingBackgroundJob_Then_BackgroundJobDoesNotExist() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        let backgroundStub = StubBackgroundJobManager()
        backgroundStub.setBackgroundJobExists(false)
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        testSubject.deleteBackgroundJobs(id: 1) { error in
            if let error = error as? HealthKitErrors {
                XCTAssertEqual(error, .backgroundJobNotFound)
            } else {
                XCTFail("Did not throw error")
            }
        }
    }
    
    func test_Given_ExistentBackgroundJob_When_DeletingBackgroundJob_Then_UnsubscribingError() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        let backgroundStub = StubBackgroundJobManager()
        backgroundStub.setBackgroundJobExists(true)
        backgroundStub.setUnsubscribeError(true)
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        testSubject.deleteBackgroundJobs(id: 1) { error in
            if let error = error as? HealthKitErrors {
                XCTAssertEqual(error, .unsubscribeError)
            } else {
                XCTFail("Did not throw error")
            }
        }
    }
    
    func test_Given_ExistentBackgroundJob_When_DeletingBackgroundJob_Then_Success() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        let backgroundStub = StubBackgroundJobManager()
        backgroundStub.setBackgroundJobExists(true)
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        testSubject.deleteBackgroundJobs(id: 1) { error in
            XCTAssertEqual(error, nil)
        }
    }
}
