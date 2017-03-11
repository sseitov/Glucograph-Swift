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
    case blood = 0
    case pressure = 1
}

func changeType(_ type:ValueType) {
    UserDefaults.standard.set(type.rawValue, forKey: "ValueType")
    UserDefaults.standard.synchronize()
}

func valueType() -> ValueType {
    return ValueType(rawValue: UserDefaults.standard.integer(forKey: "ValueType"))!
}

enum Period:Int {
    case day = 0
    case week = 1
    case mongth = 2
    case all = 3
}

func changePeriod(_ period:Period) {
    UserDefaults.standard.set(period.rawValue, forKey: "Period")
    UserDefaults.standard.synchronize()
}

func period() -> Period {
    return Period(rawValue: UserDefaults.standard.integer(forKey: "Period"))!
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
    
    // MARK: - Blood table

    func bloodCount() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Blood")
        if let count = try? managedObjectContext.count(for: fetchRequest) {
            return count
        } else {
            return 0
        }
    }
    
    func myLastBludDate() -> Date? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Blood")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1
        if let all = try? managedObjectContext.fetch(fetchRequest) as! [Blood], let blood = all.first {
            return blood.date! as Date
        } else {
            return nil
        }
    }

    func addBloodAt(_ date:Date, value:Double, comments:String = "", complete: @escaping() -> ()) {
        let record = CKRecord(recordType: "Blood")
        record.setValue(date, forKey: "date")
        record.setValue(value, forKey: "value")
        record.setValue(comments, forKey: "comments")
        
        cloudDB!.save(record, completionHandler: { cloudRecord, error in
            DispatchQueue.main.async {
                if error != nil {
                    print(error!)
                    complete()
                } else {
                    let blood = NSEntityDescription.insertNewObject(forEntityName: "Blood", into: self.managedObjectContext) as! Blood
                    blood.recordName = cloudRecord!.recordID.recordName
                    blood.zoneName = cloudRecord!.recordID.zoneID.zoneName
                    blood.ownerName = cloudRecord!.recordID.zoneID.ownerName
                    blood.date = date as NSDate?
                    blood.value = value
                    blood.comments = comments
                    self.saveContext()
                    complete()
                }
            }
        })

    }
    
    func migrateBlood(_ complete: @escaping() -> ()) {
/*
        let lastDate = myLastBludDate()
        let predicate = (lastDate == nil) ?
            NSPredicate(value: true) :
            NSPredicate(format: "date > %@", lastDate! as CVarArg)
*/
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Blood", predicate: predicate)
        
        cloudDB!.perform(query, inZoneWith: nil) { results, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Refresh: \(error)")
                    complete()
                }
                return
            }
            DispatchQueue.main.async {
                for record in results! {
                    self.addBlood(record)
                }
                complete()
            }
        }
    }
    
    func addBlood(_ record:CKRecord) {
        let blood = NSEntityDescription.insertNewObject(forEntityName: "Blood", into: managedObjectContext) as! Blood
        blood.recordName = record.recordID.recordName
        blood.zoneName = record.recordID.zoneID.zoneName
        blood.ownerName = record.recordID.zoneID.ownerName
        blood.date = record.value(forKey: "date") as? NSDate
        blood.value = record.value(forKey: "value") as! Double
        blood.comments = record.value(forKey: "comments") as? String
        saveContext()
    }

}
