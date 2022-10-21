//
//  EmployeeCell.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 18.10.2022.
//

import UIKit

final class EmployeeCell: UITableViewCell {
    static let reuseId = "EmployeeCellId"

    // MARK: - Subviews
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.cornerRadius
        view.backgroundColor = UIColor.CustomColors.backSecondary
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.CustomColors.border?.cgColor
        return view
    }()

    private lazy var nameLabel: InfoLabel = {
        let label = InfoLabel(tagText: "Name")
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var phoneLabel: InfoLabel = {
        let label = InfoLabel(tagText: "Phone")
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var phoneLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .CustomColors.overlay
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var skillsLabel: InfoLabel = {
        let label = InfoLabel(tagText: "Skills")
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - TraitCollection
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            containerView.layer.borderColor = UIColor.CustomColors.border?.cgColor
        }
    }

    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        setUpSubviews()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private funcs
    private func setUpSubviews() {
        contentView.addSubview(containerView)

        phoneLabelContainer.addSubview(phoneLabel)

        containerView.addSubview(nameLabel)
        containerView.addSubview(phoneLabelContainer)
        containerView.addSubview(skillsLabel)
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.spaceBetweenCells),

            nameLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: Constants.labelInset * 2),
            nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -Constants.labelInset * 2),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.labelInset),

            phoneLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            phoneLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            phoneLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor),
            phoneLabel.bottomAnchor.constraint(equalTo: skillsLabel.topAnchor),

            phoneLabelContainer.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            phoneLabelContainer.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            phoneLabelContainer.topAnchor.constraint(equalTo: phoneLabel.topAnchor),
            phoneLabelContainer.bottomAnchor.constraint(equalTo: phoneLabel.bottomAnchor),

            skillsLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            skillsLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor),
            skillsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.labelInset)
        ])
    }

    // MARK: - Public funcs
    // TODO: remove this
    func configureWithModel(_ model: EmployeeNetworkModel) {
        nameLabel.configureInfoText(infoViewText: model.name)
        phoneLabel.configureInfoText(infoViewText: model.phoneNumber)
        skillsLabel.configureInfoText(infoViewText: model.skills.appending("Bugfixfixfixfixfix").joined(separator: ", "))
    }

    // MARK: - Constants
    enum Constants {
        fileprivate static let labelInset: CGFloat = 5
        fileprivate static let spaceBetweenCells: CGFloat = 6
        static let cornerRadius: CGFloat = 16
    }
}

// TODO: remove this
extension RangeReplaceableCollection {
    func appending(_ element: Element) -> Self {
        var new = self
        new.append(element)
        return new
    }
}
