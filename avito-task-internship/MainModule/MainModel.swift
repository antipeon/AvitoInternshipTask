//
//  MainModel.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

import Foundation

final class MainModel {
    // MARK: - Private vars
    private var companyModel = CompanyNetworkResponseModel(company: CompanyNetworkModel(name: "", employees: []))
    private let networkService: NetworkService
    
    // MARK: - init
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    // MARK: - API
    var employees: [EmployeeNetworkModel] {
        companyModel.company.employees
    }
    
    var companyName: String {
        companyModel.company.name
    }
    
    var networkRequestCallback: ((Error?) -> Void)?
    
    func fetchData() {
        networkService.fetchData { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let success):
                self.companyModel = success
                self.networkRequestCallback?(nil)
            case .failure(let error):
                self.networkRequestCallback?(error)
            }
        }
    }
}
