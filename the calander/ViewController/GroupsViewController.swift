//
//  GroupsViewController.swift
//  the calander
//
//  Created by amitay levi on 29/06/2019.
//  Copyright © 2019 amitay levi. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseDatabase


//TODO:why its duble when i add a group
class GroupsViewController: UIViewController{
  
    @IBOutlet weak var tableView: UITableView!
    
    var groupsList = [Group]()
    let bgImage = #imageLiteral(resourceName: "bgTill")
    static var groupId:String?
    var uid:String?

    
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: ", signOutError)
        }
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        present(vc, animated: true)

        
    }
    

    func  readData() {
        let ref = DAO.shared.ref
        var contacts = [Contact]()
        var antiDuplicate = [String]()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.uid = uid
        ref.child("Users").child(uid).child("groups").observe(.value) { (uSnap) in

        antiDuplicate.removeAll()
        self.groupsList.removeAll()
        self.tableView.reloadData()

            for k in uSnap.children{
                if let k = k as? DataSnapshot{
                    let key  = k.key
                    ref.child("groups").queryOrderedByKey().queryEqual(toValue: key).observeSingleEvent(of: .value, with: { (gSnap) in
                        for child in gSnap.children{
                            if let g = child as? DataSnapshot,
                                let dict = g.value as? [String:Any],
                                let name = dict["name"] as? String,
                                let picture = dict["picture"] as? String,
                                let contactDict = dict["contacts"] as? [String:Any]{
                                contacts.removeAll()
                                for c in contactDict{
                                    if let contact = c.value as? [String:Any],
                                        let gName = contact["firstName"] as? String,
                                        let fName = contact["lastName"] as? String,
                                        let phone = contact["phoneNumber"] as? String{
                                        contacts.append(Contact(groups: nil, id: nil, givenName: gName, familyName: fName, phoneNumber: phone))
                                    }
                                }
                                
                                let mGroup = Group(id: key, name: name, picture: picture, contacts: contacts, manager: nil, events: nil, messages: nil)
                                if !antiDuplicate.contains(key){
                                    antiDuplicate.append(key)
                                    self.groupsList.insert(mGroup, at: 0)
                                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        if Auth.auth().currentUser == nil{ //TODO: check before the view load maybe in splash screen
            let registerVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "registerNavigationVC") as! UINavigationController

            present(registerVc, animated: true, completion: nil)
        }
        
        
        view.backgroundColor = UIColor(patternImage: bgImage)
        
        self.tableView.tableFooterView = UIView()

        readData()
        childRemoved()
       
       
        
    }
    
    func childRemoved(){
        DAO.shared.ref.child("Users/\(uid!)/groups").observe(.childRemoved) { (snap) in
            self.groupsList.removeAll()
            self.tableView.reloadData()
            self.readData()
        }
    }
    
    @IBAction func unwindToGroups(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
   

}

extension GroupsViewController :  UITableViewDelegate,UITableViewDataSource{
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsList.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupTableViewCell
        
        cell.populate(with: groupsList[indexPath.row])
       


        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       GroupsViewController.groupId = groupsList[indexPath.row].id
        let vc = storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        present(vc, animated: true)
        
    }
    
    
}



