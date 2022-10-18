//
//  NetworkService.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

import Foundation

final class NetworkService {
    
    // MARK: - Private vars
    private let parserQueue = DispatchQueue(label: "parserQueue")
    private var urlSessionTask: URLSessionDataTask?
    private let cache = Cache<CompanyNetworkResponseModel>()
    
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
    func fetchData(_ completion: @escaping (Result<CompanyNetworkResponseModel, Error>) -> Void) {
        
        guard isExpired else {
            completion(.success(cachedResponse))
            return
        }
        
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
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
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
            self.parseData(data, completion: completion)
        }
        
        // TODO: think about what to do if task is set
//        urlSessionTask?.cancel()
        urlSessionTask = task
        urlSessionTask?.resume()
    }
    
    // MARK: - Private funcs
    private func parseData(_ data: Data, completion: @escaping (Result<CompanyNetworkResponseModel, Error>) -> Void) {
        parserQueue.async { [data] in
            let companyModel = try? JSONDecoder().decode(CompanyNetworkResponseModel.self, from: data)
            
            guard let companyModel = companyModel else {
                completion(.failure(ParseError.parseError))
                return
            }
            
            completion(.success(companyModel))
        }
    }
    
    // TODO: implement cache
    private var isExpired: Bool {
        return true
    }
    
    private var cachedResponse: CompanyNetworkResponseModel {
        return CompanyNetworkResponseModel(company: CompanyNetworkModel(name: "avito", employees: [EmployeeNetworkModel(name: "Ovanes", phoneNumber: "798723", skills: ["CEO", "Soft skills", "Go"])]))
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

enum ParseError: Error {
    case parseError
}

final class UserSettings {
    @Storage(key: "cacheDate", defaultValue: nil)
    static var cacheDate: Date?
}

@propertyWrapper
public struct Storage<T: Codable> {
    private let key: String
    private let defaultValue: T

    public var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
                return defaultValue
            }

            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
}

final class Cache<T: Codable> {
    private let invalidatationTimeInterval: TimeInterval
    private let cacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("network.cache")
    
    
    init(invalidatationTimeInterval: TimeInterval = TimeInterval.minute) {
        self.invalidatationTimeInterval = invalidatationTimeInterval
        
    }
    
    /// Saves resoure to cache
    /// - Throws: parsing, writing to disk, wrong url
    func save(_ resource: T) throws {
        guard let cacheUrl = cacheUrl  else {
            throw CacheError.wrongUrl
        }
        
        let data = try JSONEncoder().encode(resource)
        try data.write(to: cacheUrl)
        UserSettings.cacheDate = Date()
    }
    
    /// Loads resource from cache
    /// - Returns: resource from cache; nil if no resource or resource is expired
    /// - Throws: parsing, reading from disk, wrong url
    func load() throws -> T? {
        guard let cacheUrl = cacheUrl  else {
            throw CacheError.wrongUrl
        }
        
        invalidateIfNeeded()
        
        guard !emptyOrExpired else {
            return nil
        }
        
        let data = try Data(contentsOf: cacheUrl)
        
        let resource = try JSONDecoder().decode(T.self, from: data)
        return resource
    }
    
    var emptyOrExpired: Bool {
        UserSettings.cacheDate == nil
    }
    
    private func invalidateIfNeeded() {
        guard let lastSavedDate = UserSettings.cacheDate else {
            return
        }
        
        if lastSavedDate.addingTimeInterval(invalidatationTimeInterval) < Date() {
            UserSettings.cacheDate = nil
        }
    }
}

extension TimeInterval {
    static let minute: TimeInterval = 60
    static let hour: TimeInterval = 60 * 60
}

enum CacheError: Error {
    case wrongUrl
}
