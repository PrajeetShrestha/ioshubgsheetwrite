//
//  LoginController.swift
//  ioshubSheets
//
//  Created by Prajeet Shrestha on 8/12/16.
//  Copyright © 2016 eeposit. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2


class LoginController: UIViewController {

    private let service = GlobalGTLService.sharedInstance.service
    override func viewDidLoad() {

    }
    
    @IBAction func login(sender: AnyObject) {
        self.presentViewController(createAuthController(), animated: true
            , completion: nil)
    }
    
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = kScopes.joinWithSeparator(" ")
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
