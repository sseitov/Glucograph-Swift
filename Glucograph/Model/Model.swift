//
//  Model.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 10.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Current settings

enum ValueType:Int {
    case blood = 0
    case pressure = 1
    case weight = 2
}

func changeType(_ type:ValueType) {
    UserDefaults.standard.set(type.rawValue, forKey: "ValueType")
    UserDefaults.standard.synchronize()
}

func glucType() -> ValueType {
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
        switch glucType() {
        case .pressure:
            return (obj as! Pressure).date
        case .weight:
            return (obj as! Weight).date
        default:
            return (obj as! Blood).date
        }
    }
    
    func objectComments(_ obj:NSManagedObject?) -> String? {
        switch glucType() {
        case .pressure:
            return (obj as! Pressure).comments
        case .weight:
            return (obj as! Weight).comments
        default:
            return (obj as! Blood).comments
        }
    }
   
    func saveComments(_ comments:String, forObject:NSManagedObject?) {
        switch glucType() {
        case .pressure:
            let pressure = forObject as! Pressure
            pressure.comments = comments
            pressure.synced = false
        case .weight:
            let weight = forObject as! Weight
            weight.comments = comments
            weight.synced = false
        default:
            let blood = forObject as! Blood
            blood.comments = comments
            blood.synced = false
        }
        saveContext()
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
        if glucType() == .weight {
            let weights = allWeightForPeriod(period())
            if weights.count < 2 {
                return nil
            }
            for w in weights {
                if w.value > 0 {
                    values.append(Double(w.value))
                }
            }
        } else {
            if glucType() == .blood {
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
        fetchRequest.predicate = NSPredicate(format: "synced == %@", NSNumber(booleanLiteral: true))
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: first)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1
        if let all = try? managedObjectContext.fetch(fetchRequest) as! [Blood], let blood = all.first {
            return blood
        } else {
            return nil
        }
    }

    func addBloodAt(_ date:Date, value:Double, comments:String = "") {
        let blood = NSEntityDescription.insertNewObject(forEntityName: "Blood", into: self.managedObjectContext) as! Blood
        blood.date = date as NSDate?
        blood.value = value
        blood.comments = comments
        blood.synced = false
        self.saveContext()
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
    
    func bloodForDate(_ date:NSDate) -> Blood? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Blood")
        fetchRequest.predicate = NSPredicate(format: "date == %@", date)
        if let all = try? managedObjectContext.fetch(fetchRequest) {
            return all.first as? Blood
        } else {
            return nil
        }
    }
    
    func nonSyncedBloods() -> [Blood] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Blood")
        fetchRequest.predicate = NSPredicate(format: "synced == %@", NSNumber(booleanLiteral: false))
        if let all = try? managedObjectContext.fetch(fetchRequest) as! [Blood] {
            return all
        } else {
            return []
        }
    }
    
    // MARK: - Pressure table
    
    func myLastPressure(_ first:Bool = false) -> Pressure? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pressure")
        fetchRequest.predicate = NSPredicate(format: "synced == %@", NSNumber(booleanLiteral: true))
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
    
    func addPressureAt(_ date:Date, high:Int, low:Int) {
        let pressure = NSEntityDescription.insertNewObject(forEntityName: "Pressure", into: self.managedObjectContext) as! Pressure
        pressure.date = date as NSDate?
        pressure.highValue = Double(high)
        pressure.lowValue = Double(low)
        pressure.synced = false
        self.saveContext()
    }
    
    func pressureForDate(_ date:NSDate) -> Pressure? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pressure")
        fetchRequest.predicate = NSPredicate(format: "date == %@", date)
        if let all = try? managedObjectContext.fetch(fetchRequest) {
            return all.first as? Pressure
        } else {
            return nil
        }
    }

    func nonSyncedPressures() -> [Pressure] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pressure")
        fetchRequest.predicate = NSPredicate(format: "synced == %@", NSNumber(booleanLiteral: false))
        if let all = try? managedObjectContext.fetch(fetchRequest) as! [Pressure] {
            return all
        } else {
            return []
        }
    }
    
    // MARK: - Weight table
    
    func weightCount() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Weight")
        if let count = try? managedObjectContext.count(for: fetchRequest) {
            return count
        } else {
            return 0
        }
    }
    
    func myLastWeight(_ first:Bool = false) -> Weight? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Weight")
        fetchRequest.predicate = NSPredicate(format: "synced == %@", NSNumber(booleanLiteral: true))
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: first)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1
        if let all = try? managedObjectContext.fetch(fetchRequest) as! [Weight], let weight = all.first {
            return weight
        } else {
            return nil
        }
    }
    
    func addWeightAt(_ date:Date, value:Double, comments:String = "") {
        let weight = NSEntityDescription.insertNewObject(forEntityName: "Weight", into: self.managedObjectContext) as! Weight
        weight.date = date as NSDate?
        weight.value = value
        weight.comments = comments
        weight.synced = false
        self.saveContext()
    }
    
    func allWeightForPeriod(_ period:Period) -> [Weight] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Weight")
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
        
        if let all = try? managedObjectContext.fetch(fetchRequest) as! [Weight] {
            return all
        } else {
            return []
        }
    }
    
    func weightForDate(_ date:NSDate) -> Weight? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Weight")
        fetchRequest.predicate = NSPredicate(format: "date == %@", date)
        if let all = try? managedObjectContext.fetch(fetchRequest) {
            return all.first as? Weight
        } else {
            return nil
        }
    }
    
    func nonSyncedWeights() -> [Weight] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Weight")
        fetchRequest.predicate = NSPredicate(format: "synced == %@", NSNumber(booleanLiteral: false))
        if let all = try? managedObjectContext.fetch(fetchRequest) as! [Weight] {
            return all
        } else {
            return []
        }
    }

}
