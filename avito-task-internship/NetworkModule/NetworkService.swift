//
//  NetworkService.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

import Foundation
import CocoaLumberjack

final class NetworkService<
    CacheT: CacheProtocol,
        ParserT: DecodableParserProtocol & EncodableParserProtocol
>: CompanyFetcherProtocol where CacheT.T == CompanyNetworkResponseModel,
                                    ParserT.E == CompanyNetworkResponseModel,
                                    ParserT.D == CompanyNetworkResponseModel {

    typealias CompletionHandler = CompanyFetcherProtocol.CompletionHandler

    // MARK: - Private vars
    private let cache: CacheT
    private let parser: ParserT
    private let networkAPI: NetworkApiProtocol

    init(
        cache: CacheT = Cache<CompanyNetworkResponseModel, CacheDiskStorage>(),
        networkAPI: NetworkApiProtocol = NetworkAPI(),
        parser: ParserT = Parser<CompanyNetworkResponseModel>()
    ) {
        self.cache = cache
        self.networkAPI = networkAPI
        self.parser = parser
    }

    // MARK: - API
    func fetchCompanyData(_ completion: @escaping CompletionHandler) {

        cache.load { [weak self] cacheLoadResult in
            guard let self = self else {
                return
            }

            switch cacheLoadResult {
            case .success(let cachedModel):
                if let cachedModel = cachedModel {
                    DDLogInfo("cache hit")
                    completion(.success(cachedModel))
                    return
                }

                self.onCacheMiss(completion)

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private funcs
    private func onCacheMiss(_ completion: @escaping CompletionHandler) {
        DDLogInfo("cache miss - fetching from network")
        performNetworkRequest(completion)
    }

    private func performNetworkRequest(_ completion: @escaping CompletionHandler) {
        networkAPI.performRequest { [weak self] data, response, error in

            guard let self = self else {
                return
            }

            if let error = error {
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain, nsError.code == -1009 {
                    completion(.failure(NetworkError.noInternetConnection))
                    return
                }

                if nsError.domain == NSURLErrorDomain, nsError.code == -1001 {
                    completion(.failure(NetworkError.timeout))
                }

                completion(.failure(NetworkError.networkError))
                return
            }

            guard response != nil else {
                completion(.failure(NetworkError.responseError))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.networkError))
                return
            }

            self.parseDataAndUpdateCache(data, completion)
        }
    }

    private func parseDataAndUpdateCache(_ data: Data, _ completion: @escaping CompletionHandler) {
        self.parser.parseDataToModel(data) { [weak self] parseResult in
            guard let self = self else {
                return
            }

            switch parseResult {
            case .success(let model):
                self.cache.save(model) { saveResult in
                    switch saveResult {
                    case .success:
                        DDLogInfo("saved to cache successfuly")
                    case .failure(let error):
                        DDLogError("couldn't save to cache - \(error.localizedDescription)")
                        assert(false)
                    }
                }
                completion(.success(model))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - NetworkError
enum NetworkError: Error {
    case networkError
    case timeout
    case responseError
    case noInternetConnection
}
