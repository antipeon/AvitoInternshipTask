//
//  NetworkServiceTests.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 22.10.2022.
//

@testable import avito_task_internship
import XCTest

class NetworkServiceTests: XCTestCase {
    // MARK: - Subject under test
    var sut: NetworkService<CacheMock, ParserMock>!

    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        setupNetworkService()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Test setup
    func setupNetworkService() {
        // will perform setup in the actual tests
    }

    // MARK: - Test doubles
    final class CacheMock: CacheProtocol {
        var saveCalled = false
        var loadCalled = false
        
        func save(_ model: CompanyNetworkResponseModel, completion: @escaping (Result<Void, Error>) -> Void) {
            saveCalled = true
            completion(.success(()))
        }
        
        func load(_ completion: @escaping (Result<CompanyNetworkResponseModel?, Error>) -> Void) {
            loadCalled = true
            completion(.success(nil))
        }
    }
    
    final class NetworkApiSuccessfulFetchMock: NetworkApiProtocol {
        var performRequestCalled = false
        private let data: Data
        
        init(data: Data) {
            self.data = data
        }
        
        func performRequest(callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
            performRequestCalled = true
            callback(data, URLResponse(), nil)
        }
    }
    
    final class ParserMock: DecodableParserProtocol & EncodableParserProtocol {
        var parseDataToModelCalled = false
        var parseModelToDataCalled = false
        
        func parseDataToModel(_ data: Data, completion: @escaping (Result<CompanyNetworkResponseModel, Error>) -> Void) {
            parseDataToModelCalled = true
            completion(.success(Seeds.CompanyNetworkResponseModels.twoManCompany))
        }
        
        func parseModelToData(_ model: CompanyNetworkResponseModel, completion: @escaping (Result<Data, Error>) -> Void) {
            parseModelToDataCalled = true
            completion(.success(Data()))
        }
        
    }

    // MARK: - Tests
    func testNetworkServiceApiShouldMakeWriteCallsToDependencies() {
        // Given
        let cacheMock = CacheMock()
        
        let seedModel = Seeds.CompanyNetworkResponseModels.twoManCompany.company
        let data = parseModelToData(seedModel)
        let networkApiMock = NetworkApiSuccessfulFetchMock(data: data)
        let parserMock = ParserMock()
        
        sut = NetworkService(cache: cacheMock, networkAPI: networkApiMock, parser: parserMock)
        
        // When
        let expectation = expectation(description: "wait for completion")
        sut.fetchCompanyData { result in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertTrue(networkApiMock.performRequestCalled, "should make network call to API")
        XCTAssertTrue(parserMock.parseDataToModelCalled, "should parse data from network")
        XCTAssertFalse(parserMock.parseModelToDataCalled, "shouldn't call this")
        XCTAssertTrue(cacheMock.loadCalled, "should make load call to cache before calling to API")
        XCTAssertTrue(cacheMock.saveCalled, "should call save to cache in the end")
    }
    
    private func parseModelToData(_ model: CompanyNetworkModel) -> Data {
        
        let parser = Parser<CompanyNetworkModel>()
        var dataOrNil: Data?
        
        let expectation = expectation(description: "wait for completion")
        parser.parseModelToData(model) { result in
            switch result {
            case .success(let data):
                dataOrNil = data
                expectation.fulfill()
            case .failure:
                XCTFail("parse model to data can't fail in this case")
            }
        }
        waitForExpectations(timeout: 1.0)
        
        XCTAssertNotNil(dataOrNil)
        return dataOrNil!
    }
}
