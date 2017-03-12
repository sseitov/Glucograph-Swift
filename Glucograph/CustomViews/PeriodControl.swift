//
//  PeriodControl.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 11.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class PeriodControl: UISegmentedControl {

    let changePeriodNotification = Notification.Name("CHANGE_PERIOD")
 
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTitle(NSLocalizedString("Today", comment: ""), forSegmentAt: 0)
        setTitle(NSLocalizedString("Week", comment: ""), forSegmentAt: 1)
        setTitle(NSLocalizedString("This Mongth", comment: ""), forSegmentAt: 2)
        setTitle(NSLocalizedString("Last Mongth", comment: ""), forSegmentAt: 3)
        setTitle(NSLocalizedString("All", comment: ""), forSegmentAt: 4)
        addTarget(self, action: #selector(self.periodControlChange(control:)), for: .valueChanged)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.changePeriodNotify(_:)),
                                               name: changePeriodNotification, object: nil)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        selectedSegmentIndex = period().rawValue
    }
    
    func changePeriodNotify(_ notify:Notification) {
        if (notify.object as! PeriodControl) == self {
            return
        }
        selectedSegmentIndex = notify.userInfo!["value"] as! Int
    }
    
    func periodControlChange(control:UISegmentedControl) {
        switch control.selectedSegmentIndex {
        case 0:
            changePeriod(.day)
            NotificationCenter.default.post(name: changePeriodNotification, object: self, userInfo: ["value" : Period.day.rawValue])
        case 1:
            changePeriod(.week)
            NotificationCenter.default.post(name: changePeriodNotification, object: self, userInfo: ["value" : Period.week.rawValue])
        case 2:
            changePeriod(.mongth)
            NotificationCenter.default.post(name: changePeriodNotification, object: self, userInfo: ["value" : Period.mongth.rawValue])
        case 3:
            changePeriod(.lastMongth)
            NotificationCenter.default.post(name: changePeriodNotification, object: self, userInfo: ["value" : Period.lastMongth.rawValue])
        default:
            changePeriod(.all)
            NotificationCenter.default.post(name: changePeriodNotification, object: self, userInfo: ["value" : Period.all.rawValue])
        }
        NotificationCenter.default.post(name: refreshNotification, object: nil)
    }

}
