//
//  File.swift
//  WorkHistoryTracker
//
//  Created by Vincent on 12/1/16.
//  Copyright © 2016 Seven Logics. All rights reserved.
//

import Foundation
import UIKit
class WorkHistoryTableViewController : UITableViewController {
    
    // MARK: Properties
    let workScheduleCoreData = WorkScheduleCoreData.init()
    
    //2-D Array which represents the data displayed within the tableview
    var tableViewData = [[AnyObject]]()
    var buttonSection : Array<Int> = Array(repeating: 0, count : 1)
    var workScheduleSection = [WorkSchedule]()
    let imageArray = [ #imageLiteral(resourceName: "kanga"), #imageLiteral(resourceName: "dog-1"), #imageLiteral(resourceName: "bunny"), #imageLiteral(resourceName: "snake")]
    
    //Indexes marking each section
    var buttonSectionIndex : Int?
    var workScheduleSectionIndex : Int?
    
    //Add new entry alert box
    let newItemAlertController = UIAlertController(title: "New Work Day", message: "Enter the date and it's respective work schedule", preferredStyle: .alert)
    
    //temporary workschedule object serves to move data into the array
    //var workDay = WorkScheduleManagedObject()
    var indexPath = IndexPath()         //save index path for editing
    var isEditingTable : Bool?          //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isEditingTable = false
        self.buttonSectionIndex = self.tableViewData.count                  //store button section index
        self.tableViewData.append(self.buttonSection as [AnyObject])        //initialize first section of array
        self.workScheduleSectionIndex = self.tableViewData.count            //store work schedule section index
        self.tableViewData.append(self.workScheduleCoreData.fetchRequest()) //fetch the work schedules from CoreData
        self.tableView.sectionHeaderHeight = 50
        setUpAlertBoxes()
    }
    
    func setUpAlertBoxes() -> Void{
        self.newItemAlertController.addTextField { (dateTextField) in
            dateTextField.placeholder = "Date"
        }
        self.newItemAlertController.addTextField { (hoursWorkedTextField) in
            hoursWorkedTextField.placeholder = "Hours worked"
        }
        
        //insert and edit are executed here
        let actionOK = UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction) in print("ok has been pressed")
            
            let row = self.tableViewData[self.workScheduleSectionIndex!].count
            let indexPath = [IndexPath.init(row: row, section: self.workScheduleSectionIndex!)]
            var workDay : WorkScheduleManagedObject?
            
            //Check if editing or adding a new entry
            if !self.isEditingTable! {
                workDay = self.workScheduleCoreData.getNewDay()         //new entry -- get a new WorkScheduleManagedObject
            } else {
                workDay = self.tableViewData[self.workScheduleSectionIndex!][self.indexPath.row] as? WorkScheduleManagedObject
            }
            
            workDay?.name = "Vincent Thai"
            workDay?.date = self.newItemAlertController.textFields![0].text!
            workDay?.hoursWorked = self.newItemAlertController.textFields![1].text!
            
            if !self.isEditingTable! { //adding new entry
                print("new entry: row to be insert \(row)")
                workDay?.image = UIImagePNGRepresentation(self.imageArray[Int(arc4random_uniform(UInt32(self.imageArray.count)))]) as NSData?
                self.tableViewData[self.workScheduleSectionIndex!].append(workDay!)
                self.tableView.insertRows(at: indexPath, with: .automatic)
            } else { //editing existing entry
                print ("editing")
                self.workScheduleCoreData.refresh(workDay: workDay!)
                self.tableViewData[self.workScheduleSectionIndex!][self.indexPath.row] = workDay!
                self.tableView.reloadRows(at: [self.indexPath], with: .automatic)
            }
            self.workScheduleCoreData.save()
            self.isEditingTable = false
            
            //reset the boxes
            for textField in self.newItemAlertController.textFields! {
                textField.text = ""
            }
        }) // End of actionOK definition
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action: UIAlertAction) in print ("cancel has been pressed")
            for textField in self.newItemAlertController.textFields! {
                textField.text = ""
            }
        })
        
        self.newItemAlertController.addAction(actionOK)
        self.newItemAlertController.addAction(actionCancel)
    }
    
    @IBAction func addButton(_ sender: Any) {
        self.newItemAlertController.title = "New Work Day"
        self.present(newItemAlertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            if indexPath.section == self.workScheduleSectionIndex {
                print ("removing at \(indexPath.row)")
                let workDay = self.tableViewData[self.workScheduleSectionIndex!][indexPath.row]
                self.tableViewData[self.workScheduleSectionIndex!].remove(at: indexPath.row)
                self.workScheduleCoreData.delete(workDay: workDay as! WorkScheduleManagedObject)
                self.workScheduleCoreData.save()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == self.workScheduleSectionIndex {
            let workDay = self.tableViewData[self.workScheduleSectionIndex!][indexPath.row] as? WorkScheduleManagedObject
            var index = 0
            for textField in self.newItemAlertController.textFields! {
                switch index {
                case 0:
                    textField.text = workDay?.date
                    break
                case 1:
                    textField.text = workDay?.hoursWorked
                    break
                default: break
                }
                index = index+1
            }
            self.indexPath = indexPath
            self.isEditingTable = true
            self.newItemAlertController.title = "Edit Existing Work Day"
            self.present(newItemAlertController, animated: true, completion: nil)
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch(section){
        case self.buttonSectionIndex!:
            return "Add new day"
        case self.workScheduleSectionIndex!:
            return "Work History"
        default:
            return "Section"
        }
    }
    
    // MARK: - Table view data source
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewData[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.section) {
            
        case self.buttonSectionIndex! :
            let cellIdentifier = "ButtonTableViewCell"
            let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ButtonTableViewCell
            return cell
            
        case self.workScheduleSectionIndex! :
            let cellIdentifier = "DataTableViewCell"
            let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DataTableViewCell
            let workDay = self.tableViewData[self.workScheduleSectionIndex!][indexPath.row] as! WorkScheduleManagedObject
            cell.nameLabel.text = workDay.name
            cell.dateLabel.text = workDay.date
            cell.hoursWorkedLabel.text = "Hours Worked : \(workDay.hoursWorked!)"
            DispatchQueue.global(qos: .background).async { //run in background
                if workDay.image == nil {
                    workDay.image = UIImagePNGRepresentation(self.imageArray[Int(arc4random_uniform(UInt32(self.imageArray.count)))]) as NSData?
                }
                cell.icon.image = UIImage(data: workDay.image as! Data)
                cell.icon.isHidden = false
            }
            return cell
            
        default :
            let cellIdentifier = "DataTableViewCell"
            let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DataTableViewCell
            return cell
            
            
        }
        
        
    }
    
}
