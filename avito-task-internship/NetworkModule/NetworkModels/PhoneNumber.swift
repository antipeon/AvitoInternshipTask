//
//  PhoneNumber.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

struct PhoneNumber: RawRepresentable, Codable {
    private let number: String

    // MARK: - RawRepresentable
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

        self.number = rawValue
    }

    // MARK: - Constants
    private enum Constants {
        static let numberLength = 6
    }
}
