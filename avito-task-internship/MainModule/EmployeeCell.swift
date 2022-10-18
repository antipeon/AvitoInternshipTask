//
//  EmployeeCell.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

import UIKit

final class EmployeeCell: UITableViewCell {
    static let reuseId = "EmployeeCellId"
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
//        label.backgroundColor = .yellow
        return label
    }()
    
    private lazy var phoneLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
//        label.backgroundColor = .red
        return label
    }()
    
    private lazy var skillsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
//        label.backgroundColor = .blue
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(phoneLabel)
        contentView.addSubview(skillsLabel)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        nameLabel.sizeToFit()
//        phoneLabel.sizeToFit()
//        skillsLabel.sizeToFit()
//
//        nameLabel.frame = nameLabel.frame.withWidth(contentView.bounds.width)
//        phoneLabel.frame = phoneLabel.frame.withWidth(contentView.bounds.width)
//        skillsLabel.frame = skillsLabel.frame.withWidth(contentView.bounds.width)
//
//        nameLabel.frame.origin = contentView.bounds.origin
//        phoneLabel.frame.origin = CGPoint(x: contentView.bounds.origin.x, y: contentView.bounds.origin.y + nameLabel.bounds.height)
//        skillsLabel.frame.origin = CGPoint(x: contentView.bounds.origin.x, y: contentView.bounds.origin.y + nameLabel.bounds.height + phoneLabel.bounds.height)
//    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            phoneLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            phoneLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            phoneLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor),
            phoneLabel.bottomAnchor.constraint(equalTo: skillsLabel.topAnchor),
            
//            skillsLabel.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor),
            skillsLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            skillsLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor),
            skillsLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
    
    func configureWithModel(_ model: EmployeeNetworkModel) {
        nameLabel.text = model.name
//        phoneLabel.text = model.phoneNumber.number
        phoneLabel.text = model.phoneNumber
        skillsLabel.text = model.skills.joined(separator: ", ")
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
}


extension CGRect {
    mutating func withWidth(_ width: CGFloat) -> CGRect {
        CGRect(origin: origin, size: CGSize(width: width, height: height))
    }
}
