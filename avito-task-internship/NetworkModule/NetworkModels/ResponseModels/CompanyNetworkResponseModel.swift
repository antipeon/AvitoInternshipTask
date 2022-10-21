//
//  CompanyNetworkResponseModel.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 17.10.2022.
//

/// Decodable for network request; Codable for storing to cache
struct CompanyNetworkResponseModel: Codable {
    let company: CompanyNetworkModel
    
    init(company: CompanyNetworkModel) {
        self.company = company
    }
    
    init() {
        self.init(company: CompanyNetworkModel(name: "", employees: []))
    }
}

extension CompanyNetworkResponseModel {
    func sorted(by comparator: (EmployeeNetworkModel, EmployeeNetworkModel) -> Bool) -> Self {
        let employees = company.employees.sorted(by: comparator)
        return withNewEmployees(employees)
    }
    
    private func withNewEmployees(_ newEmployees: [EmployeeNetworkModel]) -> Self {
        CompanyNetworkResponseModel(company: CompanyNetworkModel(name: company.name, employees: newEmployees))
    }
}
