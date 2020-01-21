//
//  DetailsViewController.swift
//  the calander
//
//  Created by amitay levi on 02/07/2019.
//  Copyright © 2019 amitay levi. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SDWebImage
import ContactsUI
import FirebaseAuth

class DetailsViewController: UIViewController {
    var groupId:String?
    
    let contactsVc = CNContactPickerViewController()
    

    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var contactsTableView: UITableView!
    
    let bgImage = #imageLiteral(resourceName: "bgTill")
    
    var groupNames = [String]()
    var groupPhoneNumbers = [String]()
    var phoneNumbers = [String:Any]()
    
   
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //get the group id
        groupId = GroupsViewController.groupId

//        groupImage.layer.cornerRadius = groupImage.frame.width / 2
        
        view.backgroundColor = UIColor(patternImage: bgImage)
        readDb()
        getAllPhoneNumbers()
        
        
    }
    func readDb(){
        let ref = DAO.shared.ref.child("groups").child(groupId!)
        
        ref.observe(.value) { (snap) in
            
            guard let dict = snap.value as? [String:Any],
                let name = dict["name"] as? String,
                let picture = dict["picture"] as? String,
                let contactsDict = dict["contacts"] as? [String:[String:Any]] else {print("err");return}
            self.groupNames.removeAll()
            for (_,contact) in contactsDict{
                if let fName = contact["firstName"] as? String,
                    let lName = contact["lastName"] as? String,
                    let phone = contact["phoneNumber"] as? String{
                    let fullName = "\(fName) \(lName)"
                    self.groupNames.append(fullName)
                    self.groupPhoneNumbers.append(phone)
                }
            }
            self.groupImage.sd_setImage(with: URL(string: picture), placeholderImage: UIImage(named: "group-icon")?.circleMasked)
            
            self.groupName.text = name
//            self.contactsTableView.reloadData()
        }

    }
    
    
    @IBAction func addMembers(_ sender: UIBarButtonItem) {
        contactsVc.delegate = self
        present(contactsVc, animated: true)
        
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
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

}
extension DetailsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupNames.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == groupNames.count {
            let leave = tableView.dequeueReusableCell(withIdentifier: "leave") as! UITableViewCell
            leave.textLabel?.text = "leave group"
            leave.textLabel?.textColor = UIColor.red

            
            return leave
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell" ) as! UITableViewCell
            
            cell.textLabel?.text = groupNames[indexPath.row]
            
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == groupNames.count {
            let alert = UIAlertController(title: "leave group", message: "are you sure you want to leave this group?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (yes) in
                guard let uid = Auth.auth().currentUser?.uid else{return}
                DAO.shared.ref.child("Users/\(uid)/groups/\(self.groupId!)").removeValue()
                DAO.shared.ref.child("groups/\(self.groupId!)/contacts/\(uid)").removeValue(completionBlock: { (err, _) in
                    if err == nil{
                        self.performSegue(withIdentifier: "unwindToGroups", sender: self)

                    }
                })

            }
            let noActoin = UIAlertAction(title: "No", style: .cancel) { (no) in
               alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(yesAction)
            alert.addAction(noActoin)
            self.present(alert, animated: true, completion: nil)

        }
    }
    
}

extension DetailsViewController: CNContactPickerDelegate{
    func getAllPhoneNumbers() {
        
        DAO.shared.ref.child("usersPhone").observeSingleEvent(of: .value) { (snap) in
            if let dict = snap.value as? [String:Any]{
                self.phoneNumbers = dict
                    
                
            }
        }
    }
  
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        for c in contacts{
            
            let contactNumber = c.phoneNumbers.first?.value.stringValue ?? ""
            let clearNumber = contactNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
           
            if phoneNumbers.keys.contains(clearNumber), !groupPhoneNumbers.contains(clearNumber){
                let key = String(describing: phoneNumbers[clearNumber]!)
               
                DAO.shared.ref.child("Users").child(key).observeSingleEvent(of: .value) { (snap) in
                    if let userDict = snap.value as?[String:Any]{
                        
                        let path = "groups/\(self.groupId!)/contacts"
                        DAO.shared.writeByAutoId(path: path, value: userDict)
                        
                        DAO.shared.ref.child("Users/\(key)/groups").child(self.groupId!).setValue(true)
                    }
                }
            }
        }
    }
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
}

