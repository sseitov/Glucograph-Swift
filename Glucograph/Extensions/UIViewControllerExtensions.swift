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

let refreshNotification = Notification.Name("REFRESH")

extension UIViewController {
    
    func setupTitle(_ text:String) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        label.textAlignment = .center
        label.font = UIFont.condensedFont(15)
        label.text = text
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        navigationItem.titleView = label
    }

    func setupType(_ type:ValueType) {
        let typeControl = UISegmentedControl(items: [NSLocalizedString("Blood", comment: ""),
                                                     NSLocalizedString("Pressure", comment: ""),
                                                     NSLocalizedString("Weight", comment: "")])
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
        case 2:
            changeType(.weight)
        default:
            changeType(.blood)
        }
        NotificationCenter.default.post(name: refreshNotification, object: nil)
    }
    
    func goBack() {
        _ = self.navigationController!.popViewController(animated: true)
    }
    
    // MARK: - alerts
    
    func showMessage(_ message:String, messageType:MessageType, messageHandler: (() -> ())? = nil) {
        
        let alert = LGAlertView.decoratedAlert(
            withTitle: Bundle.main.infoDictionary?["CFBundleName"] as? String,
            message: message,
            cancelButtonTitle: "OK",
            cancelButtonBlock: { alert in
                if messageHandler != nil {
                    messageHandler!()
                }
        })
        if messageType == .error {
            alert!.titleLabel.textColor = UIColor.errorColor()
            alert!.okButton.backgroundColor = UIColor.errorColor()
        } else {
            alert!.titleLabel.textColor = UIColor.mainColor()
            alert!.okButton.backgroundColor = UIColor.mainColor()
        }
        alert?.show()
    }
}
