//
//  NotesCell.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 11.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import CoreData

class NotesCell: UITableViewCell {

    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var highValue: UILabel!
    @IBOutlet weak var lowValue: UILabel!
    @IBOutlet weak var commentsView: UILabel!
    @IBOutlet weak var lowWidth: NSLayoutConstraint!

    var object:NSManagedObject? {
        didSet {
            dateView.text = dayTimeOfDate(Model.shared.objectDate(object) as Date?)?.uppercased()
            commentsView.text = Model.shared.objectComments(object)
            switch glucType() {
            case .pressure:
                let pressure = object as! Pressure
                highValue.text = String(format: "%d", Int(pressure.highValue))
                lowValue.text = String(format: "/ %d", Int(pressure.lowValue))
                lowWidth.constant = 40
            case .weight:
                let weight = object as! Weight
                highValue.text = String(format: "%d", weight.value)
                lowValue.text = ""
                lowWidth.constant = 0
            default:
                let blood = object as! Blood
                highValue.text = String(format: "%.1f", blood.value)
                lowValue.text = ""
                lowWidth.constant = 0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
