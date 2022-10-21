//
//  EmployeeName.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 21.10.2022.
//

struct EmployeeName {
    private let name: String
    private init(name: String) {
        self.name = name
    }
}

extension EmployeeName: RawRepresentable {
    var rawValue: String {
        name
    }

    init?(rawValue: String) {
        guard rawValue.capitalized == rawValue else {
            return nil
        }

        guard rawValue.allSatisfy({ symbol in
            symbol.isLetter
        }) else {
            return nil
        }

        self.init(name: rawValue)
    }
}
