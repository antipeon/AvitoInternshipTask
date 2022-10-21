//
//  NetworkService.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

import Foundation

final class NetworkService {

    typealias CompletionHandler = (Result<CompanyNetworkResponseModel, Error>) -> Void

    // MARK: - Private vars
    private var urlSessionTask: URLSessionDataTask?
    private lazy var cache = Cache<CompanyNetworkResponseModel>(parser: parser)
    private let parser = Parser<CompanyNetworkResponseModel>()
    private let request = URL(string: Constants.urlString).flatMap {
        URLRequest(url: $0)
    }

    // MARK: - API
    func fetchData(_ completion: @escaping CompletionHandler) {

        guard let request = request else {
            completion(.failure(NetworkError.incorrectURL))
            return
        }

        cache.load { [weak self] cacheLoadResult in
            guard let self = self else {
                return
            }

            switch cacheLoadResult {
            case .success(let cachedModel):
                if let cachedModel = cachedModel {
                    // TODO: replace with loger
                    print("cache hit")
                    completion(.success(cachedModel))
                    return
                }

                self.onCacheMiss(request, completion)

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private funcs
    private func onCacheMiss(_ request: URLRequest, _ completion: @escaping CompletionHandler) {
        // TODO: replace with loger
        print("cache miss - fetching from network")
        let task = dataTask(request, completion)

        // TODO: think about what to do if task is set
//        urlSessionTask?.cancel()
        urlSessionTask = task
        urlSessionTask?.resume()
    }

    private func dataTask(_ request: URLRequest, _ completion: @escaping CompletionHandler) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: request) { [weak self] data, response, error in

            guard let self = self else {
                return
            }

            if let error = error {
                // TODO: process error
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

            guard let response = response else {
                // TODO: process response
                completion(.failure(NetworkError.responseError))
                return
            }

            guard let data = data else {
                // TODO: check when possible
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
                        // TODO: replace with loger
                        print("saved to cache successfuly")
                    case .failure(let error):
                        assert(false, "couldn't save to cache - \(error.localizedDescription)")
                    }
                }
                completion(.success(model))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Constants
    enum Constants {
        static let urlString = "https://run.mocky.io/v3/1d1cb4ec-73db-4762-8c4b-0b8aa3cecd4c"
    }
}

// MARK: - NetworkError
enum NetworkError: Error {
    case networkError
    case timeout
    case responseError
    case incorrectURL
    case noInternetConnection
}
