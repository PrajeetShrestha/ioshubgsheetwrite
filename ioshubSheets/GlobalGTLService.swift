//
//  GlobalGTLService.swift
//  ioshubSheets
//
//  Created by Prajeet Shrestha on 8/12/16.
//  Copyright © 2016 eeposit. All rights reserved.
//

import Foundation
import GoogleAPIClient

class GlobalGTLService {
    static let sharedInstance = GlobalGTLService()
    let service = GTLService()
}