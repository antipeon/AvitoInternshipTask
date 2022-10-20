//
//  InfoLabel.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 20.10.2022.
//

import UIKit

final class InfoLabel: UIView {
    // MARK: - Subviews
    private lazy var tagView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.CustomFonts.mediumBold
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var infoView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.CustomFonts.medium
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    // MARK: - init
    init(tagText: String) {
        super.init(frame: .zero)
        setUpSubviews()
        setUpConstraints()
        tagView.text = "\(tagText):"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public funcs
    func configureInfoText(infoViewText: String) {
        infoView.text = infoViewText
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - Private funcs
    private func setUpSubviews() {
        addSubview(tagView)
        addSubview(infoView)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            tagView.leftAnchor.constraint(equalTo: leftAnchor),
            tagView.topAnchor.constraint(equalTo: topAnchor),
            tagView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            
            infoView.leftAnchor.constraint(equalTo: tagView.rightAnchor),
            infoView.rightAnchor.constraint(equalTo: rightAnchor),
            infoView.topAnchor.constraint(equalTo: tagView.topAnchor),
            infoView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

