//
//  ParserTests.swift
//  Tests
//
//  Created by Samat Gaynutdinov on 23.10.2022.
//

@testable import avito_task_internship
import XCTest

extension EmployeeNetworkModel: Equatable {
    public static func == (lhs: EmployeeNetworkModel, rhs: EmployeeNetworkModel) -> Bool {
        lhs.name == rhs.name && lhs.phoneNumber == rhs.phoneNumber && lhs.skills == rhs.skills
    }
}

extension CompanyNetworkModel: Equatable {
    public static func == (lhs: CompanyNetworkModel, rhs: CompanyNetworkModel) -> Bool {
        lhs.name == rhs.name && lhs.employees == rhs.employees
    }
}

final class ParserTests: XCTestCase {

    // MARK: - Subject under test
    var sut: Parser<CompanyNetworkModel>!

    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        setupParser()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Test setup
    func setupParser() {
        sut = Parser()
    }

    // MARK: - Tests
    func testEncodeThenDecodeModel_ShouldBeEqualToOriginal() {
        // Given
        let model = Seeds.CompanyNetworkResponseModels.twoManCompany.company
        
        // When
        var company: CompanyNetworkModel?
        let expectation = expectation(description: "wait for completion")
        sut.parseModelToData(model) { [self] result in
            switch result {
            case .success(let data):
                sut.parseDataToModel(data) { result in
                    switch result {
                    case .success(let model):
                        company = model
                        expectation.fulfill()
                    case .failure:
                        XCTFail("parse data to model can't fail in this case")
                    }
                }
            case .failure:
                XCTFail("parse model to data can't fail in this case")
            }
        }
        waitForExpectations(timeout: 1.0)
        
        // Then
        XCTAssertEqual(company, model, "encoded then decoded value should be equal to original value")
    }
}
