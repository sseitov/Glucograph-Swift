//
//  NotesCell.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 11.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class NotesCell: UITableViewCell {

    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var timeView: UILabel!
    @IBOutlet weak var highValue: UILabel!
    @IBOutlet weak var lowValue: UILabel!
    @IBOutlet weak var commentsView: UITextView!
    @IBOutlet weak var commentsHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var showComments: UIButton!
}
