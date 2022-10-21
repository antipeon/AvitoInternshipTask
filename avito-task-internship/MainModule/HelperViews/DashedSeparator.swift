//
//  DashedSeparator.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 20.10.2022.
//

import UIKit

class DashedSeparator: UIView {

    override func draw(_ rect: CGRect) {
        let  path = UIBezierPath()

        let  p0 = CGPoint(x: self.bounds.minX, y: self.bounds.midY)
        path.move(to: p0)

        let  p1 = CGPoint(x: self.bounds.maxX, y: self.bounds.midY)
        path.addLine(to: p1)

//        let  dashes: [ CGFloat ] = [ 16.0, 32.0 ]
        let dashes: [CGFloat] = [4.0, 8.0]
        path.setLineDash(dashes, count: dashes.count, phase: 0.0)

//        path.lineWidth = 8.0
        path.lineCapStyle = .butt
        UIColor.CustomColors.separator?.set()
//        UIColor.white.setStroke()
//        UIColor.CustomColors.separator?.setStroke()
        path.stroke()
        path.fill()
    }

}
