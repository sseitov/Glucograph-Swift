//
//  PeriodControl.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 11.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class PeriodControl: UISegmentedControl {
 
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTitle(NSLocalizedString("Week", comment: ""), forSegmentAt: 0)
        setTitle(selectedMongth(), forSegmentAt: 1)
        setTitle(NSLocalizedString("All", comment: ""), forSegmentAt: 2)
        
        let segmentedTapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGestureSegment(_:)))
        addGestureRecognizer(segmentedTapGesture)
    }
    
    private func selectedMongth() -> String {
        var date = UserDefaults.standard.object(forKey: "PeriodDate") as? Date
        if date == nil {
            date = Date()
        }
        let comps = Calendar.current.dateComponents([.month, .year], from: date!)
        return  "\(Mongth(comps.month!)) \(comps.year!)"
    }

    func onTapGestureSegment(_ tapGesture: UITapGestureRecognizer) {
        let point = tapGesture.location(in: self)
        let segmentSize = bounds.size.width / CGFloat(numberOfSegments)
        let touchedSegment = Int(point.x / segmentSize)
        
        if selectedSegmentIndex != touchedSegment {
            // Normal behaviour the segment changes
            selectedSegmentIndex = touchedSegment
            onSegment()
        } else {
            // Tap on the already selected segment
            selectedSegmentIndex = touchedSegment
            if selectedSegmentIndex == 1 {
                let alert = Picker.mongthChooser({ mongth in
                    changePeriod(.monthDate, date: mongth)
                    self.setTitle(self.selectedMongth(), forSegmentAt: 1)
                    NotificationCenter.default.post(name: refreshNotification, object: nil)
                })
                alert?.show()
            }
        }
    }

    func onSegment() {
        switch selectedSegmentIndex {
        case 0:
            changePeriod(.week)
            NotificationCenter.default.post(name: refreshNotification, object: nil)
        case 1:
            changePeriod(.monthDate)
            NotificationCenter.default.post(name: refreshNotification, object: nil)
        default:
            changePeriod(.all)
            NotificationCenter.default.post(name: refreshNotification, object: nil)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        selectedSegmentIndex = period().rawValue
    }
    
}
