//
//  GlucController.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 10.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class GlucController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackButton()
        setupTypeAndPeriod(type: valueType(), period: period())
    }
    
    override func goBack() {
        let alert = Picker.createFor(type: valueType(), acceptHandler: { val1, val2 in
            print("\(val1).\(val2)")
        })
        alert?.show()
    }

}
