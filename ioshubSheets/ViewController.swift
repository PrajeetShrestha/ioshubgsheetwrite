//
//  ViewController.swift
//  ioshubSheets
//
//  Created by Eeposit1 on 8/12/16.
//  Copyright © 2016 eeposit. All rights reserved.
//

import GoogleAPIClient
import GTMOAuth2
import UIKit

class ViewController: UIViewController {
    
    private let kKeychainItemName = "Google Sheets API1"
    private let kClientID         = sheetClientID
    private let kSpreadSheetID    = "1YLX32uGIJOieuouW_RidrEOmZknyxoPA_sZ5njAHJCw"
    private var name:String!
    private var bloodGroup: String!
    private var contactInfo:String!
    private var email:String!
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    @IBOutlet var tfName: UITextField!
    @IBOutlet var tfBloodGroup: TextDrop1Column!
    @IBOutlet var tfContact: UITextField!
    @IBOutlet var tfEmail: UITextField!
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = ["https://www.googleapis.com/auth/spreadsheets"]
    
    private let service = GTLService()
    
    // When the view loads, create necessary subviews
    // and initialize the Google Sheets API service
    override func viewDidLoad() {
        super.viewDidLoad()
        tfBloodGroup.pickerDataArray = ["A+", "A-","B+","B-","O+","O-","AB+","AB-"]
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
        
    }
    
    // When the view appears, ensure that the Google Sheets API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
        
    }
    
    func postData() {
        let baseUrl = "https://sheets.googleapis.com/v4/spreadsheets"
        let range = "Sheet1!A1:D1"
        let url = String(format:"%@/%@/values/%@:append", baseUrl, kSpreadSheetID, range)
        
        
        let params = ["valueInputOption" :"USER_ENTERED"]
        
        let gValue:NSMutableDictionary =
            [
                "values":
                    
                    [
                        [self.name, self.bloodGroup, self.contactInfo, self.email]
                ]
        ]
        
        let gtlObject = GTLObject(JSON: gValue)
        let fullUrl = GTLUtilities.URLWithString(url, queryParameters: params)
        self.indicator.startAnimating()
        service.fetchObjectByInsertingObject(gtlObject, forURL: fullUrl) {
            (ticket, gObj, error) in
            self.indicator.stopAnimating()
            if let error = error {
                 self.showAlert("Failure", message: error.localizedDescription)
                return
            } else {
                self.showAlert("Success", message: "Successfully added new record")
            }
        }
    }
    
    @IBAction func send(sender: AnyObject) {
        if self.tfName.text?.characters.count == 0 ||
            self.tfEmail.text?.characters.count ==  0 ||
            self.tfContact.text?.characters.count ==  0 ||
            self.tfEmail.text?.characters.count == 0 {
            showAlert("Incomplete Form", message: "Please fill all the form fields!")
        } else {
            self.name = self.tfName.text
            self.contactInfo = self.tfContact.text
            self.bloodGroup = self.tfBloodGroup.text
            self.email = self.tfEmail.text
            
            
            if let authorizer = service.authorizer,
                canAuth = authorizer.canAuthorize where canAuth {
                
                postData()
                
            } else {
                presentViewController(
                    createAuthController(),
                    animated: true,
                    completion: nil
                )
            }
        }
    }
    
    
    // Creates the auth controller for authorizing access to Google Sheets API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: #selector(ViewController.viewController(_:finishedWithAuth:error:))
        )
    }
    
    // Handle completion of the authorization process, and update the Google Sheets API
    // with the new credentials.
    func viewController(vc : UIViewController,
                        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
        
        if let error = error {
            service.authorizer = nil
            showAlert("Authentication Error", message: error.localizedDescription)
            return
        }
        
        service.authorizer = authResult
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
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
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

/*
 Reference
 func listNames() {
 let baseUrl = "https://sheets.googleapis.com/v4/spreadsheets"
 let range = "Sheet1!A1:B5"
 let url = String(format:"%@/%@/values/%@", baseUrl, kSpreadSheetID, range)
 let params = ["majorDimension": "ROWS"]
 let fullUrl = GTLUtilities.URLWithString(url, queryParameters: params)
 service.fetchObjectWithURL(fullUrl,
 objectClass: GTLObject.self,
 delegate: self,
 didFinishSelector: #selector(ViewController.displayResultWithTicket(_:finishedWithObject:error:))
 )
 }
 
 func listMajors() {
 let baseUrl = "https://sheets.googleapis.com/v4/spreadsheets"
 let spreadsheetId = "1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms"
 let range = "Class%20Data!A2:E"
 let url = String(format:"%@/%@/values/%@", baseUrl, spreadsheetId, range)
 //let params = ["majorDimension": "ROWS"]
 let fullUrl = GTLUtilities.URLWithString(url, queryParameters: nil)
 service.fetchObjectWithURL(fullUrl,
 objectClass: GTLObject.self,
 delegate: self,
 didFinishSelector: #selector(ViewController.displayResultWithTicket(_:finishedWithObject:error:))
 )
 }
 */
