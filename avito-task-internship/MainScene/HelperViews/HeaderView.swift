//
//  HeaderView.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 19.10.2022.
//

import UIKit

final class HeaderView: UITableViewHeaderFooterView {
    static let reuseId = "HeaderViewId"

    // MARK: - Subviews
    private lazy var titleView: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.CustomFonts.large
        return label
    }()

    // MARK: - init
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        titleView.sizeToFit()
        titleView.frame.origin = CGPoint(
            x: (contentView.bounds.width - titleView.bounds.width) / 2,
            y: (contentView.bounds.height - titleView.bounds.height) / 2
        )
    }

    // MARK: - Public funcs
    func setTitle(_ title: String) {
        titleView.text = title
    }
}
