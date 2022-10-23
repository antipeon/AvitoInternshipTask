//
//  Cache.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

import Foundation

protocol CacheProtocol {
    associatedtype T: Codable
    func save(_ model: T, completion: @escaping (Result<Void, Error>) -> Void)
    func load(_ completion: @escaping (Result<T?, Error>) -> Void)
}

final class Cache<T: Codable, CacheDiskStorageT: CacheDiskStorageProtocol>: CacheProtocol {

    // MARK: - Private vars
    private let expirationTimeInterval: TimeInterval
    private let parser = Parser<T>()
    private let cacheDiskStorage: CacheDiskStorageT
    private var userDefaults: UserDefaultsWrapperProtocol
    private let currentDateProvider: () -> Date

    /// allow only one save/multiple-load operations at a time
    private let synchronizeSaveLoadQueue = DispatchQueue(label: "synchronizeSaveLoad", qos: .utility, attributes: .concurrent)

    // MARK: - init
    init(
        cacheDiskStorage: CacheDiskStorageT = CacheDiskStorage("network.cache"),
        invalidatationTimeInterval: TimeInterval = TimeInterval.minute,
        currentDateProvider: @escaping () -> Date = { Date() },
        userDefaults: UserDefaultsWrapperProtocol = UserSettings.shared
    ) {
        self.expirationTimeInterval = invalidatationTimeInterval
        self.currentDateProvider = currentDateProvider
        self.cacheDiskStorage = cacheDiskStorage
        self.userDefaults = userDefaults
    }

    // MARK: - API

    /// saves model to cache
    /// - Parameters:
    ///   - model: model to save to cache
    ///   - completion: Errors: parsing, writing to disk.
    ///   Queue for completion to run is up to the user.
    func save(_ model: T, completion: @escaping (Result<Void, Error>) -> Void) {

        synchronizeSaveLoadQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }

            let group = DispatchGroup()
            group.enter()

            self.parser.parseModelToData(model) { [weak self] result in
                defer {
                    group.leave()
                }

                guard let self = self else {
                    return
                }

                switch result {
                case .success(let data):
                    let result = Result {
                        try self.cacheDiskStorage.save(data)
                        self.userDefaults.cacheDate = self.currentDateProvider()
                    }
                    completion(result)
                case .failure(let error):
                    completion(.failure(error))
                }
            }

            group.wait()
        }
    }

    /// Loads model from cache
    /// - Parameters:
    ///   - completion: Model from cache; nil if no model or model is expired. Error: parsing, reading from disk, wrong url.
    ///   Queue for completion to run is up to the user.
    func load(_ completion: @escaping (Result<T?, Error>) -> Void) {

        synchronizeSaveLoadQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.invalidateCacheIfNeeded()

            guard !self.cacheEmptyOrExpired else {
                completion(.success(nil))
                return
            }

            let result = Result {
                try self.cacheDiskStorage.loadData()
            }

            switch result {
            case .success(let data):
                self.parser.parseDataToModel(data) { result in
                    switch result {
                    case .success(let model):
                        completion(.success(model))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    var cacheEmptyOrExpired: Bool {
        userDefaults.cacheDate == nil
    }

    // MARK: - Private funcs
    private func invalidateCacheIfNeeded() {
        guard let lastSavedDate = userDefaults.cacheDate else {
            return
        }

        if lastSavedDate.addingTimeInterval(expirationTimeInterval) < currentDateProvider() {
            userDefaults.cacheDate = nil
        }
    }
}

extension TimeInterval {
    static let minute: TimeInterval = 60
    static let hour: TimeInterval = 60 * 60
}
