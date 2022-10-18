//
//  CompanyNetworkResponseModel.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 17.10.2022.
//

/// Decodable for network request; Codable for storing to cache
struct CompanyNetworkResponseModel: Codable {
    let company: CompanyNetworkModel
}
