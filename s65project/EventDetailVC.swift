//
//  EventDetailVC.swift
//  s65project
//
//  Created by Chi Zhang on 7/27/15.
//  Copyright (c) 2015 Chi Zhang. All rights reserved.
//


import UIKit
import MapKit
import Social
import EventKit
import Parse

struct MapSegue {
    static let identifier: String = "show map"
}

class EventDetailVC: UIViewController {
    
    var summary: String {
        return "\(self.thisName) will be happening on \(self.thisDateString) at \(self.thisAddress)!"
    }
    
    var thisIdentifier: String?
    var thisName: String!
    var thisDate: NSDate! {
        didSet {
            var dateFormatter = NSDateFormatter()
            var timeFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            let dateString = dateFormatter.stringFromDate(self.thisDate)
            let timeString = timeFormatter.stringFromDate(self.thisDate)
            self.thisDateString = dateString + " " + timeString
        }

    }
  
    var thisDateString: String!
    
    
    var thisDescription: String!
    var thisWhoShouldCome: String!
    var thisAddress: String!
    var thisGoing: Int?
    
    var imageFile: UIImage? {
        didSet {
            eventImage.image = imageFile
        }
    }
    
    @IBOutlet weak var eventDescription: UILabel! {
        didSet {
            eventDescription.text = "\(self.thisName) \n \(self.thisAddress) \n \(self.thisDateString) \n \(self.thisDescription) \n \(self.thisWhoShouldCome)"
        }
    }
    
    @IBOutlet weak var eventImage: UIImageView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var addToCalendar: UIButton!
    
    @IBOutlet weak var goingButton: UIButton!
    
    @IBOutlet weak var numberOfGoing: UILabel! {
        didSet {
            numberOfGoing.text = "\(self.thisGoing!) people are going"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // AppDoca
    
    @IBAction func shareButtonClicker(sender: UIButton) {
        let shareMenu = UIAlertController(title: nil, message: "Share using", preferredStyle: .ActionSheet)
        let twitterAction = UIAlertAction(title: "Twitter", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                let tweetComposer = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                tweetComposer.setInitialText(self.summary)
                tweetComposer.addImage(self.imageFile)
                self.presentViewController(tweetComposer, animated: true, completion: nil)
            }
            else {
                let alertMessage = UIAlertController(title: "Twitter Unavailable", message: "You haven't registered your Twitter account. Please go to Settings > Twitter to create one.", preferredStyle: .Alert)
                alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alertMessage, animated: true, completion: nil)
            }
        })
        
        let facebookAction = UIAlertAction(title: "Facebook", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                let facebookComposer = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                facebookComposer.setInitialText(self.summary)
                facebookComposer.addImage(self.imageFile)
                self.presentViewController(facebookComposer, animated: true, completion: nil)
            }
            else {
                let alertMessage = UIAlertController(title: "Facebook Unavailable", message: "You haven't registered your Facebook account. Please go to Settings > Facebook to sign in or create one.", preferredStyle: .Alert)
                alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alertMessage, animated: true, completion: nil)
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        shareMenu.addAction(twitterAction)
        shareMenu.addAction(facebookAction)
        shareMenu.addAction(cancelAction)
        self.presentViewController(shareMenu, animated: true, completion: nil)
    }
    
    
    //  https://gist.github.com/mchirico/d072c4e38bda61040f91
    @IBAction func addToCalendarClicked(sender: AnyObject) {
        var eventStore: EKEventStore = EKEventStore()
        eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion: {(granted, error) in
            if granted && error == nil {
                var event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = self.thisName
                event.startDate = self.thisDate
                event.endDate = self.thisDate.dateByAddingTimeInterval(4 * 60 * 60)
                event.notes = self.thisDescription! + " " + self.thisWhoShouldCome!
                event.calendar = eventStore.defaultCalendarForNewEvents
                eventStore.saveEvent(event, span: EKSpanThisEvent, error: nil)
                println("Saved Event")
                self.alertCalendar("Succeed!")
            }
            else {
                self.alertCalendar("Error!")
            }
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        var query = PFQuery(className:"FinalDemoData")
        query.getObjectInBackgroundWithId(self.thisIdentifier!) {
            (eventObject: PFObject?, error: NSError?) -> Void in
            if error != nil {
                println(error)
            } else if let eventObject = eventObject {
                eventObject[EventKeys.EventGoing] = self.thisGoing
                eventObject.saveInBackground()
            }
        }
    }
    
    
    @IBAction func goingClicked(sender: AnyObject) {
        if var number: Int = self.thisGoing {
            number++
            self.thisGoing = number
        }
        self.numberOfGoing.text = "\(self.thisGoing!) people are going"
        // goingButton.text = "You're Going"
        goingButton.setTitle("You're Going!", forState: UIControlState.Normal)
        goingButton.enabled = false
    }
    
    
    func alertCalendar(message: String) {
        UIAlertView(title: "Calendar Message", message: message, delegate: nil, cancelButtonTitle: "OK").show()
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MapSegue.identifier {
            if let mapVC = segue.destinationViewController as? MapVC {
                mapVC.eventName = self.thisName
                mapVC.address = self.thisAddress
            }
        }
    }
    
}