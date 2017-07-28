//
//  yAxizView.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 12.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class yAxizView: UIView {

    var range:(min:Double, max:Double)?
    
    override func draw(_ rect: CGRect) {
        if range == nil {
            return
        }
        var textRect = CGRect(x: 0, y: rect.size.height - 20, width: 30, height: 20)
        let stepY:CGFloat = (rect.size.height - 30) / 10
        let stepVal = (range!.max - range!.min)/10
        var val = range!.min
        for _ in 0...10 {
            let text = glucType() == .pressure ? NSString(format: "%d", Int(val)) : NSString(format: "%.1f", val)
            text.draw(UIFont.condensedFont(12), color: UIColor.white, rect: textRect)
            val += stepVal
            textRect.origin.y -= stepY
        }
    }
    
}
