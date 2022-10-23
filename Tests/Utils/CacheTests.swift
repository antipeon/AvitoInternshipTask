//
//  CacheTests.swift
//  Tests
//
//  Created by Samat Gaynutdinov on 23.10.2022.
//

@testable import avito_task_internship
import XCTest

final class CacheTests: XCTestCase {

    // MARK: - Subject under test
    var sut: Cache<CompanyNetworkModel, CacheDiskStorageSpy>!

    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        setupCache()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Test setup
    func setupCache() {
        // setup will take place in the actual test
    }

    // MARK: - Test doubles
    class CacheDiskStorageSpy: CacheDiskStorageProtocol {
        var saveCalled = false
        var loadDataCalled = false
        
        func save(_ data: Data) throws {
            saveCalled = true
        }
        
        func loadData() throws -> Data {
            loadDataCalled = true
            return Data()
        }
    }
    
    class UserDefaultsWrapperMock: UserDefaultsWrapperProtocol {
        var cacheDate: Date?
    }
    
    class ConstantDateProvider {
        let date: Date
        init(date: Date) {
            self.date = date
        }
    }

    // MARK: - Tests
    func testLoadFromEmptyCache_ShoulBehaveCorrectly() {
        // Given
        let storageSpy = CacheDiskStorageSpy()
        let userDefaultsMock = UserDefaultsWrapperMock()
        sut = Cache<CompanyNetworkModel, CacheDiskStorageSpy>(
            cacheDiskStorage: storageSpy,
            invalidatationTimeInterval: 2.0,
            currentDateProvider: { Date() },
            userDefaults: userDefaultsMock
        )
        
        // When
        var company: CompanyNetworkModel?
        
        let expectation = expectation(description: "wait for completion")
        sut.load { result in
            switch result {
            case .success(let model):
                company = model
                expectation.fulfill()
            case .failure:
                XCTFail("should not return error here")
            }
        }
        waitForExpectations(timeout: 2.0)
        
        // Then
        XCTAssertFalse(storageSpy.loadDataCalled, "should return before calling load from storage")
        XCTAssertFalse(storageSpy.saveCalled, "should not call save to storage")
        XCTAssertNil(userDefaultsMock.cacheDate, "cache date should be nil")
        XCTAssertNil(company, "model should be nil")
    }
    
    func testSaveToCache_ShouldSaveWithCorrectDateToCache() {
        // Given
        let storageSpy = CacheDiskStorageSpy()
        let userDefaultsMock = UserDefaultsWrapperMock()
        let constantDateProvider = ConstantDateProvider(date: Date())
        sut = Cache<CompanyNetworkModel, CacheDiskStorageSpy>(
            cacheDiskStorage: storageSpy,
            invalidatationTimeInterval: 2.0,
            currentDateProvider: { constantDateProvider.date },
            userDefaults: userDefaultsMock
        )
        let model = Seeds.CompanyNetworkResponseModels.twoManCompany.company
        
        // When
        let expectation = expectation(description: "wait for completion")
        sut.save(model) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("should not fail in this case")
            }
        }
        waitForExpectations(timeout: 2.0)
        
        // Then
        XCTAssertNotNil(userDefaultsMock.cacheDate, "cache date should not be nil")
        XCTAssertEqual(userDefaultsMock.cacheDate, constantDateProvider.date, "incorrect date saved to cache")
        XCTAssertTrue(storageSpy.saveCalled, "should call save")
        XCTAssertFalse(storageSpy.loadDataCalled, "should not call load from storage")
    }
    
    func testLoadFromExpiredCache_ReturnedModelShouldBeNil() {
        // TODO: write test
        // Given
        
        let storageSpy = CacheDiskStorageSpy()
        let userDefaultsMock = UserDefaultsWrapperMock()
        let constantDateProvider = ConstantDateProvider(date: Date())
        // we go back in the past to invalidate cache later
        let invalidationTimeInterval = -2.0
        
        sut = Cache<CompanyNetworkModel, CacheDiskStorageSpy>(
            cacheDiskStorage: storageSpy,
            invalidatationTimeInterval: invalidationTimeInterval,
            currentDateProvider: { constantDateProvider.date },
            userDefaults: userDefaultsMock
        )
        let model = Seeds.CompanyNetworkResponseModels.twoManCompany.company
        
        // save to cache
        let saveExpectation = expectation(description: "wait for completion")
        sut.save(model) { result in
            switch result {
            case .success:
                saveExpectation.fulfill()
            case .failure:
                XCTFail("should not fail in this case")
            }
        }
        waitForExpectations(timeout: 1.0)
        
        XCTAssertNotNil(userDefaultsMock.cacheDate, "cache date should not be nil")
        XCTAssertEqual(userDefaultsMock.cacheDate, constantDateProvider.date, "incorrect date saved to cache")
        XCTAssertTrue(storageSpy.saveCalled, "should call save")
        XCTAssertFalse(storageSpy.loadDataCalled, "should not call load from storage")
        
        // When
        var company: CompanyNetworkModel?
        let loadExpectation = expectation(description: "wait for completion")
        sut.load { result in
            switch result {
            case .success(let model):
                company = model
                loadExpectation.fulfill()
            case .failure:
                XCTFail("should not return error here")
            }
        }
        
        waitForExpectations(timeout: 1.0)
        
        // Then
        XCTAssertNil(company, "returned model should be nil")
        XCTAssertNil(userDefaultsMock.cacheDate, "cache date should be invalidated")
        XCTAssertFalse(storageSpy.loadDataCalled, "should not call load from storage")
    }
}
