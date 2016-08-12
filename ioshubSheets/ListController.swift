//
//  ViewController.swift
//  ioshubSheets
//
//  Created by Eeposit1 on 8/12/16.
//  Copyright © 2016 eeposit. All rights reserved.
//

import UIKit
import GoogleAPIClient

class ListController: UIViewController {
    var donorList = [Donor]()
    @IBOutlet var tableView: UITableView!

    
    private let service = GlobalGTLService.sharedInstance.service
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.fetchList()
        
    }
    
    func fetchList() {
        let range = "Sheet1!A:D"
        let url = String(format:"%@/%@/values/%@", kBaseUrl, kSheetID, range)
        let params = ["majorDimension": "ROWS"]
        let fullUrl = GTLUtilities.URLWithString(url, queryParameters: params)
        service.fetchObjectWithURL(fullUrl,
                                   objectClass: GTLObject.self,
                                   delegate: self,
                                   didFinishSelector: #selector(displayResultWithTicket(_:finishedWithObject:error:))
        )
        
    }
    
    func displayResultWithTicket(ticket: GTLServiceTicket,
                                 finishedWithObject object : GTLObject,
                                                    error : NSError?) {
        if let error = error {
            
            showAlert("Error", message: error.localizedDescription, controller: self)
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refresh(sender: AnyObject) {
        fetchList()
        
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
