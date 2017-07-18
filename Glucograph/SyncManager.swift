//
//  SyncManager.swift
//  Glucograph
//
//  Created by Sergey Seitov on 18.07.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

class SyncManager: NSObject {
    
    static let shared = SyncManager()
    
    private var cloudDB: CKDatabase?
    private var internetReachability:Reachability?
    private var networkStatus:NetworkStatus = NotReachable
    
    private override init() {
        super.init()
        
        let container = CKContainer.default()
        cloudDB = container.privateCloudDatabase
        
        internetReachability = Reachability.forInternetConnection()
        if internetReachability != nil {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.reachabilityChanged(_:)),
                                                   name: NSNotification.Name.reachabilityChanged,
                                                   object: nil)
            networkStatus = internetReachability!.currentReachabilityStatus()
            internetReachability!.startNotifier()
        }
    }
    
    private func syncAvailable(_ status:NetworkStatus) -> Bool {
        return status == ReachableViaWiFi
    }
    
    func reachabilityChanged(_ notify:Notification) {
        if let currentReachability = notify.object as? Reachability {
            let newStatus = currentReachability.currentReachabilityStatus()
            if !syncAvailable(networkStatus) && syncAvailable(newStatus) {
                networkStatus = newStatus
                sync()
            } else {
                networkStatus = newStatus
            }
        }
    }

    func sync() {
        if syncAvailable(networkStatus) {
            getBloods({ bloodError in
                if bloodError != nil {
                    print("iCloud Refresh Error : \(bloodError!.localizedDescription)")
                } else {
                    self.getPressures({ pressureError in
                        if pressureError != nil {
                            print("iCloud Refresh Error : \(pressureError!.localizedDescription)")
                        } else {
                            NotificationCenter.default.post(name: refreshNotification, object: nil)
                            self.upload()
                        }
                    })
                }
            })
        }
    }
    
    func upload() {
        if syncAvailable(networkStatus) {
            let bloods = Model.shared.nonSyncedBloods()
            for blood in bloods {
                putBlood(blood, result: { record in
                    DispatchQueue.main.async {
                        if record != nil {
                            blood.recordName = record!.recordID.recordName
                            blood.synced = true
                            Model.shared.saveContext()
                        }
                    }
                })
            }
            let pressures = Model.shared.nonSyncedPressures()
            for pressure in pressures {
                putPressure(pressure, result: { record in
                    DispatchQueue.main.async {
                        if record != nil {
                            pressure.recordName = record!.recordID.recordName
                            pressure.synced = true
                            Model.shared.saveContext()
                        }
                    }
                })
            }
        }
    }
    
    // MARK: - Blood cloud table
    
    private func getBloods(_ result: @escaping(Error?) -> ()) {
        let date = Model.shared.myLastBlood()?.date
        let predicate = date == nil ? NSPredicate(value: true) : NSPredicate(format: "date > %@", date! as CVarArg)
        let query = CKQuery(recordType: "Blood", predicate: predicate)
        
        cloudDB!.perform(query, inZoneWith: nil) { results, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    result(error)
                }
                return
            }
            DispatchQueue.main.async {
                if results != nil {
                    for record in results! {
                        if let date = record.value(forKey: "date") as? NSDate {
                            var blood = Model.shared.bloodForDate(date)
                            if blood == nil {
                                blood = NSEntityDescription.insertNewObject(forEntityName: "Blood",
                                                                                into: Model.shared.managedObjectContext) as? Blood
                                blood!.date = date
                            }
                            blood!.value = record.value(forKey: "value") as! Double
                            blood!.comments = record.value(forKey: "comments") as? String
                            blood!.recordName = record.recordID.recordName
                            blood!.synced = true
                        }
                    }
                    Model.shared.saveContext()
                }
                result(nil)
            }
        }
    }

    private func getPressures(_ result: @escaping(Error?) -> ()) {
        let date = Model.shared.myLastPressure()?.date
        let predicate = date == nil ? NSPredicate(value: true) : NSPredicate(format: "date > %@", date! as CVarArg)
        let query = CKQuery(recordType: "Pressure", predicate: predicate)
        
        cloudDB!.perform(query, inZoneWith: nil) { results, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Refresh: \(error!.localizedDescription)")
                    result(error)
                }
                return
            }
            DispatchQueue.main.async {
                if results != nil {
                    for record in results! {
                        if let date = record.value(forKey: "date") as? NSDate {
                            var pressure = Model.shared.pressureForDate(date)
                            if pressure == nil {
                                pressure = NSEntityDescription.insertNewObject(forEntityName: "Pressure",
                                                                               into: Model.shared.managedObjectContext) as? Pressure
                                pressure!.date = date
                            }
                            pressure!.highValue = record.value(forKey: "highValue") as! Double
                            pressure!.lowValue = record.value(forKey: "lowValue") as! Double
                            pressure!.comments = record.value(forKey: "comments") as? String
                            pressure!.recordName = record.recordID.recordName
                            pressure!.synced = true
                        }
                    }
                    Model.shared.saveContext()
                }
                result(nil)
            }
        }
    }
    
    private func putBlood(_ blood:Blood, result: @escaping(CKRecord?) -> ()) {
        if blood.recordName != nil {
            fetchRecord(blood.recordName!, type: "Blood", record: { record in
                if record != nil {
                    record!.setValue(blood.date, forKey: "date")
                    record!.setValue(blood.value, forKey: "value")
                    record!.setValue(blood.comments, forKey: "comments")
                    self.saveRecord(record: record!, result: { cloudRecord in
                        result(cloudRecord)
                    })
                } else {
                    result(nil)
                }
            })
        } else {
            let record = CKRecord(recordType: "Blood")
            record.setValue(blood.date, forKey: "date")
            record.setValue(blood.value, forKey: "value")
            record.setValue(blood.comments, forKey: "comments")
            self.saveRecord(record: record, result: { cloudRecord in
                result(cloudRecord)
            })
        }
    }
    
    private func putPressure(_ pressure:Pressure, result: @escaping(CKRecord?) -> ()) {
        if pressure.recordName != nil {
            fetchRecord(pressure.recordName!, type: "Pressure", record: { record in
                if record != nil {
                    record!.setValue(pressure.date, forKey: "date")
                    record!.setValue(pressure.highValue, forKey: "highValue")
                    record!.setValue(pressure.lowValue, forKey: "lowValue")
                    record!.setValue(pressure.comments, forKey: "comments")
                    self.saveRecord(record: record!, result: { cloudRecord in
                        result(cloudRecord)
                    })
                } else {
                    result(nil)
                }
            })
        } else {
            let record = CKRecord(recordType: "Pressure")
            record.setValue(pressure.date, forKey: "date")
            record.setValue(pressure.highValue, forKey: "highValue")
            record.setValue(pressure.lowValue, forKey: "lowValue")
            record.setValue(pressure.comments, forKey: "comments")
            self.saveRecord(record: record, result: { cloudRecord in
                result(cloudRecord)
            })
        }
    }
    
    private func saveRecord(record:CKRecord, result: @escaping(CKRecord?) -> ()) {
        cloudDB!.save(record, completionHandler: { cloudRecord, err in
            DispatchQueue.main.async {
                if err != nil {
                    print(err!.localizedDescription)
                }
                result(cloudRecord)
            }
        })
    }
    
    private func fetchRecord(_ name:String, type:String, record: @escaping(CKRecord?) -> ()) {
        let predicate = NSPredicate(format: "recordName == %@", name)
        let query = CKQuery(recordType: type, predicate: predicate)
        cloudDB!.perform(query, inZoneWith: nil) { results, error in
            guard error == nil else {
                record(nil)
                return
            }
            DispatchQueue.main.async {
                record(results?.first)
            }
        }

    }
}
