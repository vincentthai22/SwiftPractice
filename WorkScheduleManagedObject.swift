//
//  WorkScheduleManagedObject+CoreDataClass.swift
//  WorkHistoryTracker
//
//  Created by Vincent on 12/1/16.
//  Copyright © 2016 Seven Logics. All rights reserved.
//

import Foundation
import CoreData

@objc(WorkScheduleManagedObject)
public class WorkScheduleManagedObject: NSManagedObject {
    override public func awakeFromInsert() {
        super.awakeFromInsert()
    }
}
