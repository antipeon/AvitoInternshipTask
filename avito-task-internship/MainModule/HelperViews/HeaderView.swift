//
//  HeaderView.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 19.10.2022.
//

import UIKit

final class HeaderView: UITableViewHeaderFooterView {
    static let reuseId = "HeaderViewId"
    
    lazy var title: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.CustomFonts.large
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        title.sizeToFit()
        title.frame.origin = CGPoint(
            x: (contentView.bounds.width - title.bounds.width) / 2,
            y: (contentView.bounds.height - title.bounds.height) / 2
        )
    }
}

