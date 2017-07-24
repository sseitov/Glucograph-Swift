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
    var weights:[Weight] = []

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        setupType(glucType())
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
        switch glucType() {
        case .pressure:
            pressures = Model.shared.allPressureForPeriod(period())
        case .weight:
            weights = Model.shared.allWeightForPeriod(period())
        default:
            bloods = Model.shared.allBloodForPeriod(period())
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch glucType() {
        case .pressure:
            return pressures.count
        case .weight:
            return weights.count
        default:
            return bloods.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var text:String?
        switch glucType() {
        case .pressure:
            text = pressures[indexPath.row].comments
        case .weight:
            text = weights[indexPath.row].comments
        default:
            text = bloods[indexPath.row].comments
        }
        if (text != nil && !text!.isEmpty) {
            return 80 + text!.heightWithConstrainedWidth(width: tableView.frame.size.width-40, font: UIFont.commentsFont())
        } else {
            return 60
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notes", for: indexPath) as! NotesCell
        switch glucType() {
        case .pressure:
            cell.object = pressures[indexPath.row]
        case .weight:
            cell.object = weights[indexPath.row]
        default:
            cell.object = bloods[indexPath.row]
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
