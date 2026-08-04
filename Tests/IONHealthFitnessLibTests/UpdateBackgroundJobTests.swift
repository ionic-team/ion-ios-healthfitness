import XCTest
@testable import IONHealthFitnessLib

class UpdateBackgroundJobsTests: XCTestCase {
    func test_Given_NonExistentBackgroundJob_When_UpdatingBackgroundJob_Then_BackgroundJobDoesNotExist() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        let backgroundStub = StubBackgroundJobManager()
        backgroundStub.setBackgroundJobExists(false)
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.updateBackgroundJob(for: testSubject) { result in
            switch result {
            case .success:
                XCTFail("Did not throw error")
            case .failure(let error):
                XCTAssertEqual(error as? HealthKitErrors, .backgroundJobNotFound)
            }
        }
    }
    
    func test_Given_ExistentBackgroundJob_When_UpdatingBackgroundJob_Then_Success() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        let backgroundStub = StubBackgroundJobManager()
        backgroundStub.setBackgroundJobExists(true)
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.updateBackgroundJob(for: testSubject) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail("Test failed")
            }
        }
    }
}

// MARK: Private Methods
private extension UpdateBackgroundJobsTests {
    struct DummyData {
        static let id: Int64 = 1
        static let notificationFrequency = "DAY"
        static let notificationFrequencyGrouping = 1
        static let condition = "HIGHER"
        static let value: Double = 100
        static let notificationText = "Test"
        static let isActive = true
    }
    
    func updateBackgroundJob(for testSubject: HealthKitManager, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        testSubject.updateBackgroundJob(
            id: DummyData.id,
            notificationFrequency: (DummyData.notificationFrequency, DummyData.notificationFrequencyGrouping),
            condition: DummyData.condition,
            value: DummyData.value,
            notificationText: (DummyData.notificationText, DummyData.notificationText),
            isActive: DummyData.isActive,
            completion: completionHandler
        )
    }
}
