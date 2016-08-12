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

class AddDonorDataController: UIViewController {
    
    private let service = GlobalGTLService.sharedInstance.service
    private var name:String!
    private var bloodGroup: String!
    private var contactInfo:String!
    private var email:String!
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var tfName: UITextField!
    @IBOutlet var tfBloodGroup: TextDrop1Column!
    @IBOutlet var tfContact: UITextField!
    @IBOutlet var tfEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfBloodGroup.pickerDataArray = ["A+", "A-","B+","B-","O+","O-","AB+","AB-"]
    }
    
    @IBAction func send(sender: AnyObject) {
        if self.tfName.text?.characters.count == 0 ||
            self.tfEmail.text?.characters.count ==  0 ||
            self.tfContact.text?.characters.count ==  0 ||
            self.tfEmail.text?.characters.count == 0 {
            showAlert("Incomplete Form", message: "Please fill all the form fields!", controller: self)
        } else {
            self.name = self.tfName.text
            self.contactInfo = self.tfContact.text
            self.bloodGroup = self.tfBloodGroup.text
            self.email = self.tfEmail.text
            self.postData()
        }
    }
    
    func clearData() {
        self.tfName.text = ""
        self.tfEmail.text = ""
        self.tfContact.text = ""
        self.tfBloodGroup.text = ""
    }
    
    func postData() {
        let range = "Sheet1!A1:D1"
        let url = String(format:"%@/%@/values/%@:append", kBaseUrl, kSheetID, range)
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
                showAlert("Failure", message: error.localizedDescription, controller: self)
                return
            } else {
                showAlert("Success", message: "Successfully added new record", controller: self)
            }
        }
    }
    
}
