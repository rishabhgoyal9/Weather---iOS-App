//
//  LocationViewController.swift
//  Weather App
//
//  Created by Rishabh Goyal on 14/03/22.
//

import UIKit

protocol getLocationofUserChoice{
    func getLocation(location : String)
}

class LocationViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    
    var delegate : getLocationofUserChoice?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // to wrap words -> unlimited lines
        label.numberOfLines = 0
        
    }
    
    // MARK: -
    
    @IBAction func submitButton_pressed(_ sender: UIButton) {
        
        delegate?.getLocation(location: textField.text!)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButton_pressed(_ sender: UIButton) {
        
        // on back button pressed , go back to Weather View Controller
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
