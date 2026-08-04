import XCTest
@testable import IONHealthFitnessLib

class OSHealthKitTestsTests: XCTestCase {
    
    func test_Given_PermissionsNotGranted_When_RequestingPermissions_Then_SomeError () throws {
        let storeStub = StubHealthKitStore()
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.authorizeHealthKit(for: testSubject, variable: DummyData.stepsVariable) { _, error in
            if let error = error as? HealthKitErrors {
                XCTAssertEqual(error, .authorizationError)
            } else {
                XCTFail(DummyData.didNotThrowError)
            }
        }
    }
    
    func test_Given_PermissionsNotGranted_When_RequestingPermissions_UserGrants_Then_Success() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setDidPermissionsGrantWithoutError(true)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.authorizeHealthKit(for: testSubject, variable: DummyData.stepsVariable) { authorized, error in
            if let error = error {
                XCTFail(error.localizedDescription)
            } else if authorized {
                XCTAssertEqual(authorized, true)
            }
        }
    }
    
    // MARK: - Permissions Tests
    func test_Given_InvalidVariable_When_RequestingPermissions_Then_VariableNotAvailableError() throws {
        let storeStub = StubHealthKitStore()
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.authorizeHealthKit(for: testSubject, variable: DummyData.invalidVariable) { _, error in
            if let error = error as? HealthKitErrors {
                XCTAssertEqual(error, .variableNotAvailable)
            } else {
                XCTFail(DummyData.didNotThrowError)
            }
        }
    }
    
    // MARK: - WriteData Tests
    func test_Given_InvalidVariable_When_WritingData_Then_VariableNotAvailableError() throws {
        let storeStub = StubHealthKitStore()
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.writeData(for: testSubject, variable: DummyData.invalidVariable) { inner in
            do {
                _ = try inner()
                XCTFail(DummyData.didNotThrowError)
            } catch let error {
                XCTAssertEqual(error as? HealthKitErrors, .variableNotAvailable)
            }
        }
    }
    
    func test_Given_SharingDeniedVariable_When_WritingData_Then_VariableHasWriteDeniedError() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingDenied)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.writeData(for: testSubject, variable: DummyData.stepsVariable) { inner in
            do {
                _ = try inner()
                XCTFail(DummyData.didNotThrowError)
            } catch let error {
                XCTAssertEqual(error as? HealthKitErrors, .variableHasWriteDenied)
            }
        }
    }
    
    func test_Given_ValidVariableValidValue_When_WritingData_Then_Success() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        storeStub.setDidWriteSteps(true)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.writeData(for: testSubject, variable: DummyData.bodyFatPercentageVariable) { inner in
            do {
                _ = try inner()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func test_Given_ValidVariableValidValue_When_WritingData_Then_SomeError() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.writeData(for: testSubject, variable: DummyData.bodyFatPercentageVariable) { inner in
            do {
                _ = try inner()
                XCTFail(DummyData.didNotThrowError)
            } catch let error {
                XCTAssertEqual(error as? HealthKitErrors, .errorWhileWriting)
            }
        }
    }
    
    // MARK: SimpleQuery
    func test_Given_ValidVariable_When_SimpleQuery_Then_SomeError() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.performAdvancedQuery(
            for: testSubject, variable: DummyData.stepsVariable, date: (Date.distantPast, Date()), DummyData.sumOperation, isMostRecent: true
        ) { _, error in
            if let error = error as? HealthKitErrors {
                XCTAssertEqual(error, .errorWhileReading)
            } else {
                XCTFail(DummyData.didNotThrowError)
            }
        }
    }
    
    func test_Given_ValidVariable_When_SimpleQuery_Then_Success() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        storeStub.setDidAdvancedQuery(true)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.performAdvancedQuery(
            for: testSubject, variable: DummyData.stepsVariable, date: (Date.distantPast, Date()), DummyData.sumOperation, isMostRecent: true
        ) { _, error in
            XCTAssertNil(error)
            
        }
    }
    
    func test_Given_InvalidVariable_When_SimpleQuery_Then_VariableNotAvailableError() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .notDetermined)
        storeStub.setDidAdvancedQuery(true)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.performAdvancedQuery(
            for: testSubject, variable: DummyData.invalidVariable, date: (Date.distantPast, Date()), DummyData.sumOperation, isMostRecent: true
        ) { _, error in
            if let error = error as? HealthKitErrors {
                XCTAssertEqual(error, .variableNotAvailable)
            } else {
                XCTFail(DummyData.didNotThrowError)
            }
        }
    }
    
    func test_Given_VariableWithoutPermissions_When_SimpleQuery_Then_VariableNotAuthorizedError() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .notDetermined)
        storeStub.setDidAdvancedQuery(true)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.performAdvancedQuery(
            for: testSubject, variable: DummyData.stepsVariable, date: (Date.distantPast, Date()), DummyData.sumOperation, isMostRecent: true
        ) { _, error in
            if let error = error as? HealthKitErrors {
                XCTAssertEqual(error, .variableNotAuthorized)
            } else {
                XCTFail(DummyData.didNotThrowError)
            }
        }
    }
    
    // MARK: AdvancedQuery Tests
    func test_Given_ValidVariable_When_AdvancedQuery_Then_Success() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        storeStub.setDidAdvancedQuery(true)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.performAdvancedQuery(
            for: testSubject, variable: DummyData.heartRateVariable, date: (Date(), Date()), DummyData.averageOperation, isMostRecent: false
        ) { _, error in
            XCTAssertNil(error)
        }
    }
    
    func test_Given_InvalidOperation_When_AdvancedQuery_Then_OperationNotAllowedError() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.performAdvancedQuery(
            for: testSubject, variable: DummyData.heartRateVariable, date: (Date(), Date()), DummyData.sumOperation, isMostRecent: false
        ) { _, error in
            if let error = error as? HealthKitErrors {
                XCTAssertEqual(error, .operationNotAllowed)
            } else {
                XCTFail(DummyData.didNotThrowError)
            }
        }
    }
    
    func test_Given_InvalidVariable_When_AdvancedQuery_Then_VariableNotAvailableError() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.performAdvancedQuery(
            for: testSubject, variable: DummyData.invalidVariable, date: (Date(), Date()), DummyData.sumOperation, isMostRecent: false
        ) { _, error in
            if let error = error as? HealthKitErrors {
                XCTAssertEqual(error, .variableNotAvailable)
            } else {
                XCTFail(DummyData.didNotThrowError)
            }
        }
    }
    
    // MARK: Workout Advanced Query Tests
    func test_Given_WorkoutTypeNotAuthorised_When_QueryingWorkoutsAdvancedQuery_Then_WorkoutNotAuthorizedError() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .notDetermined)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.performWorkoutAdvancedQuery(
            for: testSubject, workoutTypeVariableDictionary: WorkoutTypeVariableDictionary(), date: (Date(), Date())
        ) { _, error in
            if let error = error as? HealthKitErrors {
                XCTAssertEqual(error, .workoutTypeNotAuthorized)
            } else {
                XCTFail(DummyData.didNotThrowError)
            }
        }
    }
    
    func test_Given_WorkoutTypeNotAvailable_When_QueryingWorkoutsAdvancedQuery_Then_WorkoutNotAvailableError() throws {
        let storeStub = StubHealthKitStore()
        storeStub.setAuthorizationStatus(status: .sharingAuthorized)
        let backgroundStub = StubBackgroundJobManager()
        let notificationStub = StubNotificationManager()
        
        let testSubject = HealthKitManager(store: storeStub, backgroundManager: backgroundStub, notificationManager: notificationStub)
        self.performWorkoutAdvancedQuery(
            for: testSubject, workoutTypeVariableDictionary: WorkoutTypeVariableDictionary(), date: (Date(), Date())
        ) { _, error in
            if let error = error as? HealthKitErrors {
                XCTAssertEqual(error, .workoutTypeNotAvailable)
            } else {
                XCTFail(DummyData.didNotThrowError)
            }
        }
    }
}

private extension OSHealthKitTestsTests {
    struct DummyData {
        static let invalidVariable = "TEST"
        static let stepsVariable = "STEPS"
        static let bodyFatPercentageVariable = "BODY_FAT_PERCENTAGE"
        static let heartRateVariable = "HEART_RATE"
        
        static let sumOperation = "SUM"
        static let averageOperation = "AVERAGE"
        
        static let didNotThrowError = "Did not throw error."
    }
    
    func authorizeHealthKit(for manager: HealthKitManager, variable: String, completion: @escaping (Bool, NSError?) -> Void) {
        let customPermissions = "[{\"Variable\":\"\(variable)\",\"AccessType\":\"READ\"}]"
        let commonObject = "{\"IsActive\":false,\"AccessType\":\"\"}"
        let variableStruct = VariableStruct(
            allVariables: commonObject,
            fitnessVariables: commonObject,
            healthVariables: commonObject,
            profileVariables: commonObject,
            workoutVariables: commonObject
        )
        
        manager.authorizeHealthKit(customPermissions: customPermissions, variable: variableStruct, completion: completion)
    }
    
    func writeData(for manager: HealthKitManager, variable: String, completion: @escaping (@escaping () throws -> HealthKitErrors?) -> Void) {
        manager.writeData(variable: variable, value: 10, completion: completion)
    }
    
    func performAdvancedQuery(for manager: HealthKitManager, variable: String, date: (start: Date, end: Date), _ operationType: String, isMostRecent: Bool, completion: @escaping (AdvancedQueryResponse?, NSError?) -> Void) {
        manager.advancedQuery(
            variable: variable,
            startDate: date.start,
            endDate: date.end,
            timeUnit: "DAY",
            operationType: operationType,
            mostRecent: isMostRecent,
            timeUnitLength: 0,
            completion: completion
        )
    }
    
    func performWorkoutAdvancedQuery(
        for manager: HealthKitManager,
        workoutTypeVariableDictionary: WorkoutTypeVariableDictionary,
        date: (start: Date, end: Date),
        _ completion: @escaping (WorkoutAdvancedQueryResponse?, NSError?) -> Void
    ) {
        manager.workoutAdvancedQuery(
            workoutTypeVariableDictionary: workoutTypeVariableDictionary, startDate: date.start, endDate: date.end, completion: completion
        )
    }
}
