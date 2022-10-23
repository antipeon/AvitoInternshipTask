//
//  MainViewControllerTests.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 22.10.2022.
//

@testable import avito_task_internship
import XCTest

struct DisplayFetchDataError
{
  static var presentViewControllerAnimatedCompletionCalled = false
  static var viewControllerToPresent: UIViewController?
}

extension MainViewController {
    override public func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        DisplayFetchDataError.presentViewControllerAnimatedCompletionCalled = true
        DisplayFetchDataError.viewControllerToPresent = viewControllerToPresent
    }
}

class MainViewControllerTests: XCTestCase {
    // MARK: - Subject under test
    var sut: MainViewController!
    var window: UIWindow!

    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupMainViewController()
        loadView()
    }

    override func tearDown() {
        window = nil
        super.tearDown()
    }

    // MARK: - Test setup
    func setupMainViewController() {
        sut = MainViewController()
    }

    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }

    // MARK: - Test doubles
    class MainBusinessLogicSpy: MainBusinessLogic {
        var fetchDataCalled = false
        
        func fetchData(request: Main.FetchData.Request) {
            fetchDataCalled = true
        }
    }
    
    class TableViewSpy: UITableView {
        var reloadDataCalled = false
        
        override func reloadData() {
            reloadDataCalled = true
        }
    }

    // MARK: - Tests
    func testShouldDoSomethingWhenViewDidAppear() {
        // Given
        let spy = MainBusinessLogicSpy()
        sut.interactor = spy

        // When
        sut.viewDidAppear(false)

        // Then
        XCTAssertTrue(spy.fetchDataCalled, "viewDidAppear() should ask the interactor to fetch data")
    }
    
    func testPresentCompanyData_TableViewShouldReloadData() {
        // Given
        let spy = TableViewSpy()
        sut.tableView = spy
        let viewModel = Main.FetchData.ViewModel.Company(company: Seeds.CompanyNetworkResponseModels.oneManCompany.company)
        
        // When
        sut.presentCompanyData(viewModel: viewModel)
        
        // Then
        XCTAssertTrue(spy.reloadDataCalled, "presentCompanyData(viewModel:) should reload table view data")
    }
    
    func testShouldDisplayCorrectCells() {
        // Given
        let displayedModel = Main.FetchData.ViewModel.Company(company: Seeds.CompanyNetworkResponseModels.twoManCompany.company)
        sut.displayedModel = displayedModel
        
        // When
        let index0 = IndexPath(row: 0, section: 0)
        let index1 = IndexPath(row: 1, section: 0)
        let cell0 = sut.tableView(sut.tableView, cellForRowAt: index0) as! EmployeeCell
        let cell1 = sut.tableView(sut.tableView, cellForRowAt: index1) as! EmployeeCell
        
        // Then
        XCTAssertEqual(cell1.nameLabelText, "Name:Dave")
        XCTAssertEqual(cell1.phoneLabelText, "Phone:123456")
        XCTAssertEqual(cell1.skillsLabelText, "Skills:Javascript, React")
        
        XCTAssertEqual(cell0.nameLabelText, "Name:Jessica")
        XCTAssertEqual(cell0.phoneLabelText, "Phone:654321")
        XCTAssertEqual(cell0.skillsLabelText, "Skills:Java, Spring")
    }
    
    func testShouldHaveCorrectNumberOfCells() {
        // Given
        let displayedModel = Main.FetchData.ViewModel.Company(company: Seeds.CompanyNetworkResponseModels.twoManCompany.company)
        sut.displayedModel = displayedModel
        
        // When
        let number = sut.tableView(sut.tableView, numberOfRowsInSection: 0)
        
        // Then
        XCTAssertTrue(number == 2, "incorrect number of cells in table view")
    }
    
    func testCorrectHeaderTitle() {
        // Given
        let displayedModel = Main.FetchData.ViewModel.Company(company: Seeds.CompanyNetworkResponseModels.twoManCompany.company)
        sut.displayedModel = displayedModel
        
        // When
        let header = sut.tableView(sut.tableView, viewForHeaderInSection: 0) as! HeaderView
        
        // Then
        XCTAssertEqual(header.title, "Twoman")
    }
    
    func testPresentErrorShouldShowAlert() {
        // Given
        let viewModel = Main.FetchData.ViewModel.Error(errorMessage: "some error message")
        
        // When
        sut.presentError(viewModel: viewModel)
        
        // Then
        let alertController = DisplayFetchDataError.viewControllerToPresent as! UIAlertController
        XCTAssertTrue(DisplayFetchDataError.presentViewControllerAnimatedCompletionCalled, "should show alert")
        XCTAssertEqual(alertController.title, "Error", "incorrect alert title")
        XCTAssertEqual(alertController.message, "some error message", "incorrect alert message")
    }
}
