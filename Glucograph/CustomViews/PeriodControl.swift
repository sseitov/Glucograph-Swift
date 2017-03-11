//
//  PeriodControl.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 11.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class PeriodControl: UISegmentedControl {

    override func awakeFromNib() {
        super.awakeFromNib()
        setTitle(NSLocalizedString("Today", comment: ""), forSegmentAt: 0)
        setTitle(NSLocalizedString("Week", comment: ""), forSegmentAt: 1)
        setTitle(NSLocalizedString("This Mongth", comment: ""), forSegmentAt: 2)
        setTitle(NSLocalizedString("Last Mongth", comment: ""), forSegmentAt: 3)
        setTitle(NSLocalizedString("All", comment: ""), forSegmentAt: 4)
        addTarget(self, action: #selector(self.periodControlChange(control:)), for: .valueChanged)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        selectedSegmentIndex = period().rawValue
    }
    
    func periodControlChange(control:UISegmentedControl) {
        switch control.selectedSegmentIndex {
        case 0:
            changePeriod(.day)
        case 1:
            changePeriod(.week)
        case 2:
            changePeriod(.mongth)
        case 3:
            changePeriod(.lastMongth)
        default:
            changePeriod(.all)
        }
        NotificationCenter.default.post(name: refreshNotification, object: nil)
    }

}
