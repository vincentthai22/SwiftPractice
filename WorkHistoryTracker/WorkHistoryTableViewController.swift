//
//  WorkHistoryTableViewController.swift
//  WorkHistoryTracker
//
//  Created by Vincent on 12/1/16.
//  Copyright © 2016 Seven Logics. All rights reserved.
//
//  current task: REDO ENTIRE PROJECT IN OBJ C

import Foundation
import UIKit
class WorkHistoryTableViewController : UITableViewController {
    
    // MARK: Properties
    let workScheduleCoreData = WorkScheduleCoreData.init()
    
    let imageCache = NSCache<NSIndexPath, UIImage>()
    var defaultCellHeight : CGFloat = 100.0
    
    //2-D Array which represents the data displayed within the tableview
    var tableViewData = [[AnyObject]]()
    var buttonSection : Array<Int> = Array(repeating: 0, count : 1)
    var workScheduleSection = [WorkSchedule]()
    let imageArray = [ #imageLiteral(resourceName: "kanga"), #imageLiteral(resourceName: "dog-1"), #imageLiteral(resourceName: "bunny"), #imageLiteral(resourceName: "snake"), #imageLiteral(resourceName: "squid"), #imageLiteral(resourceName: "shark"), #imageLiteral(resourceName: "turtle")]
    
    //Indexes marking each section
    var buttonSectionIndex : Int?
    var workScheduleSectionIndex : Int?
    
    //Add new entry alert box
    let newItemAlertController = UIAlertController(title: "New Work Day", message: "Enter the date and it's respective work schedule", preferredStyle: .alert)
    let randomizePicturesAlertController = UIAlertController(title: "Feelin' Lucky?", message: "Randomize all pictures!", preferredStyle: .alert)
    
    var indexPath = IndexPath()         //save index path for editing
    var isEditingTable : Bool?          //controls the actionOK button for editing or new entry
    
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
        
        self.newItemAlertController.addTextField { (nameTextField) in
            nameTextField.placeholder="Enter Your Name Here"
        }
        
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
            // assign values from textfields
            workDay?.name = (self.newItemAlertController.textFields![0].text?.characters.count)! > 1 ? self.newItemAlertController.textFields![0].text : "Vincent Thai"
            workDay?.date = self.newItemAlertController.textFields![0].text!
            workDay?.hoursWorked = self.newItemAlertController.textFields![1].text!
            
            if workDay?.date == "" {
                workDay?.date = Date().description.substring(to: Date().description.index(Date().description.startIndex, offsetBy: 10))
            }
            
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
            let numCells = self.tableViewData[1].count
            self.tableView.setContentOffset(CGPoint.init(x: 0, y: CGFloat.init(numCells) * self.tableView.rowHeight), animated: true)
            
            //reset the boxes
            for textField in self.newItemAlertController.textFields! {
                textField.text = ""
            }
        })
        // End of actionOK definition
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action: UIAlertAction) in print ("cancel has been pressed")
            for textField in self.newItemAlertController.textFields! {
                textField.text = ""
            }
            if self.isEditingTable! {
                self.isEditingTable = false
            }
        })
        
        let randomizerActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action: UIAlertAction) in print ("cancel has been pressed")
            
        })
        //Randomizer OK button handler
        let randomizerActionOK = UIAlertAction(title: "OK", style: .default, handler: {
            (action : UIAlertAction) in
            for workDay in (self.tableViewData[self.workScheduleSectionIndex!] as! [WorkScheduleManagedObject]) {
                workDay.image = UIImagePNGRepresentation(self.imageArray[Int(arc4random_uniform(UInt32(self.imageArray.count)))]) as NSData?
                self.tableView.reloadSections(NSIndexSet.init(index: self.workScheduleSectionIndex!) as IndexSet, with: .bottom)
                self.workScheduleCoreData.save()
                self.imageCache.removeAllObjects()
            }
        })
        
        self.randomizePicturesAlertController.addAction(randomizerActionOK)
        self.randomizePicturesAlertController.addAction(randomizerActionCancel)
        self.newItemAlertController.addAction(actionOK)
        self.newItemAlertController.addAction(actionCancel)
    }
    
    @IBAction func addButton(_ sender: Any) {
        self.newItemAlertController.title = "New Work Day"
        self.present(newItemAlertController, animated: true, completion: nil)
    }
    @IBAction func dicebutton(_ sender: UIButton) {
        self.present(randomizePicturesAlertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.imageCache.removeAllObjects()
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
    /* Function : tableView didSelectRowAt
    *  Serves as an onClick listener for the table for row selection. Used for editing.
    */
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

//    Creates a floating view for the section header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerText = UILabel.init(frame: CGRect(x: 150, y: 0, width: 150, height: 50))
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 500, height: 50))
        view.backgroundColor = UIColor.groupTableViewBackground
        switch (section) {
        case self.buttonSectionIndex!:
            headerText.text = "Add a new day"
            break
        case self.workScheduleSectionIndex!:
            headerText.text = "Work History"
            break
        default:
            headerText.text = "Section"
            break
        }
        view.addSubview(headerText)
        return view
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewData[section].count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return defaultCellHeight
    }
    
    /*  Function : tableView willDisplay :
    *   Renders the cells that are visible on screen. assigning data here is more appropriate because it is what the user is seeing.
    */
    override func tableView(_ tableView: UITableView, willDisplay cell2: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == workScheduleSectionIndex {
            let cell = cell2 as! DataTableViewCell
            let workDay = self.tableViewData[self.workScheduleSectionIndex!][indexPath.row] as! WorkScheduleManagedObject
            cell.nameLabel.text = workDay.name
            cell.dateLabel.text = workDay.date
            cell.hoursWorkedLabel.text = "Hours Worked : \(workDay.hoursWorked!)"
            cell.hoursWorkedLabel.textColor = UIColor.red
            
            DispatchQueue.global(qos: .background).async(execute: {//load image in background thread (heavy lifting)
                
                var image : UIImage?  //temporary image variable to hold data on background thread
                
                if self.imageCache.object(forKey: indexPath as NSIndexPath) != nil {//if image is stored in cache
                    print ("Cache accessed")
                    image = self.imageCache.object(forKey: indexPath as NSIndexPath)  //retrieve from cache
                } else { //image is not in cache, place into cache and initialize.
                    image = UIImage(data: workDay.image as! Data)
                    self.imageCache.setObject(image!, forKey: indexPath as NSIndexPath) //store into cache
                }
                DispatchQueue.main.async {
                    //load the image using the main thread
                    cell.icon.image = image
                }
            })
        }

    }
    
    /* Function : tableView cellForRowAt
    *  Initializes cells, should not perform assignments of data here because it will cause the table to render cells that are not visible which will lead to lag.
    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.section) {
            
        case self.buttonSectionIndex! :
            let cellIdentifier = "ButtonTableViewCell"
            let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ButtonTableViewCell
            cell.alpha = 1.0
            return cell
            
        case self.workScheduleSectionIndex! :
            let cellIdentifier = "DataTableViewCell"
            let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DataTableViewCell
            cell.alpha = 1.0
            return cell
            
        default :
            let cellIdentifier = "DataTableViewCell"
            let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DataTableViewCell
            return cell
            
        }
    }
}
//
//    if workDay.image == nil {
//    workDay.image = UIImagePNGRepresentation(self.imageArray[Int(arc4random_uniform(UInt32(self.imageArray.count)))]) as NSData?
//    }
//                UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
//                let context = UIGraphicsGetCurrentContext()
//                context?.draw((image?.cgImage)!, in: CGRect(x: 0, y: 0, width: (image!.size.width), height: image!.size.height))
//                UIGraphicsEndImageContext()
//    sets the title for section header but it remains static (not floating).
//
//section header (non-floating)
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//
//        switch(section){
//        case self.buttonSectionIndex!:
//            return "Add new day"
//        case self.workScheduleSectionIndex!:
//            return "Work History"
//        default:
//            return "Section"
//        }
//    }
