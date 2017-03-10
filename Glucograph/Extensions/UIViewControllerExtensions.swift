//
//  UIViewControllerExtensions.swift
//  v-Channel
//
//  Created by Сергей Сейтов on 16.02.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

enum MessageType {
    case error, success, information
}

extension UIViewController {
    
    func setupTypeAndPeriod(type:ValueType, period:Period) {
        let periodControl = UISegmentedControl(items: [NSLocalizedString("Today", comment: ""),
                                                 NSLocalizedString("Week", comment: ""),
                                                 NSLocalizedString("Mongth", comment: ""),
                                                 NSLocalizedString("All", comment: "")])
        periodControl.tintColor = UIColor.white
        periodControl.selectedSegmentIndex = period.rawValue
        periodControl.addTarget(self, action: #selector(self.periodControlChange(control:)), for: .valueChanged)
        let stretch = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        self.toolbarItems = [stretch, UIBarButtonItem(customView: periodControl), stretch]
        let typeControl = UISegmentedControl(items: [NSLocalizedString("Blood", comment: ""),
                                                       NSLocalizedString("Pressure", comment: "")])
        typeControl.tintColor = UIColor.white
        typeControl.selectedSegmentIndex = type.rawValue
        typeControl.addTarget(self, action: #selector(self.typeControlChange(control:)), for: .valueChanged)
        navigationItem.titleView = typeControl
    }
    
    func setupBackButton() {
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(UIViewController.goBack)
    }

    func typeControlChange(control:UISegmentedControl) {
        switch control.selectedSegmentIndex {
        case 1:
            changeType(.pressure)
        default:
            changeType(.blood)
        }
    }

    func periodControlChange(control:UISegmentedControl) {
        switch control.selectedSegmentIndex {
        case 0:
            changePeriod(.day)
        case 1:
            changePeriod(.week)
        case 2:
            changePeriod(.mongth)
        default:
            changePeriod(.all)
        }
    }
    
    func goBack() {
        _ = self.navigationController!.popViewController(animated: true)
    }
    
    
    // MARK: - alerts
    
    func showMessage(_ error:String, messageType:MessageType, messageHandler: (() -> ())? = nil) {
        var title:String = ""
        switch messageType {
        case .success:
            title = "Success"
        case .information:
            title = "Information"
        default:
            title = "Error"
        }
        let alert = LGAlertView.decoratedAlert(withTitle:title, message: error, cancelButtonTitle: "OK", cancelButtonBlock: { alert in
            if messageHandler != nil {
                messageHandler!()
            }
        })
        alert!.titleLabel.textColor = messageType == .error ? UIColor.errorColor() : UIColor.mainColor()
        alert?.show()
    }
    
    func createQuestion(_ question:String, acceptTitle:String, cancelTitle:String, acceptHandler:@escaping () -> (), cancelHandler: (() -> ())? = nil) -> LGAlertView? {
        
        let alert = LGAlertView.alert(
            withTitle: "Attention!",
            message: question,
            cancelButtonTitle: cancelTitle,
            otherButtonTitle: acceptTitle,
            cancelButtonBlock: { alert in
                if cancelHandler != nil {
                    cancelHandler!()
                }
        },
            otherButtonBlock: { alert in
                alert?.dismiss()
                acceptHandler()
        })
        return alert
    }

}
