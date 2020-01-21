//
//  ShowMessageViewController.swift
//  the calander
//
//  Created by amitay levi on 25/07/2019.
//  Copyright © 2019 amitay levi. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class ShowMessageViewController: UIViewController {
    
    var comments = [Comment]()
    var name:String?
    var date:String?
    var content:String?
    var messageId:String?
    var groupId:String?
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var commentTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBorder()
        getId()
        nameLabel.text = name
        dateLabel.text = date
        contentLabel.text = content
        readComments()
    }
    
    func setBorder(){
        mView.layer.borderWidth = 4
        mView.layer.borderColor = UIColor(red:0.29, green:0.58, blue:0.91, alpha:1.0).cgColor
        mView.layer.cornerRadius = 4
    }
    func getId(){
        if let groupId = GroupsViewController.groupId ,
            messageId != nil{
            self.groupId = groupId
        } else {
            presentAlert(title: "Erorr", message: "somthing happend. please try again", actions: nil)
            return
        }
        
    }
    
    @IBAction func addComment(_ sender: UIButton) {
        
        
        let path = "messages/\(groupId!)/\(messageId!)/comments"
        guard let comment = commentTF.text , !comment.isEmpty else {return}
       
        let commentDict = ["writer":Auth.auth().currentUser?.displayName ?? "" ,
                           "content":comment,
                           "time": getCurrentTime()]
        DAO.shared.writeByAutoId(path: path, value: commentDict)
        commentTF.text = ""
    }
    
    func getCurrentTime() -> String {
        let component = Calendar.current.dateComponents([.hour,.minute], from: Date())
        
        let hour = component.hour
        let minute = component.minute
        
        if minute! < 10 {
            return String("\(hour!):0\(minute!)")
        }
        return String("\(hour!):\(minute!)")
        
    }
    
    func readComments(){
        let commentRef = DAO.shared.ref.child("messages").child(groupId!).child(messageId!).child("comments")
        commentRef.observe(.value) { (snap) in
            self.comments.removeAll()
            for child in snap.children{
                if let childSnap = child as? DataSnapshot,
                    let dict = childSnap.value as? NSDictionary,
                    let writer = dict["writer"] as? String,
                    let content = dict["content"] as? String,
                    let time = dict["time"] as? String{
                    self.comments.append(Comment(writer: writer, content: content, time: time))
                }
            }
            self.commentTableView.reloadData()
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
        dismiss(animated: true )
    }

}
extension ShowMessageViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "commentCell")
        let index = comments[indexPath.row]
        let comment = "\(index.writer): \(index.content)"
        
        let range = NSRange(location:0,length:index.writer.count + 2)
        let MAS = NSMutableAttributedString(string: comment)
        MAS.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Georgia", size: 18.0), range: range )
        MAS.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range)

        cell.textLabel?.attributedText = MAS
        
        return cell
    }
    
    
}
