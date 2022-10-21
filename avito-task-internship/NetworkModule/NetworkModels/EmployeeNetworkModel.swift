//
//  EmployeeNetworkModel.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

struct EmployeeNetworkModel: Codable {
    let name: String
    let phoneNumber: String
    let skills: [String]

    enum CodingKeys: String, CodingKey {
        case name
        case phoneNumber = "phone_number"
        case skills
    }
}
