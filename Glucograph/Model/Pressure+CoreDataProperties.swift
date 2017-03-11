//
//  Pressure+CoreDataProperties.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 11.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import Foundation
import CoreData


extension Pressure {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pressure> {
        return NSFetchRequest<Pressure>(entityName: "Pressure");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var highValue: Double
    @NSManaged public var lowValue: Double
    @NSManaged public var comments: String?
    @NSManaged public var recordName: String?
    @NSManaged public var zoneName: String?
    @NSManaged public var ownerName: String?

}
