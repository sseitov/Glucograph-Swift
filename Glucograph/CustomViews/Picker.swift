//
//  Picker.swift
//  v-Channel
//
//  Created by Сергей Сейтов on 16.02.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

typealias CompletionBlock = (Int, Int) -> Void

class Picker: LGAlertView {

    @IBOutlet weak var pickerView: UIPickerView!

    var pickerType:ValueType?
    
    class func createFor(type:ValueType, acceptHandler: @escaping CompletionBlock) -> Picker? {
        if let pickerAlert = Bundle.main.loadNibNamed("Picker", owner: nil, options: nil)?.first as? Picker {
            pickerAlert.pickerType = type
            if type == .blood {
                pickerAlert.titleLabel.text = NSLocalizedString("Blood sugar level", comment: "")
            } else {
                pickerAlert.titleLabel.text = NSLocalizedString("Pressure", comment: "")
            }
            pickerAlert.otherButtonBlock = { alert in
                pickerAlert.dismiss()
                if type == .blood {
                    acceptHandler(33 - pickerAlert.pickerView.selectedRow(inComponent: 0),
                                  9 - pickerAlert.pickerView.selectedRow(inComponent: 1))
                } else {
                    acceptHandler(240 - pickerAlert.pickerView.selectedRow(inComponent: 0),
                                  140 - pickerAlert.pickerView.selectedRow(inComponent: 1))
                }
            }
            pickerAlert.pickerView.dataSource = pickerAlert
            pickerAlert.pickerView.delegate = pickerAlert
            return pickerAlert
        } else {
            return nil
        }
    }
    
    override func show() {
        super.show()
        if pickerType == .blood {
            pickerView.selectRow(26, inComponent: 0, animated: false)
            pickerView.selectRow(7, inComponent: 1, animated: false)
        } else {
            pickerView.selectRow(120, inComponent: 0, animated: false)
            pickerView.selectRow(60, inComponent: 1, animated: false)
        }
    }
    
    func showInView(_ view:UIView) {
        superView = view
        show()
    }
}

extension Picker : UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1 {
            return pickerType! == .blood ? 10 : 121
        } else {
            return pickerType! == .blood ? 32 : 141
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 100))
        label.font = UIFont.condensedFont(27)
        if pickerType! == .blood {
            label.textColor = UIColor.black
        } else {
            label.textColor = component == 1 ? UIColor.mainColor() : UIColor.errorColor()
        }
        if component == 1 {
            label.text = pickerType! == .blood ? "\(9-row)" :  "\(140 - row)"
        } else {
            label.text = pickerType! == .blood ? "\(33 - row)." : "\(240 - row)"
        }
        return label
    }
/*
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1 {
            return pickerType! == .blood ? "\(9-row)" :  "\(140 - row)"
        } else {
            return pickerType! == .blood ? "\(33 - row)." : "\(240 - row)"
        }
    }
 */
}
