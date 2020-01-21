//
//  addMessageViewController.swift
//  the calander
//
//  Created by amitay levi on 17/07/2019.
//  Copyright © 2019 amitay levi. All rights reserved.
//

import UIKit
import FirebaseAuth

class addMessageViewController: UIViewController,UITextViewDelegate {
   
    
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var content: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        content.delegate = self
        content.text = "Type your message..."
        content.textColor = UIColor.lightGray
        
        content.layer.borderWidth = 1.5
        content.layer.borderColor = UIColor(red:0.62, green:0.62, blue:0.62, alpha:1.0).cgColor
        content.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.88, alpha:1.0)
        content.layer.cornerRadius = 4
        
        mainView.layer.borderColor = UIColor(red:0.62, green:0.62, blue:0.62, alpha:1.0).cgColor
        mainView.layer.borderWidth = 0.2
        mainView.layer.cornerRadius = 20
        mainView.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.94, alpha:1.0)
        
        doneBtn.layer.cornerRadius = 4
        
        
    }
    

    @IBAction func done(_ sender: UIButton) {
        guard let content = content.text, content != "Type your message...", !content.isEmpty else {
            presentAlert(title: nil, message: "please enter content", actions: nil)
            return
        }
        let date = String(date: Date())
        var time:String{
            let date = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            
            if minute < 10 {
                return String("\(hour):0\(minute)")
            }
            return "\(hour):\(minute)"
        }
        let writer = Auth.auth().currentUser?.displayName
        let messageDict = ["date":date,
                           "time":time,
                           "content":content,
                           "writer":writer,
                           "isSeen":"false"]
        
        guard  let groupId = GroupsViewController.groupId else {
            presentAlert(title: "Erorr", message: "somthing happend. please try again", actions: nil)
            return
        }
        
        let path = "messages/\(groupId)"
        let key = DAO.shared.writeByAutoId(path: path , value: messageDict)
//        let IDpath = "groups/\(groupId)/messages"
//        DAO.shared.ref.child(IDpath).child(key!).setValue("true")
        dismiss(animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if content.textColor == UIColor.lightGray{
            content.text = nil
            content.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if content.text.isEmpty{
            content.text = "Type your message"
            content.textColor = UIColor.lightGray
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
}

