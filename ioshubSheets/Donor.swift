//
//  Donor.swift
//  ioshubSheets
//
//  Created by Eeposit1 on 8/12/16.
//  Copyright © 2016 eeposit. All rights reserved.
//

import UIKit

class Donor {
    
    var name:String
    var type:String
    var contactNumber:String
    var email:String
    
    init(name:String, type:String, contactNumber:String, email:String) {
        self.name = name
        self.type = type
        self.contactNumber = contactNumber
        self.email = email
    }

}
