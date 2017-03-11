//
//  xAxizView.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 11.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class xAxizView: UIView {

    override func draw(_ rect: CGRect) {
        switch period() {
        case .day:
            drawHours(rect)
        case .week:
            drawWeekDays(rect)
        case .mongth, .lastMongth:
            drawDays(rect)
        default:
            break
        }
    }

    func drawHours(_ rect: CGRect) {
        var textRect = CGRect(x: 30, y: 0, width: 20, height: 20)
        let stepX = (rect.size.width - 60) / CGFloat(GraphView.intervalCount())
        var hour = 0
        for _ in 0...GraphView.intervalCount() {
            let text = "\(hour)" as NSString
            text.draw(UIFont.condensedFont(12), color: UIColor.white, rect: textRect)
            hour += 2
            textRect.origin.x += stepX
        }
    }
    
    func drawWeekDays(_ rect: CGRect) {
        let days = [
            NSLocalizedString("day1", comment: "") as NSString,
            NSLocalizedString("day2", comment: "") as NSString,
            NSLocalizedString("day3", comment: "") as NSString,
            NSLocalizedString("day4", comment: "") as NSString,
            NSLocalizedString("day5", comment: "") as NSString,
            NSLocalizedString("day6", comment: "") as NSString,
            NSLocalizedString("day7", comment: "") as NSString,
        ]
        var textRect = CGRect(x: 15, y: 0, width: 50, height: 20)
        let stepX = (rect.size.width - 60) / CGFloat(GraphView.intervalCount())
        for i in 0...GraphView.intervalCount() {
            let text = days[i]
            text.draw(UIFont.condensedFont(12), color: UIColor.white, rect: textRect)
            textRect.origin.x += stepX
        }
    }
    
    func drawDays(_ rect: CGRect) {
        var textRect = CGRect(x: 30, y: 0, width: 20, height: 20)
        let stepX = (rect.size.width - 60) / CGFloat(GraphView.intervalCount())
        var day = 1
        for _ in 0...GraphView.intervalCount() {
            let text = "\(day)" as NSString
            text.draw(UIFont.condensedFont(12), color: UIColor.white, rect: textRect)
            day += 2
            textRect.origin.x += stepX
        }
    }
}

extension NSString {
    
    func draw(_ font:UIFont, color:UIColor, rect:CGRect, alignment:NSTextAlignment = .center) {
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = alignment
        
        let textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        let size = self.size(attributes: textFontAttributes)
        let r = CGRect(x: rect.origin.x,
                       y: rect.origin.y + (rect.size.height - size.height)/2.0,
                       width: rect.size.width,
                       height: size.height)
        
        self.draw(in: r, withAttributes: textFontAttributes)
    }
    
}

