//
//  AnnotationTypeViewController.swift
//  FlickVisitR
//
//  Created by Michelle Grover on 8/15/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import UIKit

class AnnotationTypeViewController: UIViewController {
    
    
    
    @IBOutlet weak var addressTextFieldOutlet: UITextField!
    @IBOutlet weak var errorLabelOutlet: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressTextFieldOutlet.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addressTextFieldOutlet.becomeFirstResponder()
        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    
    
}

extension AnnotationTypeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addressTextFieldOutlet.resignFirstResponder()
        return true
    }
    
    
    
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {

        if (textField.text == "1810") {
            errorLabelOutlet.text = "There was an error"
            return
        } else {
            errorLabelOutlet.text = ""
            navigationController?.popViewController(animated: true)
        }
       
    }
}


