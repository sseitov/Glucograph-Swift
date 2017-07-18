//
//  Blood+CoreDataProperties.swift
//  Glucograph
//
//  Created by Sergey Seitov on 18.07.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import Foundation
import CoreData


extension Blood {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Blood> {
        return NSFetchRequest<Blood>(entityName: "Blood")
    }

    @NSManaged public var comments: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var value: Double
    @NSManaged public var recordName: String?
    @NSManaged public var synced: Bool

}
