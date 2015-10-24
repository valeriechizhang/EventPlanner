//
//  ListTableVC.swift
//  s65project
//
//  Created by Chi Zhang on 7/27/15.
//  Copyright (c) 2015 Chi Zhang. All rights reserved.
//

// http://shrikar.com/parse-search-in-ios-8-with-swift/

import UIKit
import Parse
import MapKit

struct TableSegue {
    static let identifier: String = "basic detail segue"
}


struct TitleColors {
    static let mostPopular = UIColor(red: 0, green: 0, blue: 102/255, alpha: 1)
    static let moderatePopular = UIColor(red: 0, green: 128/255, blue: 1, alpha: 1)
    static let notPopular = UIColor(red: 102/255, green: 178/255, blue: 1, alpha: 1)
    static let leastPopular = UIColor(red: 153/255, green: 204/255, blue: 1, alpha: 1)
}



class ListTableVC: UITableViewController, UISearchBarDelegate {
    
    var eventList: [PFObject]!
    var eventCount = 0
    

    var searchController: UISearchController!
    var searchResults: [PFObject]!
    var searchActive: Bool = false
    
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(true)
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        search()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // search
    
    func search(searchText: String? = nil) {
        let query = PFQuery(className: "FinalDemoData")
        if(searchText != nil) {
            query.whereKey(EventKeys.EventName, containsString: searchText)
        }
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            self.eventList = (results as? [PFObject])!
            self.tableView.reloadData()
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchText: searchText)
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.eventList != nil) {
            return self.eventList.count
        }
        return 0
    }
    
    
    func setTitleColor(eventItem: PFObject) -> UIColor {
        let numberGoing = eventItem[EventKeys.EventGoing] as! Int
        if numberGoing >= 100 {
            return TitleColors.mostPopular
        }
        else if numberGoing < 100 && numberGoing >= 50 {
            return TitleColors.moderatePopular
        }
        else if numberGoing < 50 && numberGoing >= 20 {
            return TitleColors.notPopular
        }
        else {
            return TitleColors.leastPopular
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("basic table cell", forIndexPath: indexPath)as! ListTableViewCell

        let item = eventList[indexPath.row]
        
        
        if let name = item[EventKeys.EventName] as? String {
            cell.eventNameLabel.text = name
            cell.eventNameLabel.textColor = setTitleColor(item)
        }
        
        
        if let loc = item[EventKeys.EventAddress] as? String {
            cell.locationLabel.text = loc
        }
        
        if let time = item[EventKeys.EventDate] as? NSDate {
            var dateFormatter = NSDateFormatter()
            var timeFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            let dateString = dateFormatter.stringFromDate(time)
            let timeString = timeFormatter.stringFromDate(time)
            cell.timeLabel.text = dateString + " " + timeString
        }
        
        if let icon = item[EventKeys.EventIcon] as? String {
            if let iconImage = iconCollection[icon] {
                cell.iconImageView.image = UIImage(named: iconImage)
            }
        } 
        return cell
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == TableSegue.identifier {
            if let indexPath = tableView.indexPathForSelectedRow() {
                if let detailVC = segue.destinationViewController as? EventDetailVC {
                    let item = eventList[indexPath.row]
                    detailVC.title = "Event Detail"
                    detailVC.thisName = "\(item[EventKeys.EventName]!)"
                    detailVC.thisAddress = "\(item[EventKeys.EventAddress]!)"
                    detailVC.thisDescription = "\(item[EventKeys.EventBriefDescription]!)"
                    detailVC.thisWhoShouldCome = "\(item[EventKeys.EventWhoShouldCome]!)"
                    
                    let going = item[EventKeys.EventGoing] as! Int
                    detailVC.thisGoing = going
                    
                    let date = item[EventKeys.EventDate] as! NSDate
                    detailVC.thisDate = date
                    
                    detailVC.thisIdentifier = item.objectId!
                    
        
                    let userImageFile = item[EventKeys.EventPhotoFile] as! PFFile
                    userImageFile.getDataInBackgroundWithBlock {
                        (imageData: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                let image = UIImage(data:imageData)
                                detailVC.imageFile = image
                            }
                        }
                    }
                    
                }
                
            }
        }
        else {
            assertionFailure("Unknown Segue")
        }
        
    }

    @IBAction func refresh(sender: UIRefreshControl) {
        search()
        //println("what is going on?")
        //self.tableView.reloadData()
        self.refreshControl!.endRefreshing()
    }

}
