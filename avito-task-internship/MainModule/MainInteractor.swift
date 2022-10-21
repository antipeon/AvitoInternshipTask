//
//  MainInteractor.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 21.10.2022.
//

import Foundation

protocol MainBusinessLogic {
    func fetchData(request: Main.FetchData.Request)
}

protocol MainDataStore {
    var companyOrError: Result<Company, BusinessLogicError>? { get }
}

final class MainInteractor: MainBusinessLogic, MainDataStore {
    var networkWorker = NetworkWorker(companyFetcher: NetworkService())
    var presenter: MainPresentationLogic?

    // MARK: - MainBusinessLogic
    func fetchData(request: Main.FetchData.Request) {
        presenter?.presentStartFetchingData(response: Main.FetchData.Response.Dummy())
        fetchDataFromNetwork()
    }

    // MARK: - MainDataStore
    var companyOrError: Result<Company, BusinessLogicError>?

    // MARK: - Private funcs
    private func fetchDataFromNetwork() {
        networkWorker.fetchCompanyData { [weak self] result in
            guard let self = self else {
                return
            }

            let transformedResult = result.map { model in
                Company(from: model.company)
            }

            let companyOrError = self.companyOrError(result: transformedResult)
            self.companyOrError = companyOrError
            let response = Main.FetchData.Response.CompanyOrError(companyOrError: companyOrError)

            DispatchQueue.main.async {
                self.presenter?.presentFetchedData(response: response)
                self.presenter?.presentFinishedFetchingData(response: Main.FetchData.Response.Dummy())
            }
        }
    }

    private func transformToBusinessLogicError(_ error: Error) -> BusinessLogicError {
        guard let networkError = error as? NetworkError else {
            guard let parseError = error as? ParseError else {
                return BusinessLogicError.unhandledError
            }

            switch parseError {
            case .parseError:
                return BusinessLogicError.parse
            }
        }

        switch networkError {
        case .timeout:
            return .timeout
        case .noInternetConnection:
            return .noInternetConnection
        case .incorrectURL, .networkError, .responseError:
            return .unhandledError
        }
    }

    private func companyOrError(result: Result<Company?, Error>) -> Result<Company, BusinessLogicError> {
        switch result {
        case .success(let company):
            guard let company = company else {
                return .failure(BusinessLogicError.invalidDataFormat)
            }
            return .success(company)

        case .failure(let error):
            return .failure(transformToBusinessLogicError(error))
        }
    }

}

// MARK: - Error
enum BusinessLogicError: Error {
    case invalidDataFormat
    case noInternetConnection
    case timeout
    case parse
    case unhandledError
}
