//
//  MainInteractorTests.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 22.10.2022.
//

@testable import avito_task_internship
import XCTest

class MainInteractorTests: XCTestCase {
    // - MARK: Subject under test
    var sut: MainInteractor!
    
    // - MARK: Test lifecycle
    override func setUp() {
        super.setUp()
        setupMainInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // - MARK: Test setup
    func setupMainInteractor() {
        sut = MainInteractor()
    }
    
    // - MARK: Test doubles
    class MainPresentationLogicSpy: MainPresentationLogic {
        var presentStartFetchingDataCalled = false
        var presentFetchedDataCalled = false
        var presentFinishedFetchingDataCalled = false
        
        var dataResponse: Main.FetchData.Response.CompanyOrError?
        
        func presentStartFetchingData(response: Main.FetchData.Response.Dummy) {
            presentStartFetchingDataCalled = true
        }
        
        func presentFetchedData(response: Main.FetchData.Response.CompanyOrError) {
            presentFetchedDataCalled = true
            self.dataResponse = response
        }
        
        func presentFinishedFetchingData(response: Main.FetchData.Response.Dummy) {
            presentFinishedFetchingDataCalled = true
        }
    }
    
    class MainPresentationLogicMock: MainPresentationLogic {
        class CorrectSmallCompanyFetcherSpy: CompanyFetcherProtocol {
            var fetchCompanyDataCalled = false
            
            func fetchCompanyData(_ completion: @escaping CompletionHandler) {
                fetchCompanyDataCalled = true
                completion(.success(Seeds.CompanyNetworkResponseModels.oneManCompany))
            }
        }
        
        var dataResponse: Main.FetchData.Response.CompanyOrError?
        
        func presentStartFetchingData(response: Main.FetchData.Response.Dummy) {}
        
        func presentFetchedData(response: Main.FetchData.Response.CompanyOrError) {
            self.dataResponse = response
        }
        
        func presentFinishedFetchingData(response: Main.FetchData.Response.Dummy) {}
        
        func validateData() -> Bool {
            guard let response = dataResponse?.companyOrError else {
                return false
            }

            switch response {
            case .success(let company):
                guard let employee = company.employees.first else {
                    return false
                }
                
                guard let skill = employee.skills.first else {
                    return false
                }
                
                return company.name.rawValue == "Oneman" &&
                company.employees.count == 1 &&
                employee.name.rawValue == "John" &&
                employee.phoneNumber.rawValue == "777777" &&
                employee.skills.count == 1 &&
                skill == "Everything"
            case .failure:
                return false
            }
        }
    }
    
    class CompanyFetcherSpy: CompanyFetcherProtocol {
        var fetchCompanyDataCalled = false
        
        func fetchCompanyData(_ completion: @escaping CompletionHandler) {
            fetchCompanyDataCalled = true
            completion(.success(Seeds.CompanyNetworkResponseModels.empty))
        }
    }
    
    class InvalidCompanyNameCompanyFetcherSpy: CompanyFetcherProtocol {
        var fetchCompanyDataCalled = false
        
        func fetchCompanyData(_ completion: @escaping CompletionHandler) {
            fetchCompanyDataCalled = true
            completion(.success(Seeds.CompanyNetworkResponseModels.invalid))
        }
    }
    
    class NoInternetConnectionCompanyFetcherSpy: CompanyFetcherProtocol {
        var fetchCompanyDataCalled = false
        
        func fetchCompanyData(_ completion: @escaping CompletionHandler) {
            fetchCompanyDataCalled = true
            completion(.failure(NetworkError.noInternetConnection))
        }
    }
    
    class ConnectionTimeoutCompanyFetcherSpy: CompanyFetcherProtocol {
        var fetchCompanyDataCalled = false
        
        func fetchCompanyData(_ completion: @escaping CompletionHandler) {
            fetchCompanyDataCalled = true
            completion(.failure(NetworkError.timeout))
        }
    }
    
    // MARK: - Tests
    func testFetchDataShouldAskWorkerToFetchAndPresenterToFormatResults() {
        // Given
        let presenterSpy = MainPresentationLogicSpy()
        let companyFetcherSpy = CompanyFetcherSpy()
        sut.presenter = presenterSpy
        sut.networkWorker = NetworkWorker(companyFetcher: companyFetcherSpy)
        let request = Main.FetchData.Request()
        
        // When
        sut.fetchData(request: request)
        
        // Then
        XCTAssertTrue(companyFetcherSpy.fetchCompanyDataCalled, "should call companyFetcher to fetch data")
        XCTAssertTrue(presenterSpy.presentStartFetchingDataCalled, "should call presenter to presentStartFetchingData")
        XCTAssertTrue(presenterSpy.presentFetchedDataCalled, "should call presenter to presentFetchedData")
        XCTAssertTrue(presenterSpy.presentFinishedFetchingDataCalled, "should call presenter to presentFinishedFetchingData")
    }
    
    func testFetchCorrectDataShouldAskPresenterToFormatData() {
        // Given
        let presenterMock = MainPresentationLogicMock()
        let companyFetcherSpy = MainPresentationLogicMock.CorrectSmallCompanyFetcherSpy()
        sut.presenter = presenterMock
        sut.networkWorker = NetworkWorker(companyFetcher: companyFetcherSpy)
        let request = Main.FetchData.Request()
        
        // When
        sut.fetchData(request: request)
        
        // Then
        XCTAssertTrue(presenterMock.validateData(), "data passed to presenter is invalid")
    }
    
    func testFetchInvalidDataShouldAskPresenterToFormatError() {
        // Given
        let presenterSpy = MainPresentationLogicSpy()
        let companyFetcherSpy = InvalidCompanyNameCompanyFetcherSpy()
        sut.presenter = presenterSpy
        sut.networkWorker = NetworkWorker(companyFetcher: companyFetcherSpy)
        let request = Main.FetchData.Request()
        
        // When
        sut.fetchData(request: request)
        
        // Then
        XCTAssertTrue(companyFetcherSpy.fetchCompanyDataCalled, "should call companyFetcher to fetch data")
        XCTAssertNotNil(presenterSpy.dataResponse, "data should not be nil")
        
        let error = presenterSpy.dataResponse!.companyOrError.extractedError()
        
        XCTAssertNotNil(error, "data should contain error")
        
        XCTAssertTrue(error == BusinessLogicError.invalidDataFormat, "error should be passed to presenter")
    }
    
    func testNoInternetConnectionShouldAskPresenterToFormatError() {
        // Given
        let presenterSpy = MainPresentationLogicSpy()
        let companyFetcherSpy = NoInternetConnectionCompanyFetcherSpy()
        sut.presenter = presenterSpy
        sut.networkWorker = NetworkWorker(companyFetcher: companyFetcherSpy)
        let request = Main.FetchData.Request()
        
        // When
        sut.fetchData(request: request)
        
        // Then
        XCTAssertTrue(companyFetcherSpy.fetchCompanyDataCalled, "should call companyFetcher to fetch data")
        XCTAssertNotNil(presenterSpy.dataResponse, "data should not be nil")
        
        let error = presenterSpy.dataResponse!.companyOrError.extractedError()
        
        XCTAssertNotNil(error, "data should contain error")
        
        XCTAssertTrue(error == BusinessLogicError.noInternetConnection, "error should be passed to presenter")
    }
    
    func testConnectionTimeoutShouldAskPresenterToFormatError() {
        // Given
        let presenterSpy = MainPresentationLogicSpy()
        let companyFetcherSpy = ConnectionTimeoutCompanyFetcherSpy()
        sut.presenter = presenterSpy
        sut.networkWorker = NetworkWorker(companyFetcher: companyFetcherSpy)
        let request = Main.FetchData.Request()
        
        // When
        sut.fetchData(request: request)
        
        // Then
        XCTAssertTrue(companyFetcherSpy.fetchCompanyDataCalled, "should call companyFetcher to fetch data")
        XCTAssertNotNil(presenterSpy.dataResponse, "data should not be nil")
        
        let error = presenterSpy.dataResponse!.companyOrError.extractedError()
        
        XCTAssertNotNil(error, "data should contain error")
        
        XCTAssertTrue(error == BusinessLogicError.timeout, "error should be passed to presenter")
    }
}
