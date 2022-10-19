//
//  Cache.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

import Foundation

final class Cache<T> {
    // MARK: - Private vars
    private let expirationTimeInterval: TimeInterval
    private let cacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("network.cache")
    private let parser: Parser<T>
    
    // write to disk - async(with barrier), read - async
    private let storageQueue = DispatchQueue(label: "storageQueue", qos: .utility, attributes: .concurrent)
    
    // allow only one save/load operation at a time
    private let synchronizeSaveLoadQueue = DispatchQueue(label: "synchronizeSaveLoad", qos: .utility)
    
    init(invalidatationTimeInterval: TimeInterval = TimeInterval.minute, parser: Parser<T>) {
        self.expirationTimeInterval = invalidatationTimeInterval
        self.parser = parser
    }
    
    // MARK: - API

    /// saves resource to cache
    /// - Parameters:
    ///   - resource: resource to save to cache
    ///   - completion: Errors: parsing, writing to disk, wrong url.
    ///   Queue for completion to run is up to the user.
    func save(_ resource: T, completion: @escaping (Result<Void, Error>) -> Void) where T: Encodable {
        synchronizeSaveLoadQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            guard let cacheUrl = self.cacheUrl  else {
                completion(.failure(CacheError.wrongUrl))
                return
            }
            
            let group = DispatchGroup()
            group.enter()
            
            self.parser.parseResourceToData(resource) { [weak self] result in
                defer {
                    group.leave()
                }
                
                guard let self = self else {
                    return
                }
                
                switch result {
                case .success(let data):
                    self.storageQueue.sync {
                        let result = Result {
                            try data.write(to: cacheUrl)
                            UserSettings.cacheDate = Date()
                        }
                        completion(.success(()))
                    }
                case .failure(let failure):
                    completion(.failure(failure))
                }
            }
            
            group.wait()
        }
    }
    
    /// Loads resource from cache
    /// - Parameters:
    ///   - completion: Resource from cache; nil if no resource or resource is expired. Error: parsing, reading from disk, wrong url.
    ///   Queue for completion to run is up to the user.
    func load(_ completion: @escaping (Result<T?, Error>) -> Void) where T: Decodable {
        
        synchronizeSaveLoadQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            guard let cacheUrl = self.cacheUrl else {
                completion(.failure(CacheError.wrongUrl))
                return
            }
            
            self.invalidateCacheIfNeeded()
            
            guard !self.cacheEmptyOrExpired else {
                completion(.success(nil))
                return
            }
            
            self.storageQueue.sync { [weak self] in
                guard let self = self else {
                    return
                }
                
                let result = Result {
                    try Data(contentsOf: cacheUrl)
                }
                
                switch result {
                case .success(let data):
                    self.parser.parseDataToResource(data) { result in
                        switch result {
                        case .success(let resource):
                            completion(.success(resource))
                        case .failure(let failure):
                            completion(.failure(failure))
                        }
                    }
                case .failure(let failure):
                    completion(.failure(failure))
                }
            }
        }
    }
    
    var cacheEmptyOrExpired: Bool {
        UserSettings.cacheDate == nil
    }
    
    // MARK: - Private funcs
    private func invalidateCacheIfNeeded() {
        guard let lastSavedDate = UserSettings.cacheDate else {
            return
        }
        
        if lastSavedDate.addingTimeInterval(expirationTimeInterval) < Date() {
            UserSettings.cacheDate = nil
        }
    }
}

enum CacheError: Error {
    case wrongUrl
}

extension TimeInterval {
    static let minute: TimeInterval = 60
    static let hour: TimeInterval = 60 * 60
}


