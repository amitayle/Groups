//
//  addEventViewController.swift
//  the calander
//
//  Created by amitay levi on 08/07/2019.
//  Copyright © 2019 amitay levi. All rights reserved.
//

import UIKit
import FirebaseAuth

class addEventViewController: UIViewController {
    
    

    @IBOutlet weak var details: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var titleTF: UITextField!
    
    var dates = [String]() // TODO: fill the arrray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .overCurrentContext

        details.layer.borderWidth = 0.4
        details.layer.borderColor = UIColor.lightGray.cgColor
        details.layer.cornerRadius = 5
        details.delegate = self
        details.text = "Enter event details"
        details.textColor = UIColor(red:0.84, green:0.84, blue:0.84, alpha:1.0)

        datePicker.datePickerMode = .date
    }
    
    @IBAction func Done(_ sender: UIButton) {
         let date = datePicker.date
        guard !dates.contains(String(date: date))else{
                    presentAlert(title: "Error", message: "The date you selected is already occupied", actions: nil)
                    return
        }

        guard let title = titleTF.text, !title.isEmpty else{
            presentAlert(title: nil, message: "Enter title", actions: nil)
            return
        }
        var mDetails:String{
            if details.text == "" || details.text == "Enter event details"{
                return ""
            }
            else {
                return details.text
            }
        }
        let user = Auth.auth().currentUser
        let writer = user?.displayName
        let uid = user?.uid
        
        let eventDict = ["date":String(date: date),
                         "title":title,
                         "details":mDetails,
                         "writer":writer,
                         "uid":uid,
                         "isSeen":"false"]
        guard let groupId = GroupsViewController.groupId else{
            presentAlert(title: "Erorr", message: "somthing happend. please try again", actions: nil)
            return
        
        }
        let path = "events/\(groupId)"
        DAO.shared.ref.child(path).childByAutoId().setValue(eventDict) { (err, _) in
            if err == nil{
               self.dates.append(String(date: date))
            }
        }
        
        dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }

}
extension addEventViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(red:0.84, green:0.84, blue:0.84, alpha:1.0){
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            details.text = "Enter event details"
            details.textColor = UIColor.lightGray
        }
    }
}
