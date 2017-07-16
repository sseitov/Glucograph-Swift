//
//  Picker.swift
//  v-Channel
//
//  Created by Сергей Сейтов on 16.02.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

typealias CompletionBlock = (Int, Int) -> Void
typealias MongthCompletionBlock = (Date?) -> Void

class Picker: LGAlertView {

    @IBOutlet weak var pickerView: UIPickerView!

    var pickerType:ValueType?
    
    class func mongthChooser(_ completion: @escaping MongthCompletionBlock) -> Picker? {
        if let pickerAlert = Bundle.main.loadNibNamed("Picker", owner: nil, options: nil)?.first as? Picker {
            pickerAlert.pickerType = nil
            pickerAlert.titleLabel.text = NSLocalizedString("MongthChooser", comment: "")
            pickerAlert.cancelButton.isHidden = true
            pickerAlert.otherButton.isHidden = true
            
            pickerAlert.otherButtonBlock = { alert in
                pickerAlert.dismiss()
                var comps = DateComponents()
                comps.year = 2000 + pickerAlert.pickerView.selectedRow(inComponent: 1)
                comps.month = pickerAlert.pickerView.selectedRow(inComponent: 0) + 1
                completion(Calendar.current.date(from: comps))
            }
            pickerAlert.okButton.addTarget(pickerAlert, action: #selector(LGAlertView.didClickOther(_:)), for: .touchUpInside)
            pickerAlert.pickerView.dataSource = pickerAlert
            pickerAlert.pickerView.delegate = pickerAlert
            return pickerAlert
        } else {
            return nil
        }
    }
    
    class func createFor(type:ValueType, acceptHandler: @escaping CompletionBlock) -> Picker? {
        if let pickerAlert = Bundle.main.loadNibNamed("Picker", owner: nil, options: nil)?.first as? Picker {
            pickerAlert.pickerType = type
            pickerAlert.okButton.isHidden = true
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
        if pickerType != nil {
            if pickerType == .blood {
                let blood = Model.shared.myLastBlood()
                if blood != nil {
                    let intVal = Int(blood!.value)
                    let decVal = Int((blood!.value - Double(intVal))*10)
                    pickerView.selectRow(33 - intVal, inComponent: 0, animated: false)
                    pickerView.selectRow(9 - decVal , inComponent: 1, animated: false)
                } else {
                    pickerView.selectRow(26, inComponent: 0, animated: false)
                    pickerView.selectRow(7, inComponent: 1, animated: false)
                }
            } else {
                let pressure = Model.shared.myLastPressure()
                if pressure != nil {
                    pickerView.selectRow(240 - Int(pressure!.highValue), inComponent: 0, animated: false)
                    pickerView.selectRow(140 - Int(pressure!.lowValue), inComponent: 1, animated: false)
                } else {
                    pickerView.selectRow(120, inComponent: 0, animated: false)
                    pickerView.selectRow(60, inComponent: 1, animated: false)
                }
            }
        } else {
            var date = UserDefaults.standard.object(forKey: "PeriodDate") as? Date
            if date == nil {
                date = Date()
            }
            let comps = Calendar.current.dateComponents([.month, .year], from: date!)
            if let m = comps.month {
                pickerView.selectRow(m-1, inComponent: 0, animated: false)
            }
            if let y = comps.year {
                pickerView.selectRow(y - 2000 , inComponent: 1, animated: false)
            }
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
            if pickerType != nil {
                return pickerType! == .blood ? 10 : 121
            } else {
                return 100
            }
        } else {
            if pickerType != nil {
                return pickerType! == .blood ? 32 : 141
            } else {
                return 12
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 100))
        label.textAlignment = .center
        if pickerType != nil {
            label.font = UIFont.condensedFont(27)
            if pickerType! == .blood {
                label.textColor = UIColor.bloodColor()
            } else {
                label.textColor = component == 1 ? UIColor.mainColor() : UIColor.bloodColor()
            }
            if component == 1 {
                label.text = pickerType! == .blood ? "\(9-row)" :  "\(140 - row)"
            } else {
                label.text = pickerType! == .blood ? "\(33 - row)." : "\(240 - row)"
            }
        } else {
            label.font = UIFont.condensedFont(21)
            if component == 1 {
                label.textColor = UIColor.black
                label.text = "\(2000 + row)"
            } else {
                label.textColor = UIColor.mainColor()
                label.text = Mongth(row+1).uppercased()
            }
        }
        return label
    }
    
}
