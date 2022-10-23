//
//  NetworkWorkerTests.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 22.10.2022.
//

@testable import avito_task_internship
import XCTest

class NetworkWorkerTests: XCTestCase {
    // MARK: - Subject under test
    var sut: NetworkWorker!

    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        setupNetworkWorker()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Test setup
    func setupNetworkWorker() {
        sut = NetworkWorker()
    }

    // MARK: - Test doubles
    class CompanyFetcherSpy: CompanyFetcherProtocol {
        var fetchCompanyDataCalled = false
        
        func fetchCompanyData(_ completion: @escaping CompletionHandler) {
            fetchCompanyDataCalled = true
        }
    }

    // MARK: - Tests
    func testWorkerShouldDelegateAllWork() {
        // Given
        sut.companyFetcher = nil
        let spy = CompanyFetcherSpy()
        sut.companyFetcher = spy
        
        // When
        sut.fetchCompanyData { _ in
            
        }
        
        // Then
        XCTAssertTrue(spy.fetchCompanyDataCalled, "worker should delegate work")
    }
}
