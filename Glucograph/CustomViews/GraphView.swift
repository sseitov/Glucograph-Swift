//
//  GraphView.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 11.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class GraphView: UIView {

    var gradient:CGGradient?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupBorder(UIColor.clear, radius: 10)
        
        let colours = [UIColor.color(128, 128, 128, 1).cgColor,
                       UIColor.color(164, 164, 164, 1).cgColor,
                       UIColor.color(206, 206, 206, 1).cgColor] as CFArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        gradient = CGGradient(colorsSpace: colorSpace, colors: colours , locations: nil)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        context?.drawLinearGradient(gradient!,
                                    start: CGPoint(), end: CGPoint(x:0, y:rect.size.height),
                                    options: CGGradientDrawingOptions(rawValue: 0))
        drawAxiz(rect)
    }

    func drawAxiz(_ rect: CGRect) {
        UIColor.darkGray.setStroke()
        let origin = CGPoint(x: 10, y: rect.size.height - 10)
        
        let xAxiz = UIBezierPath()
        xAxiz.move(to: CGPoint(x: origin.x - 5, y: origin.y))
        xAxiz.addLine(to: CGPoint(x: rect.size.width-5, y: origin.y))
        xAxiz.stroke()
        
        let stepY = (rect.size.height - 20) / 10
        var offsetY:CGFloat = origin.y - stepY
        let  dashes: [ CGFloat ] = [ 4.0, 4.0 ]
        xAxiz.setLineDash(dashes, count: dashes.count, phase: 0)
        xAxiz.lineWidth = 0.5
        for _ in 0..<10 {
            xAxiz.move(to: CGPoint(x: origin.x - 5, y: offsetY))
            xAxiz.addLine(to: CGPoint(x: rect.size.width-5, y: offsetY))
            xAxiz.stroke()
            offsetY -= stepY
        }
        
        let yAxiz = UIBezierPath()
        yAxiz.move(to: CGPoint(x: origin.x, y: origin.y+5))
        yAxiz.addLine(to: CGPoint(x: origin.x, y: 5))
        yAxiz.stroke()
        if period() != .all {
            let stepX = (rect.size.width - 20) / CGFloat(GraphView.intervalCount())
            var offsetX:CGFloat = stepX
            yAxiz.setLineDash(dashes, count: dashes.count, phase: 0)
            yAxiz.lineWidth = 0.5
            for _ in 0..<GraphView.intervalCount() {
                yAxiz.move(to: CGPoint(x: origin.x+offsetX, y: origin.y+5))
                yAxiz.addLine(to: CGPoint(x: origin.x+offsetX, y: 5))
                yAxiz.stroke()
                offsetX += stepX
            }
        }
    }
    
    class func intervalCount() -> Int {
        switch period() {
        case .day:
            return 12
        case .week:
            return 6
        default:
            return 15
        }
    }
}
