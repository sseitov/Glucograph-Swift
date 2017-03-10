//
//  BloodController.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 10.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class BloodController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        setupPeriod(.all)
    }

    override func goBack() {
        let alert = Picker.createFor(type: .blood, acceptHandler: { val1, val2 in
            print("\(val1).\(val2)")
        })
        alert?.show()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "notes" {
            let next = segue.destination as! NotesController
            next.type = .blood
        }
    }

}
