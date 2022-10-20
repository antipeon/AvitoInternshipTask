//
//  EmployeeCell.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

import UIKit

final class EmployeeCell: UITableViewCell {
    static let reuseId = "EmployeeCellId"
    
    private lazy var nameLabel: InfoLabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = .left
//        label.font = UIFont.CustomFonts.medium
//        return label
        let label = InfoLabel(tagText: "Name")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var phoneLabel: InfoLabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = .left
//        label.font = UIFont.CustomFonts.medium
//        return label
        let label = InfoLabel(tagText: "Phone")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var skillsLabel: InfoLabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.numberOfLines = 0
//        label.textAlignment = .left
//        label.font = UIFont.CustomFonts.medium
//        return label
        let label = InfoLabel(tagText: "Skills")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.CustomColors.backSecondary
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(phoneLabel)
        contentView.addSubview(skillsLabel)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        layer.cornerRadius = 0
        clipsToBounds = false
        layer.maskedCorners = []
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constants.inset * 2),
            nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Constants.inset * 2),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.inset),
            
            phoneLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            phoneLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            phoneLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor),
            phoneLabel.bottomAnchor.constraint(equalTo: skillsLabel.topAnchor),

            skillsLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            skillsLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor),
            skillsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.inset)
        ])
    }
    
    func configureWithModel(_ model: EmployeeNetworkModel) {
        nameLabel.configureInfoText(infoViewText: model.name)
        phoneLabel.configureInfoText(infoViewText: model.phoneNumber)
        skillsLabel.configureInfoText(infoViewText: model.skills.appending("Bugfixfixfixfixfix").joined(separator: ", "))
    }
    
    private enum Constants {
        static let inset: CGFloat = 5
    }
}


extension CGRect {
    mutating func withWidth(_ width: CGFloat) -> CGRect {
        CGRect(origin: origin, size: CGSize(width: width, height: height))
    }
}

extension RangeReplaceableCollection {
    func appending(_ element: Element) -> Self {
        var new = self
        new.append(element)
        return new
    }
}

