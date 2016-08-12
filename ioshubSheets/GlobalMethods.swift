//
//  GlobalMethods.swift
//  ioshubSheets
//
//  Created by Prajeet Shrestha on 8/12/16.
//  Copyright © 2016 eeposit. All rights reserved.
//

import UIKit

func showAlert(title : String, message: String, controller:UIViewController) {
    let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: UIAlertControllerStyle.Alert
    )
    let ok = UIAlertAction(
        title: "OK",
        style: UIAlertActionStyle.Default,
        handler: nil
    )
    alert.addAction(ok)
    controller.presentViewController(alert, animated: true, completion: nil)
}