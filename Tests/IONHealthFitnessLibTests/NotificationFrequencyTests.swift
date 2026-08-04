import XCTest
@testable import IONHealthFitnessLib

class NotificationFrequencyTests: XCTestCase {
 
    private var storeStub: StubHealthKitStore?
    private var databaseStub: StubBackgroundJobManager?
    private var notificationStub: StubNotificationManager?
    private var healthKitManager: HealthKitManager?
    
    private static let variableToTest: String = "STEPS"
    private static let valueToTest: Double = 10.0
    private static let databaseErrorMessage = "Couldn't fetch database."
    
    private func setupHealthKitStore() {
        storeStub = StubHealthKitStore()
        storeStub?.setDidPermissionsGrantWithoutError(true)
        storeStub?.setAuthorizationStatus(status: .sharingAuthorized)
        storeStub?.didAdvancedQuery = true
        var result = AdvancedQueryResponse()
        result.results = [AdvancedQueryResponseBlock(block: 0, startDate: 0, endDate: 0, values: [NotificationFrequencyTests.valueToTest])]
        storeStub?.advancedQueryResponse = result
    }
    
    private func setupBackgroundJobManager() {
        databaseStub = StubBackgroundJobManager()
        try? databaseStub?.insertBackgroundJobWithNotification(
            comparision: ComparisionOperationEnum.equal.rawValue,
            variable: NotificationFrequencyTests.variableToTest,
            notificationFrequency: (NotificationFrequency.Enum.always.rawValue, 1),
            timeUnit: (TimeUnitEnum.day.rawValue, 1),
            operation: OperationTypeEnum.sum.rawValue,
            value: NotificationFrequencyTests.valueToTest,
            notificationText: ("Header", "Content")
        )
    }
    
    private func setupNotificationManager() {
        notificationStub = StubNotificationManager()
    }
    
    private func setupHealthKitManager() {
        guard let store = storeStub, let backgroundManager = databaseStub, let notificationManager = notificationStub else {
            XCTFail("Couldn't setup all Health Kit Manager properties")
            return
        }
        healthKitManager = HealthKitManager(store: store, backgroundManager: backgroundManager, notificationManager: notificationManager)
    }
    
    private func didSendNotification() -> Bool {
        notificationStub!.didAddRequest = false
        healthKitManager!.verifyBackgroundJobs(variable: NotificationFrequencyTests.variableToTest)
        return notificationStub!.didAddRequest
    }
    
    override func setUpWithError() throws {
        setupHealthKitStore()
        setupBackgroundJobManager()
        setupNotificationManager()
        setupHealthKitManager()
    }
    
    func test_Given_frequencyAlways_When_processingBackgroundJobs_Then_notificationSent() {
        guard let database = databaseStub else {
            XCTFail(Self.databaseErrorMessage)
            return
        }
        
        database.backgroundJobs.values.first?.stubNotificationFrequency = NotificationFrequency.Enum.always.rawValue
        
        XCTAssertTrue(didSendNotification())
        XCTAssertTrue(didSendNotification())
    }
    
    func test_Given_frequencyDay_When_processingBackgroundJobs_Then_notificationNotSent() {
        guard let database = databaseStub else {
            XCTFail(Self.databaseErrorMessage)
            return
        }
        
        database.backgroundJobs.values.first?.stubNotificationFrequency = NotificationFrequency.Enum.day.rawValue
        
        XCTAssertTrue(didSendNotification())
        XCTAssertFalse(didSendNotification())
    }
    
    func test_Given_frequency3Seconds_When_processingBackgroundJobs_Then_notificationSent() {
        guard let database = databaseStub else {
            XCTFail(Self.databaseErrorMessage)
            return
        }
        
        database.backgroundJobs.values.first?.stubNotificationFrequency = NotificationFrequency.Enum.second.rawValue
        database.backgroundJobs.values.first?.stubNotificationFrequencyGrouping = 3
        
        XCTAssertTrue(didSendNotification())
        sleep(1)
        XCTAssertFalse(didSendNotification())
        sleep(1)
        XCTAssertFalse(didSendNotification())
        sleep(1)
        XCTAssertTrue(didSendNotification())
        
    }
    func test_Given_inactiveJob_When_processingBackgroundJobs_Then_notificationNotSent() {
        guard let database = databaseStub else {
            XCTFail(Self.databaseErrorMessage)
            return
        }
        
        database.backgroundJobs.values.first?.stubNotificationFrequency = NotificationFrequency.Enum.always.rawValue
        database.backgroundJobs.values.first?.stubIsActive = false
        
        XCTAssertFalse(didSendNotification())
    }
}
