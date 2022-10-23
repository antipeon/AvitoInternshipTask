//
//  NetworkAPI.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 23.10.2022.
//

import Foundation

protocol NetworkApiProtocol {
    func performRequest(
        callback: @escaping (Data?, URLResponse?, Error?) -> Void
    )
}

final class NetworkAPI: NetworkApiProtocol {
    private let request: URLRequest = {
        let url = URL(string: Constants.urlString)
        guard let url = url else {
            fatalError("incorrect url")
        }

        return URLRequest(url: url)
    }()

    private let urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = Constants.timeoutTimeInterval
        let session = URLSession(configuration: configuration)
        return session
    }()

    func performRequest(
        callback: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        let task = urlSession.dataTask(with: request, completionHandler: callback)
        task.resume()
    }

    // MARK: - Constants
    enum Constants {
        static let timeoutTimeInterval: TimeInterval = 7
        static let urlString = "https://run.mocky.io/v3/1d1cb4ec-73db-4762-8c4b-0b8aa3cecd4c"
    }
}
