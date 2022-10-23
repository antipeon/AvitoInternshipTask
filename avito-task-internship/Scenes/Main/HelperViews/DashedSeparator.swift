//
//  DashedSeparator.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 20.10.2022.
//

import UIKit

final class DashedSeparator: UIView {

    override func draw(_ rect: CGRect) {
        let  path = UIBezierPath()

        let  point0 = CGPoint(x: self.bounds.minX, y: self.bounds.midY)
        path.move(to: point0)

        let  point1 = CGPoint(x: self.bounds.maxX, y: self.bounds.midY)
        path.addLine(to: point1)

        let dashes: [CGFloat] = [4.0, 8.0]
        path.setLineDash(dashes, count: dashes.count, phase: 0.0)

        path.lineCapStyle = .butt
        UIColor.CustomColors.separator?.set()
        path.stroke()
        path.fill()
    }
}
