//
//  Weight+CoreDataProperties.swift
//  Glucograph
//
//  Created by Sergey Seitov on 24.07.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import Foundation
import CoreData


extension Weight {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Weight> {
        return NSFetchRequest<Weight>(entityName: "Weight")
    }

    @NSManaged public var comments: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var recordName: String?
    @NSManaged public var synced: Bool
    @NSManaged public var value: Int32

}
