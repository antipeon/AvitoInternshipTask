//
//  MainPresenter.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 21.10.2022.
//

import Foundation

protocol MainPresentationLogic {
    func presentFetchedData(response: Main.FetchData.Response.CompanyOrError)
    func presentStartFetchingData(response: Main.FetchData.Response.Dummy)
    func presentFinishedFetchingData(response: Main.FetchData.Response.Dummy)
}

final class MainPresenter: MainPresentationLogic {
    weak var viewController: MainDisplayLogic?

    // MARK: - MainPresentationLogic
    func presentFetchedData(response: Main.FetchData.Response.CompanyOrError) {
        let companyOrError = response.companyOrError.map { company in
            CompanyNetworkModel(from: company)
        }
        switch companyOrError {
        case .success(let company):
            let sortedCompany = company.sorted { employee1, employee2 in
                employee1.name < employee2.name
            }

            let viewModel = Main.FetchData.ViewModel.Company(company: sortedCompany)

            viewController?.presentCompanyData(viewModel: viewModel)
        case .failure(let error):
            let viewModel = Main.FetchData.ViewModel.Error(errorMessage: messageToDisplayFrom(error))
            viewController?.presentError(viewModel: viewModel)
        }
    }

    func presentStartFetchingData(response: Main.FetchData.Response.Dummy) {
        viewController?.displayStartLoading(viewModel: Main.FetchData.ViewModel.Dummy())
    }

    func presentFinishedFetchingData(response: Main.FetchData.Response.Dummy) {
        viewController?.displayFinishLoading(viewModel: Main.FetchData.ViewModel.Dummy())
    }

    // MARK: - Private funcs
    private func messageToDisplayFrom(_ error: BusinessLogicError) -> String {
        var message = error.localizedDescription

        switch error {
        case .noInternetConnection, .timeout:
            message = "Check your internet connection"
        default:
            break
        }

        return message
    }
}
