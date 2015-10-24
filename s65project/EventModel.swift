//
//  EventModel.swift
//  s65project
//
//  Created by Chi Zhang on 7/27/15.
//  Copyright (c) 2015 Chi Zhang. All rights reserved.
//
// http://www.elegantthemes.com/blog/freebie-of-the-week/beautiful-flat-icons-for-free
// http://andrefrommalta.com/random-number-generator-every-month-checked-authority/

import Foundation
import UIKit

struct EventKeys {
    static let EventName:String = "EventName"
    static let EventDate:String = "EventDate"
    static let EventBriefDescription:String = "BriefDescription"
    static let EventWhoShouldCome: String = "WhoShouldCome"
    static let EventAddress: String = "EventAddress"
    static let EventIcon: String = "EventIcon"
    static let EventPhotoFile: String = "EventPhotoFile"
    static let EventGoing: String = "EventGoing"
}


let iconCollection = [ "scooter" : "scooter.png", "helicopter" : "helicopter.png", "cart" : "cart.png", "art" : "art.png", "computer" : "computer.png", "brightness" : "brightness.png" ]


struct Event {
    var name: String?
    var date: NSDate?
    var briefDescription: String = "NA"
    var whoShouldCome: String = "NA"
    var address: String?
    var icon: String = "brightness"
    var photoData: NSData?
    var numberOfGoing: Int = 0
}

