//
//  Seeds.swift
//  Tests
//
//  Created by Samat Gaynutdinov on 22.10.2022.
//

@testable import avito_task_internship
import XCTest

enum Seeds {
    enum CompanyNetworkResponseModels {
        static let empty = CompanyNetworkResponseModel()
        static let invalid = CompanyNetworkResponseModel(
            company: CompanyNetworkModel(
                name: "invalidName",
                employees: [])
        )
        static let oneManCompany = CompanyNetworkResponseModel(
            company: CompanyNetworkModel(
                name: "Oneman",
                employees: [
                    EmployeeNetworkModel(
                        name: "John",
                        phoneNumber: "777777",
                        skills: ["Everything"]
                    )
                ]
            )
        )
        static let twoManCompany = CompanyNetworkResponseModel(
            company: CompanyNetworkModel(
                name: "Twoman",
                employees: [
                    EmployeeNetworkModel(
                        name: "Jessica",
                        phoneNumber: "654321",
                        skills: ["Java", "Spring"]
                    ),
                    EmployeeNetworkModel(
                        name: "Dave",
                        phoneNumber: "123456",
                        skills: ["Javascript", "React"]
                    )
                ]
            )
        )
    }
    enum Companys {
        static let empty = Company(name: EmployeeName(rawValue: "Notbig")!, employees: [])
        static let twoManCompany = Company(
            name: EmployeeName(rawValue: "Twoman")!,
            employees: [
                Employee(
                    name: EmployeeName(rawValue: "Jessica")!,
                    phoneNumber: PhoneNumber(rawValue: "654321")!,
                    skills: ["Java", "Spring"]
                ),
                Employee(
                    name: EmployeeName(rawValue: "Dave")!,
                    phoneNumber: PhoneNumber(rawValue: "123456")!,
                    skills: ["Javascript", "React"]
                )
            ]
        )
    }
}
