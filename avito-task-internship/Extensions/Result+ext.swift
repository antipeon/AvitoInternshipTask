//
//  Result+ext.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 22.10.2022.
//

extension Result {
    func extractedError() -> Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}
