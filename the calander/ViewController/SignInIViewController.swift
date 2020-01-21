//
//  SignInIViewController.swift
//  the calander
//
//  Created by amitay levi on 04/09/2019.
//  Copyright © 2019 amitay levi. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInIViewController: UIViewController {
    @IBOutlet weak var verificationCode: UITextField!
    var firstName:String?
    var lastName:String?
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneTaped(_ sender: UIButton) {
        guard let verificationId = UserDefaults.standard.string(forKey: "verificationId") else {
            presentAlert(title: "Erorr", message: "Plase try register again.", actions: nil)
            return
        }
        
        guard let verificationCode = verificationCode.text, !verificationCode.isEmpty else {
            presentAlert(title: nil, message: "Plase enter the code.", actions: nil)
            return
        }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { (AuthDataResult, err) in
            if err != nil{
                self.presentAlert(title: "Registration failed", message: "Plase try again.", actions: nil)
                return
            }
        }
        let auth = Auth.auth().currentUser
        if auth != nil{
            let phone = auth!.phoneNumber
            let uid = auth!.uid
            let userDict = ["uid":uid,
                            "phoneNumber":phone,
                            "firstName":firstName,
                            "lastName":lastName]
            DAO.shared.write(path: "Users/\(uid)", value: userDict)
            
            DAO.shared.ref.child("usersPhone").child(phone ?? "").setValue(uid)
          
            let changeRequest = auth?.createProfileChangeRequest()
            changeRequest?.displayName = firstName
            changeRequest?.commitChanges { (error) in
                print(error)
            }
            
//            dismiss(animated: true, completion: nil)
            performSegue(withIdentifier: "unwindToGroupsFromSign", sender: self)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
