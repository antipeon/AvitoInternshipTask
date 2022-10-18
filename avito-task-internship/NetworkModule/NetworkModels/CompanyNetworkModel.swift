//
//  CompanyNetworkModel.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

struct CompanyNetworkModel: Codable {
    let name: String
    let employees: [EmployeeNetworkModel]
}
