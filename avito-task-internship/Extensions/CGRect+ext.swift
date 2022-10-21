//
//  CGRect+ext.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 21.10.2022.
//

import UIKit

extension CGRect {
    func withWidth(_ width: CGFloat) -> CGRect {
        CGRect(origin: origin, size: CGSize(width: width, height: height))
    }
}
