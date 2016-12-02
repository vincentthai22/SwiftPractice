//
//  WorkScheduleCoreData.swift
//  WorkHistoryTracker
//
//  Created by Vincent on 12/1/16.
//  Copyright © 2016 Seven Logics. All rights reserved.
//

import Foundation
import UIKit
import CoreData
class WorkScheduleCoreData {
    static let workHistoryCoreData = WorkScheduleCoreData()
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var managedContext : NSManagedObjectContext?
    var entity : NSEntityDescription?
    var workDay : WorkScheduleManagedObject?
     init(){
        self.managedContext = (self.appDelegate?.persistentContainer.viewContext)!
        self.entity = NSEntityDescription.entity(forEntityName: "WorkSchedule", in: managedContext!)!
        
    }
    func fetchRequest() -> [WorkScheduleManagedObject] {
        let request = NSFetchRequest<WorkScheduleManagedObject>(entityName: "WorkSchedule")
        do {
        let results = try self.managedContext?.fetch(request)
            return results!
        } catch {
            
        }
        return [WorkScheduleManagedObject].init()
    }
    func insert(workDay : WorkScheduleManagedObject) -> Void {
        self.managedContext?.insert(workDay)
    }
    func delete(workDay : WorkScheduleManagedObject) -> Void {
        self.managedContext?.delete(workDay)
    }
    
    func refresh(workDay : WorkScheduleManagedObject) -> Void {
        self.managedContext?.refresh(workDay, mergeChanges: true)
    }
    
    func getNewDay() -> WorkScheduleManagedObject {
        return WorkScheduleManagedObject(entity: entity!, insertInto: self.managedContext)
    }
    
    func save() -> Void {
        do{
         try self.managedContext?.save()
        }catch {
            
        }
    }
}
