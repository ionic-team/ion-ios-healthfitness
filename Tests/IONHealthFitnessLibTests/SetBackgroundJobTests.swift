import XCTest
@testable import IONHealthFitnessLib

class SetBackgroundJobTests: XCTestCase {

    func test_Given_InvalidVariable_When_SettingBackgroundJob_Then_VariableNotAvailableError() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.setBackgroundJob(for: testSubject, and: "Test") { result in
            switch result {
            case .success:
                XCTFail(DummyData.didNotThrowError)
            case .failure(let error):
                XCTAssertEqual(error as? HealthKitErrors, .variableNotAvailable)
            }
        }
    }

    func test_Given_VariableWithoutPermissions_When_SettingBackgroundJob_Then_VariableNotAuthorizedError() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .notDetermined)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.setBackgroundJob(for: testSubject, and: "STEPS") { result in
            switch result {
            case .success:
                XCTFail(DummyData.didNotThrowError)
            case .failure(let error):
                XCTAssertEqual(error as? HealthKitErrors, .variableNotAuthorized)
            }
        }
    }
    
    func test_Given_ExistentBackgroundJob_When_SettingBackgroundJob_Then_BackgroundJobAlreadyExistsError() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        storeStub.setDidEnableBackgroundJobDelivery(true)
        let backgroundStub = StubBackgroundJobManager()
        backgroundStub.setBackgroundJobExists(true)
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.setBackgroundJob(for: testSubject, and: "STEPS") { result in
            switch result {
            case .success:
                XCTFail(DummyData.didNotThrowError)
            case .failure(let error):
                XCTAssertEqual(error as? HealthKitErrors, .backgroundJobAlreadyExists)
            }
        }
    }
    
    func test_Given_ValidBackgroundJob_When_SettingBackgroundJob_Then_Success() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        storeStub.setDidAdvancedQuery(true)
        storeStub.setDidEnableBackgroundJobDelivery(true)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.setBackgroundJob(for: testSubject, and: "STEPS") { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail("Test failed")
            }
        }
    }
}

private extension SetBackgroundJobTests {
    struct DummyData {
        static let day = "DAY"
        static let frequency = 1
        static let jobFrequency = "IMMEDIATE"
        static let condition = "HIGHER"
        static let value: Double = 100
        static let notificationText = "Test notification"
        static let didNotThrowError = "Did not throw error."
    }
    
    func setBackgroundJob(for testSubject: HealthKitManager, and variable: String, completion: @escaping (Result<Bool?, Error>) -> Void) {
        testSubject.setBackgroundJob(
            variable: variable,
            timeUnit: (DummyData.day, DummyData.frequency),
            notificationFrequency: (DummyData.day, DummyData.frequency),
            jobFrequency: DummyData.jobFrequency,
            condition: DummyData.condition,
            value: DummyData.value,
            notificationText: (DummyData.notificationText, DummyData.notificationText),
            completion: completion
        )
    }
}
