//
//  CommentsController.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 11.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD

class CommentsController: UIViewController, UITextViewDelegate {

    var object:NSManagedObject?
    @IBOutlet weak var commentsView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        setupTitle(NSLocalizedString("Comments", comment: ""))
        commentsView.text = Model.shared.objectComments(object)
    }
    
    override func goBack() {
        commentsView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        commentsView.becomeFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            saveComments()
            return false
        } else {
            return true
        }
    }
    
    @IBAction func saveComments() {
        let text = commentsView.text != nil ? commentsView.text! : ""
        Model.shared.saveComments(text, forObject: object)
        NotificationCenter.default.post(name: refreshNotification, object: nil)
        SyncManager.shared.upload()
        self.goBack()
    }

}
