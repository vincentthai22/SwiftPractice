//
//  WorkSchedule.swift
//  WorkHistoryTracker
//
//  Created by Vincent on 12/1/16.
//  Copyright © 2016 Seven Logics. All rights reserved.
//

import Foundation
class WorkSchedule : NSObject {
    var name : String
    var hoursWorked : String
    var date : String
    init(hoursWorked : String, date : String) {
        self.hoursWorked = hoursWorked
        self.date = date
        self.name = "Vincent Thai"
    }
    override init (){
        self.name = ""
        self.date = ""
        self.hoursWorked = ""
    }
}
