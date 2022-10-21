//
//  CompanyNetworkModel.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

struct CompanyNetworkModel: Codable {
    let name: String
    let employees: [EmployeeNetworkModel]

    init() {
        name = ""
        employees = []
    }

    init(name: String, employees: [EmployeeNetworkModel]) {
        self.name = name
        self.employees = employees
    }
}

extension CompanyNetworkModel {
    func sorted(by comparator: (EmployeeNetworkModel, EmployeeNetworkModel) -> Bool) -> Self {
        let employees = employees.sorted(by: comparator)
        return withNewEmployees(employees)
    }

    private func withNewEmployees(_ newEmployees: [EmployeeNetworkModel]) -> Self {
        CompanyNetworkModel(name: name, employees: newEmployees)
    }
}

extension CompanyNetworkModel {
    init(from company: Company) {
        let employees = company.employees.map { employee in
            EmployeeNetworkModel(name: employee.name.rawValue, phoneNumber: employee.phoneNumber.rawValue, skills: employee.skills)
        }

        self.init(name: company.name.rawValue, employees: employees)
    }
}
