//
//  LoginController.swift
//  ioshubSheets
//
//  Created by Prajeet Shrestha on 8/12/16.
//  Copyright © 2016 eeposit. All rights reserved.
//

import UIKit
import GTMOAuth2


class LoginController: UIViewController {
    private let kKeychainItemName = "Google Sheets API1"
    private let kSpreadSheetID    = "1YLX32uGIJOieuouW_RidrEOmZknyxoPA_sZ5njAHJCw"
    private let scopes = ["https://www.googleapis.com/auth/spreadsheets"]
    private let service = GlobalGTLService.sharedInstance.service
    override func viewDidLoad() {
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
    }
    
    @IBAction func login(sender: AnyObject) {
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("tabBarController")
            self.showViewController(controller!, sender: nil)
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: #selector(viewController(_:finishedWithAuth:error:))
        )
    }
    
    func viewController(vc : UIViewController,
                        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
        
        if let error = error {
            service.authorizer = nil
            showAlert("Authentication Error", message: error.localizedDescription, controller: self)
            return
        }
        
        service.authorizer = authResult
        dismissViewControllerAnimated(true, completion: {
            //Navigate to second view controller
            if let authorizer = self.service.authorizer,
                canAuth = authorizer.canAuthorize where canAuth {
                //Navigation Code here
                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("tabBarController")
                self.showViewController(controller!, sender: nil)
            }
        })
    }
}
