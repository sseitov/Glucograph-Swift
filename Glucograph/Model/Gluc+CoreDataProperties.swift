//
//  Gluc+CoreDataProperties.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 10.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import Foundation
import CoreData


extension Gluc {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Gluc> {
        return NSFetchRequest<Gluc>(entityName: "Gluc");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var type: Int16
    @NSManaged public var value: Double
    @NSManaged public var comments: String?

}
