//
//  UserSettings.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

import Foundation

protocol UserDefaultsWrapperProtocol {
    var cacheDate: Date? { get set }
}

final class UserSettings {
    static var shared = UserDefaultsWrapper()
}

final class UserDefaultsWrapper: UserDefaultsWrapperProtocol {
    @Storage(key: "cacheDate", defaultValue: nil)
    var cacheDate: Date?
}

@propertyWrapper
struct Storage<T: Codable> {
    private let key: String
    private let defaultValue: T

    var wrappedValue: T {
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

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
}
