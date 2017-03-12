//
//  GraphView.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 11.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import CoreData

class GraphView: UIView {

    var objects:[NSManagedObject] = []
    var range:(min:Double, max:Double)?

    let secondsPerDay:TimeInterval = 24*60*60
    let secondsPerWeek:TimeInterval = 24*60*60*7
    let secondsPerMonth:TimeInterval = 24*60*60*31
    
    private var gradient:CGGradient?
    
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
        drawGraph(rect)
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
        } else {
            yAxiz.move(to: CGPoint(x: origin.x + (rect.size.width - 20), y: origin.y+5))
            yAxiz.addLine(to: CGPoint(x: origin.x + (rect.size.width - 20), y: 5))
            yAxiz.stroke()
        }
    }
    
    func drawGraph(_ rect: CGRect) {
        if range == nil {
            return
        }
        
        var timeLength:TimeInterval = 0
        var startTime:TimeInterval = 0
        
        switch period() {
        case .day:
            timeLength = secondsPerDay
            startTime = today()!.timeIntervalSince1970
        case .week:
            timeLength = secondsPerWeek
            startTime = lastWeek()!.timeIntervalSince1970
        case .mongth:
            timeLength = secondsPerMonth
            startTime = lastMongth()!.timeIntervalSince1970
        case .lastMongth:
            timeLength = secondsPerMonth
            startTime = previouseMongth()!.timeIntervalSince1970
        case .all:
            timeLength = Model.shared.objectDate(objects[0])!.timeIntervalSince1970 - Model.shared.objectDate(objects.last!)!.timeIntervalSince1970
            startTime = Model.shared.objectDate(objects.last!)!.timeIntervalSince1970
        }
        
        let origin = CGPoint(x: 10, y: rect.size.height - 10)
        let timeScale:CGFloat = (rect.size.width - 20) / CGFloat(timeLength)
        let valueScale:CGFloat = (rect.size.height - 20) / CGFloat(range!.max - range!.min)
        
        if valueType() == .blood {
            var blood = objects.last as! Blood
            let graph = UIBezierPath()
            UIColor.bloodColor().setStroke()
            graph.lineWidth = IS_PAD() ? 5 : 3
            var d = CGFloat(Model.shared.objectDate(blood)!.timeIntervalSince1970 - startTime)
            var v = CGFloat(blood.value - range!.min)
            graph.move(to: CGPoint(x: (origin.x + d*timeScale), y: (origin.y - v*valueScale)))

            for i in (0..<objects.count-1).reversed() {
                blood = objects[i] as! Blood
                if (blood.value > 0) {
                    d = CGFloat(Model.shared.objectDate(blood)!.timeIntervalSince1970 - startTime)
                    v = CGFloat(blood.value - range!.min)
                    graph.addLine(to: CGPoint(x: (origin.x + d*timeScale), y: (origin.y - v*valueScale)))
                }
            }
            graph.stroke()
        } else {
            func drawPressure(high:Bool) {
                var pressure = objects.last as! Pressure
                let graph = UIBezierPath()
                if high {
                    UIColor.bloodColor().setStroke()
                } else {
                    UIColor.mainColor().setStroke()
                }
                graph.lineWidth = IS_PAD() ? 5 : 3
                var d = CGFloat(Model.shared.objectDate(pressure)!.timeIntervalSince1970 - startTime)
                var v = CGFloat((high ? pressure.highValue : pressure.lowValue) - range!.min)
                graph.move(to: CGPoint(x: (origin.x + d*timeScale), y: (origin.y - v*valueScale)))
                
                for i in (0..<objects.count-1).reversed() {
                    pressure = objects[i] as! Pressure
                    if high && pressure.highValue == 0 {
                        continue
                    }
                    if !high && pressure.lowValue == 0 {
                        continue
                    }
                    d = CGFloat(Model.shared.objectDate(pressure)!.timeIntervalSince1970 - startTime)
                    v = CGFloat((high ? pressure.highValue : pressure.lowValue) - range!.min)
                    graph.addLine(to: CGPoint(x: (origin.x + d*timeScale), y: (origin.y - v*valueScale)))
                }
                graph.stroke()
            }
            drawPressure(high: true)
            drawPressure(high: false)
        }

    }
}
