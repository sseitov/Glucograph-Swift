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

// MARK: - Current settings

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
    case week = 0
    case monthDate = 1
    case all = 2
}

func Mongth(_ m:Int) -> String {
    switch m {
    case 1:
        return LOCALIZE("January")
    case 2:
        return LOCALIZE("February")
    case 3:
        return LOCALIZE("March")
    case 4:
        return LOCALIZE("April")
    case 5:
        return LOCALIZE("May")
    case 6:
        return LOCALIZE("June")
    case 7:
        return LOCALIZE("July")
    case 8:
        return LOCALIZE("August")
    case 9:
        return LOCALIZE("September")
    case 10:
        return LOCALIZE("October")
    case 11:
        return LOCALIZE("November")
    case 12:
        return LOCALIZE("December")
    default:
        return ""
    }
}

func changePeriod(_ period:Period, date:Date? = nil) {
    UserDefaults.standard.set(period.rawValue, forKey: "Period")
    if period == .monthDate && date != nil {
        UserDefaults.standard.set(date, forKey: "PeriodDate")
    }
    UserDefaults.standard.synchronize()
}

func period() -> Period {
    return Period(rawValue: UserDefaults.standard.integer(forKey: "Period"))!
}

func periodDate() -> Date? {
    return UserDefaults.standard.object(forKey: "PeriodDate") as? Date
}

// MARK: - Date manipulations

func startOfDay(_ date: Date) -> Date? {
    return Calendar.current.startOfDay(for: date)
}

func endOfMonth(_ date: Date) -> Date? {
    if let next = Calendar.current.date(byAdding: .month, value: 1, to: date) {
        return startOfDay(next)
    } else {
        return date
    }
}

func lastWeek() -> Date? {
    
    if let date = startOfDay(Date()), let monday = Calendar.current.date(bySetting: .weekday, value: Calendar.current.firstWeekday, of: date) {
        return Calendar.current.date(byAdding: .day, value: -7, to: monday)
    } else {
        return nil
    }
}

func dayOfDate(_ date:Date?) -> String? {
    if date != nil {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date!)
    } else {
        return nil
    }
}

func timeOfDate(_ date:Date?) -> String? {
    if date != nil {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date!)
    } else {
        return nil
    }
}

func dayTimeOfDate(_ date:Date?) -> String? {
    if date != nil {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy H:mm"
        return formatter.string(from: date!)
    } else {
        return nil
    }
}

func dateString(_ date:Date?) -> String {
    if date != nil {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date!)
    } else {
        return ""
    }
}

// MARK: - Data model

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
    
    // MARK: - Common methods
    
    func objectDate(_ obj:NSManagedObject?) -> NSDate? {
        if (valueType() == .blood) {
            return (obj as! Blood).date
        } else {
            return (obj as! Pressure).date
        }
    }
    
    func objectComments(_ obj:NSManagedObject?) -> String? {
        if (valueType() == .blood) {
            return (obj as! Blood).comments
        } else {
            return (obj as! Pressure).comments
        }
    }
   
    func saveComments(_ comments:String, forObject:NSManagedObject?, complete: @escaping() -> ()) {
        var recordID:CKRecordID?
        if valueType() == .blood {
            let blood = forObject as! Blood
            let recordZoneID = CKRecordZoneID(zoneName: blood.zoneName!, ownerName: blood.ownerName!)
            recordID = CKRecordID(recordName: blood.recordName!, zoneID: recordZoneID)
            blood.comments = comments
            saveContext()
        } else {
            let pressure = forObject as! Pressure
            let recordZoneID = CKRecordZoneID(zoneName: pressure.zoneName!, ownerName: pressure.ownerName!)
            recordID = CKRecordID(recordName: pressure.recordName!, zoneID: recordZoneID)
            pressure.comments = comments
            saveContext()
        }
        
        cloudDB?.fetch(withRecordID: recordID!, completionHandler: { record, error in
            if error == nil && record != nil {
                record!.setValue(comments, forKey: "comments")
                self.cloudDB!.save(record!, completionHandler: { _, error in
                    DispatchQueue.main.async {
                        complete()
                    }
                })
            } else {
                DispatchQueue.main.async {
                    complete()
                }
            }
        })

    }
    
    func deleteObject(_ object:NSManagedObject?, complete: @escaping() -> ()) {
        var recordID:CKRecordID?
        if valueType() == .blood {
            let blood = object as! Blood
            let recordZoneID = CKRecordZoneID(zoneName: blood.zoneName!, ownerName: blood.ownerName!)
            recordID = CKRecordID(recordName: blood.recordName!, zoneID: recordZoneID)
        } else {
            let pressure = object as! Pressure
            let recordZoneID = CKRecordZoneID(zoneName: pressure.zoneName!, ownerName: pressure.ownerName!)
            recordID = CKRecordID(recordName: pressure.recordName!, zoneID: recordZoneID)
        }
        managedObjectContext.delete(object!)
        saveContext()
        cloudDB!.delete(withRecordID: recordID!, completionHandler: { record, error in
            DispatchQueue.main.async {
                complete()
            }
        })
    }
    
    private func minValue(values:[Double]) -> Double {
        var minV = Double.greatestFiniteMagnitude
        for value in values {
            minV = min(minV, value)
        }
        return minV
    }
    
    private func maxValue(values:[Double]) -> Double {
        var maxV = Double()
        for value in values {
            maxV = max(maxV, value)
        }
        return maxV
    }
    
    func minMaxRange() -> (min:Double, max:Double)? {
        var values:[Double] = []
        if valueType() == .blood {
            let bloods = allBloodForPeriod(period())
            if bloods.count < 2 {
                return nil
            }
            for b in bloods {
                if b.value > 0 {
                    values.append(b.value)
                }
            }
        } else {
            let pressures = allPressureForPeriod(period())
            if pressures.count < 2 {
                return nil
            }
            for p in pressures {
                if p.lowValue > 0 {
                    values.append(p.lowValue)
                }
                if p.highValue > 0 {
                    values.append(p.highValue)
                }
            }
        }
        return (minValue(values: values), maxValue(values: values))
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
    
    func myLastBlood(_ first:Bool = false) -> Blood? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Blood")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: first)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1
        if let all = try? managedObjectContext.fetch(fetchRequest) as! [Blood], let blood = all.first {
            return blood
        } else {
            return nil
        }
    }

    func addBloodAt(_ date:Date, value:Double, comments:String = "", error: @escaping(NSError?) -> ()) {
        let record = CKRecord(recordType: "Blood")
        record.setValue(date, forKey: "date")
        record.setValue(value, forKey: "value")
        record.setValue(comments, forKey: "comments")
        
        cloudDB!.save(record, completionHandler: { cloudRecord, err in
            DispatchQueue.main.async {
                if err != nil {
                    error(err as NSError?)
                } else {
                    let blood = NSEntityDescription.insertNewObject(forEntityName: "Blood", into: self.managedObjectContext) as! Blood
                    blood.recordName = cloudRecord!.recordID.recordName
                    blood.zoneName = cloudRecord!.recordID.zoneID.zoneName
                    blood.ownerName = cloudRecord!.recordID.zoneID.ownerName
                    blood.date = date as NSDate?
                    blood.value = value
                    blood.comments = comments
                    self.saveContext()
                    error(nil)
                }
            }
        })

    }
    
    func migrateBlood(_ complete: @escaping() -> ()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Blood", predicate: predicate)

        cloudDB!.perform(query, inZoneWith: nil) { results, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Refresh: \(error!.localizedDescription)")
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
    
    func refreshBlood() {
        let date = myLastBlood()?.date
        let predicate = date == nil ? NSPredicate(value: true) : NSPredicate(format: "date > %@", date! as CVarArg)
        let query = CKQuery(recordType: "Blood", predicate: predicate)

        cloudDB!.perform(query, inZoneWith: nil) { results, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Refresh: \(error!.localizedDescription)")
                }
                return
            }
            if results != nil && results!.count > 0 {
                DispatchQueue.main.async {
                    for record in results! {
                        self.addBlood(record)
                    }
                    NotificationCenter.default.post(name: refreshNotification, object: nil)
                }
            }
        }
    }
    
    func getBlood(_ record:CKRecord) -> Blood? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Blood")
        fetchRequest.predicate = NSPredicate(format: "recordName == %@", record.recordID.recordName)
        if let all = try? managedObjectContext.fetch(fetchRequest) as! [Blood], let blood = all.first {
            return blood
        } else {
            return nil
        }
    }

    func addBlood(_ record:CKRecord) {
        if getBlood(record) != nil {
            return
        }
        let blood = NSEntityDescription.insertNewObject(forEntityName: "Blood", into: managedObjectContext) as! Blood
        blood.recordName = record.recordID.recordName
        blood.zoneName = record.recordID.zoneID.zoneName
        blood.ownerName = record.recordID.zoneID.ownerName
        blood.date = record.value(forKey: "date") as? NSDate
        blood.value = record.value(forKey: "value") as! Double
        blood.comments = record.value(forKey: "comments") as? String
        saveContext()
    }

    func allBloodForPeriod(_ period:Period) -> [Blood] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Blood")
        switch period {
        case .week:
            fetchRequest.predicate = NSPredicate(format: "date > %@", lastWeek()! as CVarArg)
        case .monthDate:
            if let date = UserDefaults.standard.object(forKey: "PeriodDate") as? Date {
                let pred1 = NSPredicate(format: "date > %@", startOfDay(date)! as CVarArg)
                let pred2 = NSPredicate(format: "date < %@", endOfMonth(date)! as CVarArg)
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pred1, pred2])
            } else {
                return []
            }
        default:
            break
        }
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let all = try? managedObjectContext.fetch(fetchRequest) as! [Blood] {
            return all
        } else {
            return []
        }
    }
    
    // MARK: - Pressure table
    
    func myLastPressure(_ first:Bool = false) -> Pressure? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pressure")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: first)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1
        if let all = try? managedObjectContext.fetch(fetchRequest) as! [Pressure], let pressure = all.first {
            return pressure
        } else {
            return nil
        }
    }

    func allPressureForPeriod(_ period:Period) -> [Pressure] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pressure")
        switch period {
        case .week:
            fetchRequest.predicate = NSPredicate(format: "date > %@", lastWeek()! as CVarArg)
        case .monthDate:
            if let date = UserDefaults.standard.object(forKey: "PeriodDate") as? Date {
                let pred1 = NSPredicate(format: "date > %@", startOfDay(date)! as CVarArg)
                let pred2 = NSPredicate(format: "date < %@", endOfMonth(date)! as CVarArg)
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pred1, pred2])
            } else {
                return []
            }
        default:
            break
        }
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        if let all = try? managedObjectContext.fetch(fetchRequest) as! [Pressure] {
            return all
        } else {
            return []
        }
    }
    
    func addPressureAt(_ date:Date, high:Int, low:Int, error: @escaping(NSError?) -> ()) {
        let record = CKRecord(recordType: "Pressure")
        record.setValue(date, forKey: "date")
        record.setValue(Double(high), forKey: "highValue")
        record.setValue(Double(low), forKey: "lowValue")
        
        cloudDB!.save(record, completionHandler: { cloudRecord, err in
            DispatchQueue.main.async {
                if err != nil {
                    error(err as NSError?)
                } else {
                    let pressure = NSEntityDescription.insertNewObject(forEntityName: "Pressure", into: self.managedObjectContext) as! Pressure
                    pressure.recordName = cloudRecord!.recordID.recordName
                    pressure.zoneName = cloudRecord!.recordID.zoneID.zoneName
                    pressure.ownerName = cloudRecord!.recordID.zoneID.ownerName
                    pressure.date = date as NSDate?
                    pressure.highValue = Double(high)
                    pressure.lowValue = Double(low)
                    self.saveContext()
                    error(nil)
                }
            }
        })
        
    }
    
    func getPressure(_ record:CKRecord) -> Pressure? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pressure")
        fetchRequest.predicate = NSPredicate(format: "recordName == %@", record.recordID.recordName)
        if let all = try? managedObjectContext.fetch(fetchRequest) as! [Pressure], let pressure = all.first {
            return pressure
        } else {
            return nil
        }
    }
    
    func addPressure(_ record:CKRecord) {
        if getPressure(record) != nil {
            return
        }
        let pressure = NSEntityDescription.insertNewObject(forEntityName: "Pressure", into: managedObjectContext) as! Pressure
        pressure.recordName = record.recordID.recordName
        pressure.zoneName = record.recordID.zoneID.zoneName
        pressure.ownerName = record.recordID.zoneID.ownerName
        pressure.date = record.value(forKey: "date") as? NSDate
        pressure.highValue = record.value(forKey: "highValue") as! Double
        pressure.lowValue = record.value(forKey: "lowValue") as! Double
        pressure.comments = record.value(forKey: "comments") as? String
        saveContext()
    }

    func refreshPressure() {
        let date = myLastPressure()?.date
        let predicate = date == nil ? NSPredicate(value: true) : NSPredicate(format: "date > %@", date! as CVarArg)
        let query = CKQuery(recordType: "Pressure", predicate: predicate)
        
        cloudDB!.perform(query, inZoneWith: nil) { results, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Refresh: \(error!.localizedDescription)")
                }
                return
            }
            if results != nil && results!.count > 0 {
                DispatchQueue.main.async {
                    for record in results! {
                        self.addPressure(record)
                    }
                    NotificationCenter.default.post(name: refreshNotification, object: nil)
                }
            }
        }
    }

}
