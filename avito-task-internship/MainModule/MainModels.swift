//
//  MainModels.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 21.10.2022.
//

enum Main {
    enum FetchData {
        struct Request {}

        enum Response {
            struct CompanyOrError {
                let companyOrError: Result<Company, BusinessLogicError>
            }

            struct Dummy {}
        }

        enum ViewModel {
            struct Company {
                let company: CompanyNetworkModel
            }

            struct Error {
                let errorMessage: String
            }

            struct Dummy {}
        }
    }
}
