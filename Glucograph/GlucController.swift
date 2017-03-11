//
//  GlucController.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 10.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import SVProgressHUD

class GlucController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        setupType(valueType())
    }
    
    override func goBack() {
        let alert = Picker.createFor(type: valueType(), acceptHandler: { val1, val2 in
            SVProgressHUD.show(withStatus: NSLocalizedString("Add...", comment: ""))
            if valueType() == .pressure {
                Model.shared.addPressureAt(Date(), high: val1, low: val2, complete: {
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "notes", sender: nil)
                })
            } else {
                let value = Double(val1) + Double(val2)/10.0
                Model.shared.addBloodAt(Date(), value: value, complete: {
                    SVProgressHUD.dismiss()
                })
            }
        })
        alert?.show()
    }
/*
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if toolbarItems != nil, toolbarItems!.count > 0, let periodControl = toolbarItems![1].customView as? UISegmentedControl {
            let width = (self.view.frame.width - 20) / 5.0
            for i in 0..<5 {
                periodControl.setWidth(width, forSegmentAt: i)
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print(navigationController?.toolbar.subviews.count)

        if toolbarItems != nil, toolbarItems!.count > 0, let periodControl = toolbarItems![1].customView as? UISegmentedControl {
            let width = (size.width - 20) / 5.0
            print("change width to \(size.width)")
            for i in 0..<5 {
                periodControl.setWidth(width, forSegmentAt: i)
            }
            navigationController?.toolbar.layoutSubviews()
        }

    }
*/
}
