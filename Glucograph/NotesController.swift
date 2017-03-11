//
//  NotesController.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 10.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class NotesController: UITableViewController {
    
    var bloods:[Blood] = []
    var pressures:[Pressure] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        setupTypeAndPeriod(type: valueType(), period: period())
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return valueType() == .blood ? bloods.count : pressures.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notes", for: indexPath) as! NotesCell
        if valueType() == .blood {
            cell.object = bloods[indexPath.row]
        } else {
            cell.object = pressures[indexPath.row]
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .top)
        }
    }

}
