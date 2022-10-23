//
//  Cache.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

import Foundation

final class Cache<T, CacheDiskStorageT: CacheDiskStorageProtocol> {
    // MARK: - Private vars
    private let expirationTimeInterval: TimeInterval
    private let currentDateProvider: () -> Date
    private let parser: Parser<T>
    private let cacheDiskStorage: CacheDiskStorageT

    /// allow only one save/multiple-load operations at a time
    private let synchronizeSaveLoadQueue = DispatchQueue(label: "synchronizeSaveLoad", qos: .utility, attributes: .concurrent)

    // MARK: - init
    init(
        parser: Parser<T>,
        cacheDiskStorage: CacheDiskStorageT = CacheDiskStorage("network.cache"),
        invalidatationTimeInterval: TimeInterval = TimeInterval.minute,
        currentDateProvider: @escaping () -> Date = { Date() }
    ) {
        self.expirationTimeInterval = invalidatationTimeInterval
        self.parser = parser
        self.currentDateProvider = currentDateProvider
        self.cacheDiskStorage = cacheDiskStorage
    }

    // MARK: - API

    /// saves model to cache
    /// - Parameters:
    ///   - model: model to save to cache
    ///   - completion: Errors: parsing, writing to disk.
    ///   Queue for completion to run is up to the user.
    func save(_ model: T, completion: @escaping (Result<Void, Error>) -> Void) where T: Encodable {

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
                        UserSettings.cacheDate = Date()
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
    func load(_ completion: @escaping (Result<T?, Error>) -> Void) where T: Decodable {

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
        UserSettings.cacheDate == nil
    }

    // MARK: - Private funcs
    private func invalidateCacheIfNeeded() {
        guard let lastSavedDate = UserSettings.cacheDate else {
            return
        }

        if lastSavedDate.addingTimeInterval(expirationTimeInterval) < currentDateProvider() {
            UserSettings.cacheDate = nil
        }
    }
}

extension TimeInterval {
    static let minute: TimeInterval = 60
    static let hour: TimeInterval = 60 * 60
}
