//
//  NetworkWorker.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 21.10.2022.
//

import Foundation

protocol CompanyFetcherProtocol {
    typealias CompletionHandler = (Result<CompanyNetworkResponseModel, Error>) -> Void
    func fetchCompanyData(_ completion: @escaping CompletionHandler)
}

final class NetworkWorker {
    var companyFetcher: CompanyFetcherProtocol?

    init(companyFetcher: CompanyFetcherProtocol = NetworkService()) {
        self.companyFetcher = companyFetcher
    }

    func fetchCompanyData(_ completion: @escaping CompanyFetcherProtocol.CompletionHandler) {
        companyFetcher?.fetchCompanyData { result in
            completion(result)
        }
    }
}
