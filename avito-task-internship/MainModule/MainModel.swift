//
//  MainModel.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

import Foundation

final class MainModel {
    // MARK: - Private vars
    private var companyModel = CompanyNetworkResponseModel()
    private let networkService: NetworkService
    
    // MARK: - init
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    // MARK: - API
    weak var networkSubscriber: NetworkSubscriber?
    
    var employees: [EmployeeNetworkModel] {
        companyModel.company.employees
    }
    
    var companyName: String {
        companyModel.company.name
    }
    
    var networkRequestCallback: ((Error?) -> Void)?
    
    func fetchData() {
        networkSubscriber?.networkRequestDidStart()
        
        networkService.fetchData { [weak self] result in
            guard let self = self else {
                return
            }
            
            defer {
                self.networkSubscriber?.networkResponseDidReceive()
            }
            
            switch result {
            case .success(let model):
                self.companyModel = model.sorted { employee1, employee2 in
                    employee1.name < employee2.name
                }
                self.networkRequestCallback?(nil)
            case .failure(let error):
                self.networkRequestCallback?(error)
            }
        }
    }
}

// MARK: - NetworkSubscriber
protocol NetworkSubscriber: AnyObject {
    func networkRequestDidStart()
    func networkResponseDidReceive()
}
