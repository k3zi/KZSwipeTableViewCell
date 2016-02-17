//
//  ViewController.swift
//  KZSwipeTableViewCellExample
//
//  Created by Kesi Maduka on 2/9/16.
//  Copyright © 2016 Storm Edge Apps LLC. All rights reserved.
//

import UIKit
import KZSwipeTableViewCell

class ViewController: UITableViewController {
    
    var numOfItems = 7
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "Swipe Table View"
        if let nav = navigationController {
            nav.navigationBar.tintColor = UIColor.darkGrayColor()
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: Selector("reload"))
        
        let backgroundView = UIView(frame: view.bounds)
        backgroundView.backgroundColor = UIColor(white: 227/0/255.0, alpha: 1.0)
        self.tableView.backgroundView = backgroundView
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    //MARK: TableView Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numOfItems
    }
    
    //MARK: TableView Delegate
    
    func configureCell(cell: KZSwipeTableViewCell, indexPath: NSIndexPath) {
        let checkView = KZSwipeTableViewCell.viewWithImageName("check")
        let greenColor = UIColor(red: 85.0/255.0, green: 213.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        
        let crossView = KZSwipeTableViewCell.viewWithImageName("cross")
        let redColor = UIColor(red: 232.0/255.0, green: 61.0/255.0, blue: 14.0/255.0, alpha: 1.0)
        
        let clockView = KZSwipeTableViewCell.viewWithImageName("clock")
        let yellowColor = UIColor(red: 254.0/255.0, green: 217.0/255.0, blue: 56.0/255.0, alpha: 1.0)
        
        let listView = KZSwipeTableViewCell.viewWithImageName("list")
        let brownColor = UIColor(red: 206.0/255.0, green: 149.0/255.0, blue: 98.0/255.0, alpha: 1.0)
        
        if let bgView = self.tableView.backgroundView {
            if let bgColor = bgView.backgroundColor {
                cell.settings.defaultColor = bgColor
            }
        }
        
        if indexPath.row % numOfItems == 0 {
            cell.textLabel?.text = "Switch Mode Cell"
            cell.detailTextLabel?.text = "Swipe to switch"
            
            cell.setSwipeGestureWith(checkView, color: greenColor, mode: .Switch, state: .State1, completionBlock: { (cell, state, mode) -> Void in
                print("Did swipe Checkmark cell")
            })
            
            cell.setSwipeGestureWith(crossView, color: redColor, mode: .Switch, state: .State2, completionBlock: { (cell, state, mode) -> Void in
                print("Did swipe Cross cell")
            })
            
            cell.setSwipeGestureWith(clockView, color: yellowColor, mode: .Switch, state: .State3, completionBlock: { (cell, state, mode) -> Void in
                print("Did swipe Clock cell")
            })
            
            cell.setSwipeGestureWith(listView, color: brownColor, mode: .Switch, state: .State4, completionBlock: { (cell, state, mode) -> Void in
                print("Did swipe List cell")
            })
        } else if indexPath.row % numOfItems == 1 {
            cell.textLabel?.text = "Exit Mode Cell"
            cell.detailTextLabel?.text = "Swipe to delete"
            
            cell.setSwipeGestureWith(crossView, color: redColor, mode: .Switch, state: .State1, completionBlock: { (cell, state, mode) -> Void in
                print("Did swipe Cross cell")
                
                self.deleteCell(cell)
            })
        } else if indexPath.row % numOfItems == 2 {
            cell.textLabel?.text = "Mixed Mode Cell"
            cell.detailTextLabel?.text = "Swipe to switch or delete"
            cell.settings.shouldAnimateIcons = true
            
            cell.setSwipeGestureWith(checkView, color: greenColor, mode: .Switch, state: .State1, completionBlock: { (cell, state, mode) -> Void in
                print("Did swipe Checkmark cell")
            })
            
            cell.setSwipeGestureWith(crossView, color: redColor, mode: .Exit, state: .State2, completionBlock: { (cell, state, mode) -> Void in
                print("Did swipe Cross cell")
                
                self.deleteCell(cell)
            })
        } else if indexPath.row % numOfItems == 3 {
            cell.textLabel?.text = "Un-animated Icons"
            cell.detailTextLabel?.text = "Swipe"
            cell.settings.shouldAnimateIcons = false
            
            cell.setSwipeGestureWith(checkView, color: greenColor, mode: .Switch, state: .State1, completionBlock: { (cell, state, mode) -> Void in
                print("Did swipe Checkmark cell")
            })
            
            cell.setSwipeGestureWith(crossView, color: redColor, mode: .Exit, state: .State2, completionBlock: { (cell, state, mode) -> Void in
                print("Did swipe Cross cell")
                
                self.deleteCell(cell)
            })
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        
        if cell == nil {
            cell = KZSwipeTableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
        }
        
        if let cell = cell as? KZSwipeTableViewCell {
            configureCell(cell, indexPath: indexPath)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
    func reload() {
        numOfItems = 7
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
    }
    
    func deleteCell(cell: KZSwipeTableViewCell) {
        numOfItems--;
        if let indexPath = tableView.indexPathForCell(cell) {
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}
