//
//  FormViewController.swift
//  s65project
//
//  Created by Chi Zhang on 7/27/15.
//  Copyright (c) 2015 Chi Zhang. All rights reserved.
//
// http://www.codingexplorer.com/choosing-images-with-uiimagepickercontroller-in-swift/

import UIKit
import Parse
import MobileCoreServices

struct Identifiers {
    static let ImagePickerSegue = "Show Image Picker"
}


class FormViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let sourceType: UIImagePickerControllerSourceType = .Camera
    let mediaTypes = [kUTTypeImage]
    
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var pictureReceived: UILabel!
    
    @IBOutlet weak var eventNameLabel: UITextField! {
        didSet {
            eventNameLabel.delegate = self
        }
    }
    
    @IBOutlet weak var addressLabel: UITextField! {
        didSet {
            addressLabel.delegate = self
        }
    }
    
    @IBOutlet weak var briefDescriptionLabel: UITextField! {
        didSet {
            briefDescriptionLabel.delegate = self
        }
    }
    
    @IBOutlet weak var whoShouldComeLabel: UITextField! {
        didSet {
            whoShouldComeLabel.delegate = self
        }
    }
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var iconPicker: UIPickerView!
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        newEvent.icon = iconPickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return iconPickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return iconPickerData.count
    }

    
    var iconPickerData = iconCollection.keys.array
    

    var newEvent = Event()
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == eventNameLabel {
            newEvent.name = textField.text
        }
        else if textField == addressLabel {
            newEvent.address = textField.text
        }
        else if textField == briefDescriptionLabel {
            newEvent.briefDescription = textField.text
        }
        else if textField == whoShouldComeLabel {
            newEvent.whoShouldCome = textField.text
        }
        else {
            assertionFailure("Unknown Textfield")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.libraryImagePicker.delegate = self
        
        let currentDate = NSDate()
        self.datePicker.minimumDate = currentDate
        self.iconPicker.delegate = self
        self.iconPicker.dataSource = self
        
        let dev = UIDevice.currentDevice()
        print("Device: \(dev.model) \(dev.description)")
        
        
        if dev.model == "iPhone Simulator" {
            button.enabled = false
            button.setTitle("No camera on simulator", forState: .Disabled)
            button.sizeToFit()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func eventDatePicker(sender: UIDatePicker) {
        newEvent.date = sender.date
    }
    
    
    
    
    @IBAction func submitPressed(sender: AnyObject) {
        var eventEntry = PFObject(className: "FinalDemoData")
        if (self.checkValidity()) {
            eventEntry[EventKeys.EventName] = newEvent.name
            eventEntry[EventKeys.EventAddress] = newEvent.address
            eventEntry[EventKeys.EventBriefDescription] = newEvent.briefDescription
            eventEntry[EventKeys.EventWhoShouldCome] = newEvent.whoShouldCome
            eventEntry[EventKeys.EventDate] = newEvent.date
            eventEntry[EventKeys.EventIcon] = newEvent.icon
            eventEntry[EventKeys.EventGoing] = newEvent.numberOfGoing
        
            if let imageData = newEvent.photoData {
                let imageFile = PFFile(name:"image.png", data:imageData)
                eventEntry[EventKeys.EventPhotoFile] = imageFile
            }
            else {
                let image = UIImage(named: "Default")
                let imageD = UIImageJPEGRepresentation(image, 0.5)
                let imageFile = PFFile(name:"image.png", data:imageD)
                eventEntry[EventKeys.EventPhotoFile] = imageFile
            }
        
            eventEntry.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    println("success")
                    self.cleanUI()
                } else {
                    println("Something wrong happened")
                }
            }
        }
        else {
            alertInfo("Missing Infonrmation")
        }
    }
    
    func alertInfo(message: String) {
        UIAlertView(title: "Error Message", message: message, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    func cleanUI() {
        eventNameLabel.text = ""
        addressLabel.text = ""
        briefDescriptionLabel.text = ""
        whoShouldComeLabel.text = ""
        let currentDate = NSDate()
        datePicker.date = currentDate
        pictureReceived.text = ""
    }
    

    
    func alert(message: String) {
        UIAlertView(title: "Photo message", message: message, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier != Identifiers.ImagePickerSegue {
            alert("Unknown segue \(identifier)")
            return false
        }
        if !UIImagePickerController.isSourceTypeAvailable(sourceType) {
            alert("source type \(sourceType.rawValue) not available")
            return false
        }
        let types = UIImagePickerController.availableMediaTypesForSourceType(sourceType) as? [String]
        if types == nil {
            alert("Could not retrieve media types for \(sourceType.rawValue)")
        }
        // make sure that all the media types we want are in fact available
        for wantedType in mediaTypes {
            if !contains(types!, wantedType as String) {
                alert("Media type \(wantedType) not available for source type \(sourceType)")
                return false
            }
        }
        return true
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != Identifiers.ImagePickerSegue {
            assertionFailure("Unknown segue: \(segue.identifier)")
        }
        else if let picker = segue.destinationViewController as? UIImagePickerController {
            picker.delegate = self
            picker.sourceType = sourceType
            picker.mediaTypes = mediaTypes
            picker.allowsEditing = false
        }
        else {
            assertionFailure("Unknown destination controller type: \(segue.destinationViewController)")
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pictureReceived.text = "Received!"
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            newEvent.photoData = imageData
        }
        else {
            alert("No image was picked somehow!")
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        println("Image picker canceled!")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func checkValidity() -> Bool {
        if newEvent.name == nil || newEvent.date == nil || newEvent.address == nil {
            return false
        }
        else {
            return true
        }
    }
    
    @IBAction func imageButtonTapped(sender: UIButton) {
        libraryImagePicker.allowsEditing = false
        libraryImagePicker.sourceType = .PhotoLibrary
        presentViewController(libraryImagePicker, animated: true, completion: nil)
    }
    
    let libraryImagePicker = UIImagePickerController()
    

}
