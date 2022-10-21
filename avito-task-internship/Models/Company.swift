//
//  Company.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 21.10.2022.
//

import Foundation

struct Company {
    typealias CompanyName = EmployeeName

    var name: CompanyName
    var employees: [Employee]
}

extension Company {
    init?(from model: CompanyNetworkModel) {
        guard let name = CompanyName(rawValue: model.name) else {
            return nil
        }

        let employees = model.employees.compactMap { (employee: EmployeeNetworkModel) -> Employee? in
            guard let name = EmployeeName(rawValue: employee.name) else {
                return nil
            }
            guard let phoneNumber = PhoneNumber(rawValue: employee.phoneNumber) else {
                return nil
            }
            return Employee(name: name, phoneNumber: phoneNumber, skills: employee.skills)
        }

        guard employees.count == model.employees.count else {
            return nil
        }

        self.init(name: name, employees: employees)
    }
}
