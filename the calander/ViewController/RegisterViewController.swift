//
//  RegisterViewController.swift
//  the calander
//
//  Created by amitay levi on 03/09/2019.
//  Copyright © 2019 amitay levi. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    @IBAction func register(_ sender: UIButton) {
        guard let fName = firstNameTF.text, !fName.isEmpty,
            let lName = lastNameTF.text, !lName.isEmpty else{
                presentAlert(title: nil, message: "Enter your name", actions: nil)
                return
        }
        guard let phoneNumber = phoneNumberTF.text, !phoneNumber.isEmpty else{
            self.presentAlert(title: nil, message: "Plase enter phone number.", actions: nil)
            return
        }
        
        
        Auth.auth().languageCode = "he"
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("errrrrrr:",error.localizedDescription)
                return
            }
            // Sign in using the verificationID and the code sent to the user
            UserDefaults.standard.set(verificationID, forKey: "verificationId")
            // ...
        }
        performSegue(withIdentifier: "toSignIn", sender: self)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignInIViewController{
            
            vc.firstName = firstNameTF.text
            vc.lastName = lastNameTF.text
        }
    }
}

