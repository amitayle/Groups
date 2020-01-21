//
//  BultinBoardCollectionViewController.swift
//  the calander
//
//  Created by amitay levi on 07/07/2019.
//  Copyright © 2019 amitay levi. All rights reserved.
//

import UIKit
import FirebaseDatabase

private let reuseIdentifier = "messegeCell1"

class BulletinBoardCollectionViewController: UICollectionViewController {
    var groupId:String?
    

    var messages = [Message]()
     let bgImage = #imageLiteral(resourceName: "bgTill")

    override func viewDidLoad() {
        super.viewDidLoad()
        groupId = GroupsViewController.groupId
        readMessages()
        addNavBar()

        view.backgroundColor = UIColor(patternImage: bgImage)
        
        
    }
    func addNavBar(){
        let safeArea = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 44
        let height: CGFloat = UIScreen.main.bounds.height / 20
        let navbar = UINavigationBar(frame: CGRect(x: 0, y: safeArea, width: UIScreen.main.bounds.width, height: height))
        navbar.backgroundColor = UIColor.white
        navbar.delegate = self
        navbar.backgroundColor = .clear
        
        let navItem = UINavigationItem()
        navItem.title = "message board"
        navItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addMessege))
        navItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backBtn"), style: .plain, target: self, action: #selector(back))
        
        navbar.items = [navItem]
        
        view.addSubview(navbar)
        
        collectionView?.frame = CGRect(x: 0, y: height + safeArea, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height - height))

    }
    
    @objc func back(){
        dismiss(animated: true)
    }
    
       @objc func addMessege() {
        let popUp = PopUpService().addMessagePopUp()
        present(popUp, animated: true)
    }
    
    

    
    func readMessages()  {
        let messageRef = DAO.shared.ref.child("messages").child(groupId!)
        
        messageRef.observe(.value) { (snapshot) in
            self.messages.removeAll()
            for child in snapshot.children{
                if let childSnap = child as? DataSnapshot,
                    let dict = childSnap.value as? [String:Any],
                    let writer = dict["writer"] as? String,
                    let content = dict["content"] as? String,
                    let date = dict["date"] as? String,
                    let time = dict["time"] as? String,
                    let isSeen = dict["isSeen"] as? String {
                        let id = childSnap.key
                        self.messages.append(Message(id: id, date: date, time: time,  content: content, comments: nil, writer: writer, isSeen: isSeen.bool))
                }
            }
            self.collectionView.reloadData()
        }
        
    }
    
    
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellId = ["messegeCell1","messegeCell2"]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId[indexPath.row % 2], for: indexPath) as! MessageCollectionViewCell
        
        cell.populate(message: messages[indexPath.row])
        
//        cell.content.sizeToFit()
        cell.mView.layer.borderWidth = 4
        cell.mView.layer.borderColor = UIColor(red:0.29, green:0.58, blue:0.91, alpha:1.0).cgColor
        cell.mView.layer.cornerRadius = 4
        
    
        
    
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let popUp = PopUpService().showMessageContent()
        let index = messages[indexPath.row]
        
        popUp.name = index.writer
        popUp.date =  index.date
        popUp.content = index.content
        popUp.comments = index.comments ?? []
        popUp.messageId = index.id
        
        
        present(popUp, animated: true)
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
extension BulletinBoardCollectionViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        let height = collectionView.frame.size.height / 4
        return CGSize(width: width, height: height)
    }
}
extension BulletinBoardCollectionViewController: UINavigationBarDelegate{
    
}



