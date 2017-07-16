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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        setupType(valueType())
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.refresh),
                                               name: refreshNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    func refresh() {
        if valueType() == .blood {
            graphView.objects = Model.shared.allBloodForPeriod(period())
        } else {
            graphView.objects = Model.shared.allPressureForPeriod(period())
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
