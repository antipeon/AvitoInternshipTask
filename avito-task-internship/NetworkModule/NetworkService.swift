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
//    private let urlSession: URLSession = {
//        let config = URLSessionConfiguration.default
//        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
//
//        config.urlCache = {
//            let diskCacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("networkCache")
//            print(diskCacheUrl)
//            let cache = URLCache(memoryCapacity: 10_000_000, diskCapacity: 1_000_000_000, directory: diskCacheUrl)
//
//            return cache
//        }()
//
//
//        let session = URLSession(configuration: config)
//        return session
//    }()
//
    private let request = URL(string: Constants.urlString).flatMap {
        URLRequest(url: $0)
    }
    
    // MARK: - API
    func fetchData(_ completion: @escaping CompletionHandler) {
        
        guard let request = request else {
            completion(.failure(NetworkError.incorrectURL))
            return
        }
        
//        urlSession.configuration.urlCache?.removeCachedResponses(since: Date().addingTimeInterval(-60))
//        urlSession.configuration.urlCache?.removeAllCachedResponses()
//        sleep(4)

        
        
//        if let response = urlSession.configuration.urlCache?.cachedResponse(for: request) {
//
//            print("using cache")
//            parseData(response.data, completion: completion)
//            return
//        }
//
        cache.load { [weak self] cacheLoadResult in
            guard let self = self else {
                return
            }
            
            switch cacheLoadResult {
            case .success(let cachedModel):
                if let cachedModel = cachedModel {
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
    private func onCacheMiss(_ request: URLRequest,_ completion: @escaping CompletionHandler) {
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
            
            guard error == nil else {
                // TODO: process error
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
            
//            self.urlSession.configuration.urlCache?.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
            self.parseDataAndUpdateCache(data, completion)
        }
    }
    
    private func parseDataAndUpdateCache(_ data: Data, _ completion: @escaping CompletionHandler) {
        self.parser.parseDataToResource(data) { [weak self] parseResult in
            guard let self = self else {
                return
            }
            
            switch parseResult {
            case .success(let model):
                self.cache.save(model) { saveResult in
                    switch saveResult {
                    case .success(_):
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


enum NetworkError: Error {
    case networkError
    case responseError
    case incorrectURL
}
