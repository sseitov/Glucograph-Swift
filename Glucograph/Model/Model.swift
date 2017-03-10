//
//  Model.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 10.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

enum ValueType:Int {
    case blood = 1
    case pressure = 2
}

@objc class Model: NSObject {
    
    static let shared = Model()

    private var cloudDB: CKDatabase?

    private override init() {
        super.init()

        let container = CKContainer.default()
        cloudDB = container.privateCloudDatabase
    }
    
    // MARK: - CoreData stack

    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "LocalCache", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("LocalCache.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            print("CoreData data error: \(error)")
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print("Saved data error: \(error)")
            }
        }
    }
    
    // MARK: - Gluc stack

    func glucCount() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Gluc")
        if let count = try? managedObjectContext.count(for: fetchRequest) {
            return count
        } else {
            return 0
        }
    }
    
    func myLastGlucDate() -> Date? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Gluc")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1
        if let all = try? managedObjectContext.fetch(fetchRequest) as! [Gluc], let gluc = all.first {
            return gluc.date! as Date
        } else {
            return nil
        }
    }

    func addGlucWith(_ type:Int, date:Date, value:Double, comments:String = "", complete: @escaping() -> ()) {
        let record = CKRecord(recordType: "Gluc")
        record.setValue(type , forKey: "type")
        record.setValue(date, forKey: "date")
        record.setValue(value, forKey: "value")
        record.setValue(comments, forKey: "comments")
        
        cloudDB!.save(record, completionHandler: { cloudRecord, error in
            DispatchQueue.main.async {
                if error != nil {
                    print(error!)
                    complete()
                } else {
                    let gluc = NSEntityDescription.insertNewObject(forEntityName: "Gluc", into: self.managedObjectContext) as! Gluc
                    gluc.recordName = cloudRecord!.recordID.recordName
                    gluc.zoneName = cloudRecord!.recordID.zoneID.zoneName
                    gluc.ownerName = cloudRecord!.recordID.zoneID.ownerName
                    gluc.date = date as NSDate?
                    gluc.type = Int16(type)
                    gluc.value = value
                    gluc.comments = comments
                    self.saveContext()
                    complete()
                }
            }
        })

    }
}
