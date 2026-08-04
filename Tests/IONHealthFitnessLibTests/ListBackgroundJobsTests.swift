import XCTest
@testable import IONHealthFitnessLib

class ListBackgroundJobsTests: XCTestCase {
    
    func test_Given_NoBackgroundJobs_When_ListingBackgroundJobs_Then_Success() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        storeStub.setDidAdvancedQuery(true)
        storeStub.setDidEnableBackgroundJobDelivery(true)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        let result = testSubject.listBackgroundJobs()
        XCTAssertEqual(result?.results?.isEmpty, true)
        XCTAssertEqual(result?.results?.count, 0)
    }
    
    func test_Given_ExistentBackgroundJob_When_ListingBackgroundJobs_Then_Success() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        storeStub.setDidAdvancedQuery(true)
        storeStub.setDidEnableBackgroundJobDelivery(true)
        let backgroundStub = StubBackgroundJobManager()
        backgroundStub.setHasBackgroundJobs(true)
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        let result = testSubject.listBackgroundJobs()
        XCTAssertEqual(result?.results?.isEmpty, false)
        XCTAssertEqual(result?.results?.count, 1)
    }
    
    func test_Given_ExistentBackgroundJobs_When_ListingBackgroundJobs_Then_Success() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        storeStub.setDidAdvancedQuery(true)
        storeStub.setDidEnableBackgroundJobDelivery(true)
        let backgroundStub = StubBackgroundJobManager()
        backgroundStub.setHasBackgroundJobs(true)
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.setBackgroundJob(for: testSubject, and: "STEPS")
        self.setBackgroundJob(for: testSubject, and: "HEART_RATE")
        self.setBackgroundJob(for: testSubject, and: "WEIGHT")
        
        let result = testSubject.listBackgroundJobs()
        XCTAssertEqual(result?.results?.isEmpty, false)
        XCTAssertEqual(result?.results?.count, 3)
    }
}

private extension ListBackgroundJobsTests {
    struct DummyData {
        static let day = "DAY"
        static let frequency = 1
        static let jobFrequency = "IMMEDIATE"
        static let condition = "HIGHER"
        static let value: Double = 100
        static let notificationText = "Test notification"
    }
    
    func setBackgroundJob(for testSubject: HealthKitManager, and variable: String) {
        testSubject.setBackgroundJob(
            variable: variable,
            timeUnit: (DummyData.day, DummyData.frequency),
            notificationFrequency: (DummyData.day, DummyData.frequency),
            jobFrequency: DummyData.jobFrequency,
            condition: DummyData.condition,
            value: DummyData.value,
            notificationText: (DummyData.notificationText, DummyData.notificationText)
        ) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail("Test failed")
            }
        }
    }
}
