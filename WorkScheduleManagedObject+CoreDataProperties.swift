//
//  WorkScheduleManagedObject+CoreDataProperties.swift
//  WorkHistoryTracker
//
//  Created by Vincent on 12/1/16.
//  Copyright © 2016 Seven Logics. All rights reserved.
//

import Foundation
import CoreData


extension WorkScheduleManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkScheduleManagedObject> {
        return NSFetchRequest<WorkScheduleManagedObject>(entityName: "WorkSchedule");
    }

    @NSManaged public var date: String?
    @NSManaged public var hoursWorked: String?
    @NSManaged public var image: NSData?
    @NSManaged public var name: String?

}
