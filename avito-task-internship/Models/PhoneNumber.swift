//
//  PhoneNumber.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

struct PhoneNumber {
    private let number: String

    private init(number: String) {
        self.number = number
    }

    // MARK: - Constants
    private enum Constants {
        static let numberLength = 6
    }
}

extension PhoneNumber: RawRepresentable {
    var rawValue: String {
        number
    }

    init?(rawValue: String) {
        guard rawValue.count == Constants.numberLength else {
            return nil
        }

        guard Int(rawValue) != nil else {
            return nil
        }

        self.init(number: rawValue)
    }
}
