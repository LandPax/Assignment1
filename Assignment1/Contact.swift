//
//  Contact.swift
//  Assignment1
//
//  Created by Assaf, Michael on 2017-02-07.
//  Copyright © 2017 Assaf, Michael. All rights reserved.
//

import Foundation

class Contact {
    var theName:String
    var thePhoneNum:String
    var thePhoneType:PhoneType
    var theAddress:String
    var theManagedObject:PersonEntity!
    
    var thePhoneTypeAsString:String {
        get {
            return self.thePhoneType.rawValue
        }
    }
    
    init(theName:String, thePhoneNum:String, thePhoneType:PhoneType = .Home, theAddress:String="", theManagedObject:PersonEntity){
        self.theName = theName
        self.thePhoneNum = thePhoneNum
        self.thePhoneType = thePhoneType
        self.theAddress = theAddress
        self.theManagedObject = theManagedObject
    }
}
