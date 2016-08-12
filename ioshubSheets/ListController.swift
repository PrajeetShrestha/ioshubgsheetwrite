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

class ListController: UIViewController {
    var donorList = [Donor]()
    private let kKeychainItemName = "Google Sheets API1"
    private let kClientID         = sheetClientID
    private let kSpreadSheetID    = "1YLX32uGIJOieuouW_RidrEOmZknyxoPA_sZ5njAHJCw"
    
    @IBOutlet var tableView: UITableView!
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
        self.tableView.tableFooterView = UIView()
    }
    
    // When the view appears, ensure that the Google Sheets API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
        initiateBlockIfCanAuth(fetchList)
    }
    
    func fetchList() {
        let baseUrl = "https://sheets.googleapis.com/v4/spreadsheets"
        let range = "Sheet1!A:D"
        let url = String(format:"%@/%@/values/%@", baseUrl, kSpreadSheetID, range)
        let params = ["majorDimension": "ROWS"]
        let fullUrl = GTLUtilities.URLWithString(url, queryParameters: params)
        service.fetchObjectWithURL(fullUrl,
                                   objectClass: GTLObject.self,
                                   delegate: self,
                                   didFinishSelector: #selector(ViewController.displayResultWithTicket(_:finishedWithObject:error:))
        )
        
    }
    
    func initiateBlockIfCanAuth(handler:Void->Void) {
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            
            handler()
            
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    func displayResultWithTicket(ticket: GTLServiceTicket,
                                 finishedWithObject object : GTLObject,
                                                    error : NSError?) {
        
        if let error = error {
            
            showAlert("Error", message: error.localizedDescription)
            return
        }
        
        guard let values = object.JSON["values"] as? NSMutableArray else {
            return
        }
        var count = 0
        var donors = [Donor]()
        for value in values {
            
            if count != 0 {
                let strArra = value as! [String]
                let donor = Donor(name: strArra[0],
                                  type: strArra[1],
                                  contactNumber: strArra[2],
                                  email: strArra[3])
                
                donors.append(donor)
            }
            
            count = count + 1
        }
        self.donorList = donors
        self.tableView.reloadData()
        
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

extension ListController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.donorList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let donor = self.donorList[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("donorCell") as! DonorCell
        cell.lblName.text = donor.name
        cell.lblContact.text = donor.contactNumber
        cell.lblEmail.text = donor.email
        cell.lblType.text = donor.type
        return cell
    }
}
