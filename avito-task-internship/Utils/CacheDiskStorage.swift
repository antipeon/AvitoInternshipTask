//
//  CacheDiskStorage.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 19.10.2022.
//

import Foundation

final class CacheDiskStorage {
    private let cacheUrl: URL
    
    init(_ filename: String) {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(filename)
        
        guard let url = url else {
            assert(false, "something is wrong with disk")
        }
        
        cacheUrl = url
    }
    
    func save(_ data: Data) throws {
        try data.write(to: cacheUrl)
    }
    
    func loadData() throws -> Data {
        try Data(contentsOf: cacheUrl)
    }
}
