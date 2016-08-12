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
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = ["https://www.googleapis.com/auth/spreadsheets"]
    
    private let service = GTLService()
    
    // When the view loads, create necessary subviews
    // and initialize the Google Sheets API service
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            listNames()
            postData()
            //listMajors()
            
            
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
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
    
    func postData() {
        let baseUrl = "https://sheets.googleapis.com/v4/spreadsheets"
        let range = "Sheet1!A1:D5"
        let url = String(format:"%@/%@/values/%@", baseUrl, kSpreadSheetID, range)
        
        
        let params = ["valueInputOption" :"USER_ENTERED"]
        
        let gValue:NSMutableDictionary =
            [
                "values":
                    
                    [
                        ["Item", "Cost", "Stocked", "Ship Date"],
                        ["Wheel", "$20.50", "4", "3/1/2016"],
                        ["Door", "$15", "2", "3/15/2016"],
                        ["Engine", "$100", "1", "30/20/2016"],
                        ["Totals", "=SUM(B2:B4)", "=SUM(C2:C4)", "=MAX(D2:D4)"]
                ]
        ]
        
        let gtlObject = GTLObject(JSON: gValue)
        let fullUrl = GTLUtilities.URLWithString(url, queryParameters: params)
        service.fetchObjectByUpdatingObject(gtlObject, forURL: fullUrl) {
            (ticket, gObj, error) in
            if let error = error {
                print(ticket)
                print(error.localizedDescription)
                // self.showAlert("Error", message: error.localizedDescription)
                return
            }
        }
    }
    
    
    // Display (in the UITextView) the names and majors of students in a sample
    // spreadsheet:
    // https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit
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
    
    
    // Process the response and display output
    func displayResultWithTicket(ticket: GTLServiceTicket,
                                 finishedWithObject object : GTLObject,
                                                    error : NSError?) {
        
        if let error = error {
            print(error.localizedDescription)
            //showAlert("Error", message: error.localizedDescription)
            return
        }
        
        print(object.JSON)
        
        //        var majorsString = ""
        //        let rows = object.JSON["values"] as! [[String]]
        //
        //        if rows.isEmpty {
        //            return
        //        }
        //
        //        majorsString += "Name, Major:\n"
        //        for row in rows {
        //            let name = row[0] ?? "Unknown"
        //            let major = row[4] ?? "Unknown"
        //
        //            majorsString += "\(name), \(major)\n"
        //        }
        //
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
