//
//  NotesController.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 10.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import SVProgressHUD

class NotesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var bloods:[Blood] = []
    var pressures:[Pressure] = []

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
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
            bloods = Model.shared.allBloodForPeriod(period())
        } else {
            pressures = Model.shared.allPressureForPeriod(period())
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return valueType() == .blood ? bloods.count : pressures.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var text:String?
        if (valueType() == .blood) {
            text = bloods[indexPath.row].comments
        } else {
            text = pressures[indexPath.row].comments
        }
        if (text != nil && !text!.isEmpty) {
            return 80 + text!.heightWithConstrainedWidth(width: tableView.frame.size.width-40, font: UIFont.commentsFont())
        } else {
            return 60
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notes", for: indexPath) as! NotesCell
        if valueType() == .blood {
            cell.object = bloods[indexPath.row]
        } else {
            cell.object = pressures[indexPath.row]
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "comments" {
            let nav = segue.destination as! UINavigationController
            let next = nav.topViewController as! CommentsController
            next.object = (sender as! NotesCell).object
        }
    }

}
