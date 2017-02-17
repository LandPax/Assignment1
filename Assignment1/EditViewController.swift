//
//  EditViewController.swift
//  Assignment1
//
//  Created by Assaf, Michael on 2017-02-07.
//  Copyright © 2017 Assaf, Michael. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {

    @IBOutlet var theName: UITextField!
    @IBOutlet var thePhoneNumber: UITextField!
    @IBOutlet var thePhoneType: UISegmentedControl!
    @IBOutlet var theAddress: UITextView!
    @IBOutlet var saveButton: UIButton!
    
    let MIN_NAME_LENGTH = 3
    let MIN_PHONE_LENGTH = 10
    let MAX_PHONE_LENGTH = 14
    var NAME_IS_VALID = false
    var PHONE_IS_VALID = false
    
    var theContact:Contact!
    var indexOfContact:Int!
    var objectToSave:ContactSavable!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Number Keyboard for Phone Text Field
        self.thePhoneNumber.keyboardType = UIKeyboardType.phonePad
        
        // Default Phone Type
        self.thePhoneType.selectedSegmentIndex = 3
        
        // Making Address Text View Border
        self.theAddress.layer.borderWidth = 0.5
        self.theAddress.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        self.theAddress.layer.cornerRadius = 5.0
        
        // Retrive data from saved Contacts and fill in the Text Fields
        if let _ = self.indexOfContact {
            self.theName.text = self.theContact.theName
            self.thePhoneNumber.text = self.theContact.thePhoneNum
            self.theAddress.text = self.theContact.theAddress
            self.thePhoneType.selectedSegmentIndex = {
                switch self.theContact.thePhoneType {
                    case .Home: return 0
                    case .Work: return 1
                    case .Mobile: return 2
                    case .Fax: return 3
                }
            }()
        }
        
        self.NAME_IS_VALID = true
        self.PHONE_IS_VALID = true
        self.theName.addTarget(self, action: #selector(nameDidChange(_:)), for: .editingChanged)
        self.thePhoneNumber.addTarget(self, action: #selector(phoneDidChange(_:)), for: .editingChanged)
    }

    @IBAction func doCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func doSave(_ sender: UIButton) {
        
        // Check which index was selected for the phone type
        let thePhoneType:PhoneType = {
            switch self.thePhoneType.selectedSegmentIndex {
                case 0: return .Home
                case 1: return .Work
                case 2: return .Mobile
                case 3: return .Fax
                default: return .Home
            }
        }()
        
        // Save the Contact
        if let _ = self.indexOfContact {
            self.theContact.theName = self.theName.text!
            self.theContact.thePhoneNum = self.thePhoneNumber.text!
            self.theContact.theAddress = self.theAddress.text!
            self.theContact.thePhoneType = thePhoneType
        }
        
        // Save Contact using Protocol
        self.objectToSave.SaveAContact(theContact: self.theContact, indexOfContact: self.indexOfContact)
        dismiss(animated: true, completion: nil)
    }
}

// Event Handlers
extension EditViewController {
    func nameDidChange(_ textField: UITextField) {
        // Check if theLength is Valid
        self.NAME_IS_VALID = (textField.text?.characters.count)! >= 3
        
        // Disable or Enable Save Button
        self.saveButton.isEnabled = self.NAME_IS_VALID && self.PHONE_IS_VALID
    }
    
    func phoneDidChange(_ textField: UITextField) {
        // Check if theLength is Valid
        let theLength = textField.text?.characters.count
        self.PHONE_IS_VALID = theLength! >= 10 && theLength! <= 14
        
        // Disable or Enable Save Button
        self.saveButton.isEnabled = self.NAME_IS_VALID && self.PHONE_IS_VALID
    }
}


