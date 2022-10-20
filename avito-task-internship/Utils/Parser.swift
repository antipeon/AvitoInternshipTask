//
//  Parser.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 19.10.2022.
//

import Foundation

final class Parser<T> {
    // MARK: - Private vars
    private let parserQueue = DispatchQueue(label: "parserQueue", qos: .utility, attributes: .concurrent)
    
    // MARK: - API
    func parseDataToModel(_ data: Data, completion: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        parserQueue.async { [data] in
            
            guard let model = try? JSONDecoder().decode(T.self, from: data) else {
                completion(.failure(ParseError.parseError))
                return
            }
            
            completion(.success(model))
        }
    }
    
    func parseModelToData(_ model: T, completion: @escaping (Result<Data, Error>) -> Void) where T: Encodable {
        parserQueue.async { [model] in
            
            guard let data = try? JSONEncoder().encode(model) else {
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

