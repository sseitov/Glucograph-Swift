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
    @IBOutlet weak var yAxiz: yAxizView!
    @IBOutlet weak var periodControl: PeriodControl!
    
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
            self.periodControl.selectedSegmentIndex = Period.day.rawValue
            changePeriod(.day)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    func refresh() {
        if valueType() == .blood {
            graphView.objects = Model.shared.allBloodForPeriod(period())
            Model.shared.refreshBlood()
        } else {
            graphView.objects = Model.shared.allPressureForPeriod(period())
            Model.shared.refreshPressure()
        }
        let range = Model.shared.minMaxRange()
        graphView.range = range
        yAxiz.range = range
        
        xAxiz.setNeedsDisplay()
        yAxiz.setNeedsDisplay()
        graphView.setNeedsDisplay()
    }
   
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        refresh()
    }
}
