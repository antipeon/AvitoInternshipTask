//
//  Parser.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 19.10.2022.
//

import Foundation

protocol DecodableParserProtocol {
    associatedtype D: Decodable
    func parseDataToModel(_ data: Data, completion: @escaping (Result<D, Error>) -> Void)
}

protocol EncodableParserProtocol {
    associatedtype E: Encodable
    func parseModelToData(_ model: E, completion: @escaping (Result<Data, Error>) -> Void)
}

final class Parser<T> {
    // MARK: - Private vars
    private let parserQueue = DispatchQueue(label: "parserQueue", qos: .utility, attributes: .concurrent)
}

// MARK: - API
extension Parser: DecodableParserProtocol where T: Decodable {
    func parseDataToModel(_ data: Data, completion: @escaping (Result<T, Error>) -> Void) {
        parserQueue.async { [data] in

            guard let model = try? JSONDecoder().decode(T.self, from: data) else {
                completion(.failure(ParseError.parseError))
                return
            }

            completion(.success(model))
        }
    }
}

extension Parser: EncodableParserProtocol where T: Encodable {
    func parseModelToData(_ model: T, completion: @escaping (Result<Data, Error>) -> Void) {
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
