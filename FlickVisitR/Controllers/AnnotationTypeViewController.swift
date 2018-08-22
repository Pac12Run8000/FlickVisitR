//
//  AnnotationTypeViewController.swift
//  FlickVisitR
//
//  Created by Michelle Grover on 8/15/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit

//protocol MemeGeneratorViewControllerDelegate:class {
//
//    func memeGeneratorViewControllerDidCancel(_ controller:MemeGeneratorViewController)
//    func memeGeneratorViewController(_ controller:MemeGeneratorViewController, didFinishAdding item:(topText: String, bottomText: String, originalImage: NSData, memedImage: NSData))
//    func memeGeneratorViewController(_ controller:MemeGeneratorViewController, didFinishEditing item:MemeObj)
//
//}

protocol AnnotationTypeViewControllerDelegate:class {
    func annotationTypeViewController(_ controller:AnnotationTypeViewController, didFinishAdding item:CLLocationCoordinate2D)
}

class AnnotationTypeViewController: UIViewController {
    
    var geocoder = CLGeocoder()
    var coordinate:CLLocationCoordinate2D!
    
    weak var annotationTypeDelegate:AnnotationTypeViewControllerDelegate?
    
    @IBOutlet weak var addressTextFieldOutlet: UITextField!
    @IBOutlet weak var errorLabelOutlet: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressTextFieldOutlet.delegate = self
        configureTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addressTextFieldOutlet.becomeFirstResponder()
        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resignResponderOnTap))
        view.addGestureRecognizer(tapGesture)
    }

    
    
}

extension AnnotationTypeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        addressTextFieldOutlet.resignFirstResponder()
        shouldPopViewController(textField)
        
        return true
    }
    
    @objc func resignResponderOnTap() {
        view.endEditing(true)
    }
    
    func shouldPopViewController(_ textField:UITextField) {

        
        if let address = addressTextFieldOutlet.text {
            geocoder.geocodeAddressString(address) { (placemarks, error) in
                
                if error != nil {
                    self.errorLabelOutlet.text = "\(String(describing: error!.localizedDescription))"
                }
                
                var location:CLLocation?
                
                if let placemarks = placemarks, placemarks.count > 0 {
                    location = placemarks.first?.location
                }
                
                if let location = location {
                    
                    self.coordinate = location.coordinate
                    self.annotationTypeDelegate?.annotationTypeViewController(self, didFinishAdding: self.coordinate)
                    self.navigationController?.popViewController(animated: true)
                    
                }
                
            
            }
        }
        
        
//        if (textField.text == "1810") {
//            errorLabelOutlet.text = "There was an error"
//        } else {
//            errorLabelOutlet.text = ""
//            navigationController?.popViewController(animated: true)
//        }
    }

}





