//
//  NewGroupViewController.swift
//  the calander
//
//  Created by amitay levi on 23/08/2019.
//  Copyright © 2019 amitay levi. All rights reserved.
//

import UIKit
import ContactsUI
import FirebaseStorage
import FirebaseAuth


//TODO: conect to add from detailsViewController
class NewGroupViewController: UIViewController {
    
    let contactVc = CNContactPickerViewController()
    let imagePicker = UIImagePickerController()
    
    let bgImg = #imageLiteral(resourceName: "bgTill")
    
    var usersDict = [String:[String:Any]]()
    var usersPhones = [String:Any]()
    var newContactsPhones = [String]()
    var groupImage:UIImage?
    var groupImageUrl:String?

    @IBOutlet weak var groupNameTF: UITextField!
    @IBOutlet weak var addImage: UIButton!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactVc.delegate = self
        imagePicker.delegate = self
        
        getAllPhoneNumbers()
        

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(patternImage: bgImg)
        addImage.layer.cornerRadius = addImage.frame.height / 2
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: UIButton) {
        present(contactVc, animated: true )
       
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func writeGroupToFB() {
        
        var contactsDict = [String:Any]()
        newContactsPhones.append( Auth.auth().currentUser?.phoneNumber ?? "")
        for p in newContactsPhones{
            let uId = usersPhones[p] as! String
            let firstName = usersDict[uId]?["firstName"]
            let lastName = usersDict[uId]?["lastName"]
            
            let dict = ["firstName": firstName,
                        "lastName": lastName,
                        "phoneNumber": p,
                        "uid":uId] as [String : Any]
            
            contactsDict[uId] = dict
        }
        let groupDict:[String:Any] = ["name" : groupNameTF.text,
                                      "picture" : groupImageUrl ?? "",
                                      "contacts" : contactsDict]
        if groupNameTF.text != "" , newContactsPhones.count > 1 {
            let groupKey = DAO.shared.writeByAutoId(path: "groups", value: groupDict)
            DAO.shared.ref.child("Users/\(Auth.auth().currentUser!.uid)/groups").child(groupKey!).setValue( "true")
            
            for (key,v) in contactsDict{
                DAO.shared.ref.child("Users/\(key)/groups").child(groupKey!).setValue(true)
            }
        }
    }
    
    func saveImageToFB(){
        
        guard let img = groupImage, let data = img.jpegData(compressionQuality: 0.1) else{return}
        
        let imageName = UUID().uuidString
        let imageRef = Storage.storage().reference().child("images").child(imageName)
        
        imageRef.putData(data, metadata: nil) { (metaData, err) in
            if err != nil{
                print(err.debugDescription)
                return
            }
            imageRef.downloadURL { (url, err) in
                
                guard let url = url else{
                    print("erorrrrrrrrr",err.debugDescription); return}
                let stringUrl = url.absoluteString
                
                self.groupImageUrl = stringUrl
                
                self.writeGroupToFB()

            }
        }
        
        
    }

}
extension NewGroupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            self.groupImage = img.circleMasked
            self.addImage.setImage(groupImage, for: UIControl.State.normal)
            dismiss(animated: true)
            
        }
        
    }
    
}
extension NewGroupViewController:CNContactPickerDelegate{
    
    func getAllPhoneNumbers() {
       
        DAO.shared.ref.child("usersPhone").observeSingleEvent(of: .value) { (snap) in
            if let dict = snap.value as? [String:Any]{
               self.usersPhones = dict
            }
        }
        DAO.shared.ref.child("Users").observeSingleEvent(of: .value) { (snap) in
            if let dict = snap.value as? [String:Any]{
                self.usersDict = dict as! [String : [String:Any]]
            }
        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        for c in contacts{
            let contactNumber = c.phoneNumbers.first?.value.stringValue ?? ""
            let clearNumber = contactNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
           
            if usersPhones.keys.contains(clearNumber){
                self.newContactsPhones.append(clearNumber)
            }else{
                print("mmmm")
                presentAlert(title: nil, message: "the contact '\(c.givenName) \(c.familyName)' is no member in Groups", actions: nil)
                // TODO: FIXXX
            }
            
        }
        //check if the user pick a image or not
        if groupImage != nil{
            saveImageToFB()
        }else{
            writeGroupToFB()
        }
        


//        self.navigationController?.popToRootViewController(animated: true)
        performSegue(withIdentifier: "unwindToGroupsFromNew", sender: self)
    }
    
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        self.dismiss(animated: true)
    }
    
}

