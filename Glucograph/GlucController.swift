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
    
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var xAxiz: xAxizView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        setupType(valueType())
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.refresh),
                                               name: refreshNotification,
                                               object: nil)
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
    
    func refresh() {
        graphView.setNeedsDisplay()
        xAxiz.setNeedsDisplay()
        
    }
   
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        refresh()
    }
}
