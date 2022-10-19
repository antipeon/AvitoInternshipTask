//
//  Parser.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 19.10.2022.
//

import Foundation

final class Parser<T> {
    // MARK: - Private vars
    private let parserQueue = DispatchQueue(label: "parserQueue", qos: .utility)
    
    // MARK: - API
    func parseDataToResource(_ data: Data, completion: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        parserQueue.async { [data] in
            let resource = try? JSONDecoder().decode(T.self, from: data)
            
            guard let resource = resource else {
                completion(.failure(ParseError.parseError))
                return
            }
            
            completion(.success(resource))
        }
    }
    
    func parseResourceToData(_ resource: T, completion: @escaping (Result<Data, Error>) -> Void) where T: Encodable {
        parserQueue.async { [resource] in
            
            let data = try? JSONEncoder().encode(resource)
            
            guard let data = data else {
                completion(.failure(ParseError.parseError))
                return
            }
            
            completion(.success(data))
        }
    }
}

enum ParseError: Error {
    case parseError
}

