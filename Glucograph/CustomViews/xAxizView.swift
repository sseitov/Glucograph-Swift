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
        case .week:
            drawWeekDays(rect)
        case .monthDate:
            drawDays(rect)
        default:
            drawStartEnd(rect)
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
    
    func drawStartEnd(_ rect: CGRect) {
        if valueType() == .blood {
            if let first = Model.shared.myLastBlood(true) {
                let textRect = CGRect(x: 30, y: 0, width: 100, height: 20)
                let text = dateString(first.date as Date?) as NSString
                text.draw(UIFont.condensedFont(15), color: UIColor.white, rect: textRect, alignment:.left)
            }
            if let last = Model.shared.myLastBlood() {
                let textRect = CGRect(x: bounds.size.width - 110, y: 0, width: 100, height: 20)
                let text = dateString(last.date as Date?) as NSString
                text.draw(UIFont.condensedFont(15), color: UIColor.white, rect: textRect, alignment:.right)
            }
        } else {
            if let first = Model.shared.myLastPressure(true) {
                let textRect = CGRect(x: 30, y: 0, width: 100, height: 20)
                let text = dateString(first.date as Date?) as NSString
                text.draw(UIFont.condensedFont(15), color: UIColor.white, rect: textRect, alignment:.left)
            }
            if let last = Model.shared.myLastPressure() {
                let textRect = CGRect(x: bounds.size.width - 110, y: 0, width: 100, height: 20)
                let text = dateString(last.date as Date?) as NSString
                text.draw(UIFont.condensedFont(15), color: UIColor.white, rect: textRect, alignment:.right)
            }
        }
    }
}
