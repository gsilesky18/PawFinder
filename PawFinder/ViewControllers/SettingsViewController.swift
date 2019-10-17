//
//  SettingsViewController.swift
//  PawFinder
//
//  Created by Greg Silesky on 10/15/19.
//  Copyright © 2019 Greg Silesky. All rights reserved.
//

import UIKit
import Siesta

class SettingsViewController: UIViewController {

    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchButton: UIButton!
    
    //Used to determine if the user changed any preferences
    var isDirty: Bool = false
    
    var userDefaults: UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set segment control with stored preference
        let animalType = AnimalType(rawValue: userDefaults.string(forKey: "type") ?? "dog")
        typeSegmentedControl.selectedSegmentIndex = animalType == AnimalType.dog ? 0 : 1

        //Setup tap gesture to dismiss view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        zipCodeTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        zipCodeTextField.resignFirstResponder()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func typeSegmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            userDefaults.set(AnimalType.dog.rawValue, forKey: "type")
        }else if sender.selectedSegmentIndex == 1 {
            userDefaults.set(AnimalType.cat.rawValue, forKey: "type")
        }
        isDirty = true
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        if let zipCode = zipCodeTextField.text, isValid(zipCode: zipCode){
            userDefaults.set(zipCode, forKey: "zipCode")
            isDirty = true
            dismissViewController()
        }else if isDirty {
            dismissViewController()
        }else{
            showAlertView(message: "Please enter a 5 digit zip code.")
        }
    }
}

// MARK: - Private Methods
private extension SettingsViewController {
    
    func showAlertView(message: String){
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func isValid(zipCode: String) -> Bool {
        //Simple 5 digit check
        if NSPredicate(format: "SELF MATCHES %@", "\\d{5}").evaluate(with: zipCode) {
            return true
        }
        return false
    }
    
    @objc func dismissViewController() {
        //Force user to enter a zip code
        //PetFinder Api is very slow without a zip code
        if let zipCode = userDefaults.string(forKey: "zipCode"), !zipCode.isEmpty {
            performSegue(withIdentifier: "unwindToMainViewController", sender: nil)
        }else{
            showAlertView(message: "Please search for a zip code before closing.")
        }
    }
}
