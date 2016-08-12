//  Created by Prajeet Shrestha on 2/24/16.
//  Copyright © 2016 Prajeet Shrestha. All rights reserved.

import UIKit
/*
USAGE:
______

TextDrop1Column is a subclass of UITextField, whose input view is a picker view with one component (Column)

The two components should be loaded in following order:
1. pickerDataArray


When you load the pickerDataArray then only TextDrop1Column object is loaded with a desired 1 column picker view


*/
class TextDrop1Column: UITextField, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    private var pickerData:[String]?
    private let pickerView = UIPickerView(frame: CGRectZero)
    
    var pickerDataArray:[String]? {
        get {
            return pickerData
        } set {
            self.pickerData = newValue
            self.setPickerAsInputView()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setPickerAsInputView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        self.inputView = pickerView
        self.delegate = self
    }
    
    
    //MARK: PickerView DataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let pickerDataArray = self.pickerDataArray else {
            return 0
        }
        return pickerDataArray.count
    }
    
    //MARK: PickerView Delegate
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataArray![row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.text = pickerDataArray![row]
    }
    
    
    
    //MARK: TextField Delegate
    func textFieldDidBeginEditing(textField: UITextField) {
        let row =  self.pickerView.selectedRowInComponent(0)
        self.text = self.pickerDataArray![row]
        
    }
}

