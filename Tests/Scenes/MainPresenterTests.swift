//
//  MainPresenterTests.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 22.10.2022.
//

@testable import avito_task_internship
import XCTest

class MainPresenterTests: XCTestCase {
    // MARK: - Subject under test
    var sut: MainPresenter!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        setupMainPresenter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Test setup
    func setupMainPresenter() {
        sut = MainPresenter()
    }
    
    // MARK: - Test doubles
    class MainDisplayLogicSpy: MainDisplayLogic {
        var displayStartLoadingCalled = false
        var presentErrorCalled = false
        var presentCompanyDataCalled = false
        var displayFinishLoadingCalled = false
        
        func displayStartLoading(viewModel: Main.FetchData.ViewModel.Dummy) {
            displayStartLoadingCalled = true
        }
        
        func presentError(viewModel: Main.FetchData.ViewModel.Error) {
            presentErrorCalled = true
        }
        
        func presentCompanyData(viewModel: Main.FetchData.ViewModel.Company) {
            presentCompanyDataCalled = true
        }
        
        func displayFinishLoading(viewModel: Main.FetchData.ViewModel.Dummy) {
            displayFinishLoadingCalled = true
        }
    }
    
    class MainDisplayLogicMock: MainDisplayLogic {
        var errorViewModel: Main.FetchData.ViewModel.Error?
        var companyViewModel: Main.FetchData.ViewModel.Company?
        
        func displayStartLoading(viewModel: Main.FetchData.ViewModel.Dummy) {}
        
        func presentError(viewModel: Main.FetchData.ViewModel.Error) {
            errorViewModel = viewModel
        }
        
        func presentCompanyData(viewModel: Main.FetchData.ViewModel.Company) {
            companyViewModel = viewModel
        }
        
        func displayFinishLoading(viewModel: Main.FetchData.ViewModel.Dummy) {}
        
        func validateNoInternetConnectionError() -> Bool {
            guard let errorViewModel = errorViewModel else {
                return false
            }
            return errorViewModel.errorMessage == "Check your internet connection"
        }
        
        func validateData() -> Bool {
            guard let companyViewModel = companyViewModel else {
                return false
            }
            
            let employess = companyViewModel.company.employees
            guard employess.count == 2 else {
                return false
            }
            
            let first = employess[0]
            let second = employess[1]
            
            
            return companyViewModel.company.name == "Twoman" &&
            first.name == "Dave" && first.phoneNumber == "123456" &&
            first.skills == ["Javascript", "React"] &&
            second.name == "Jessica" && second.phoneNumber == "654321" &&
            second.skills == ["Java", "Spring"]
        }
    }
    
    // MARK: - Tests
    func testPresentStartFetchingDataShouldCallViewControllerToDisplayStartFetchingData() {
        // Given
        let spy = MainDisplayLogicSpy()
        sut.viewController = spy
        let response = Main.FetchData.Response.Dummy()
        
        // When
        sut.presentStartFetchingData(response: response)
        // Then
        XCTAssertTrue(spy.displayStartLoadingCalled, "presentStartFetchingData(response:) should call viewController.displayStartLoading(viewModel:)")
    }
    
    func testPresentFinishedFetchingDataShouldCallViewControllerToDisplayFinishLoading() {
        // Given
        let spy = MainDisplayLogicSpy()
        sut.viewController = spy
        let response = Main.FetchData.Response.Dummy()
        
        // When
        sut.presentFinishedFetchingData(response: response)
        
        // Then
        XCTAssertTrue(spy.displayFinishLoadingCalled, "presentStartFetchingData(response:) should call viewController.displayStartLoading(viewModel:)")
    }
    
    func testPresentFetchedDataWithCorrectDataShouldCallViewControllerToDisplayData() {
        // Given
        let spy = MainDisplayLogicSpy()
        sut.viewController = spy
    
        let result: Result<Company, BusinessLogicError> = .success(Seeds.Companys.empty)
        let response = Main.FetchData.Response.CompanyOrError(companyOrError: result)
        
        // When
        sut.presentFetchedData(response: response)
        
        // Then
        XCTAssertTrue(spy.presentCompanyDataCalled, "presentFetchedData(response:) with correct data should call viewController.presentCompanyDataCalled(viewModel:)")
    }
    
    func testPresentFetchedDataShouldCallViewControllerWithCompanyViewModel() {
        // Given
        let mock = MainDisplayLogicMock()
        sut.viewController = mock
        
        let result: Result<Company, BusinessLogicError> = .success(Seeds.Companys.twoManCompany)
        let response = Main.FetchData.Response.CompanyOrError(companyOrError: result)
        
        // When
        sut.presentFetchedData(response: response)
        
        // Then
        XCTAssertTrue(mock.validateData(), "incorrect data passed from presenter to viewController")
    }
    
    func testPresentFetchedDataWithInternetConnectionErrorShouldCallViewControllerToDisplayCorrectError() {
        // Given
        let mock = MainDisplayLogicMock()
        sut.viewController = mock
        
        let result: Result<Company, BusinessLogicError> = .failure(.noInternetConnection)
        let response = Main.FetchData.Response.CompanyOrError(companyOrError: result)
        
        // When
        sut.presentFetchedData(response: response)
        
        // Then
        XCTAssertTrue(mock.validateNoInternetConnectionError(),
                      "incorrect error message passed from presenter to viewController")
    }
    
    func testPresentFetchedDataWithErrorShouldCallViewControllerToPresentError() {
        // Given
        let spy = MainDisplayLogicSpy()
        sut.viewController = spy
    
        let result: Result<Company, BusinessLogicError> = .failure(.invalidDataFormat)
        let response = Main.FetchData.Response.CompanyOrError(companyOrError: result)
        
        // When
        sut.presentFetchedData(response: response)
        
        // Then
        XCTAssertTrue(spy.presentErrorCalled,
                      "presentFetchedData(response:) with error should call viewController.presentError(viewModel:)")
    }
}
