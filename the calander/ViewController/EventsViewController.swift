//
//  EventsViewController.swift
//  the calander
//
//  Created by amitay levi on 08/07/2019.
//  Copyright © 2019 amitay levi. All rights reserved.
//

import UIKit
import FSCalendar
import Firebase


class EventsViewController: UIViewController {
    
    var groupId:String?
    
    let bgImage = #imageLiteral(resourceName: "bgTill")
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDetails: UILabel!
    @IBOutlet weak var eventWriter: UILabel!
    @IBOutlet weak var addCommentTF: UITextField!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    var events = [String:Event]()
    var eventId:String?
    var sDate:String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: bgImage)
        
        groupId = GroupsViewController.groupId
        readEvents()
        
    }
    

    
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func addEvent(_ sender: UIBarButtonItem) {
        let popUp = PopUpService().addEventPopUp()
        var dates = [String]()
        for d in events.keys {
            dates.append(d)
        }
        popUp.dates = dates
        present(popUp, animated: true)
        
    }
    
    @IBAction func sendComment(_ sender: UIButton) {
        guard groupId != nil, eventId != nil else {
            presentAlert(title: "Erorr", message: "somthing happend. please try again", actions: nil)
            return
        }
        
        let path = "events/\(groupId!)/\(eventId!)/comments"
        guard let content = addCommentTF.text , !content.isEmpty else {return}
        
        let writer = Auth.auth().currentUser?.displayName ?? ""
         let time = getCurrentTime()
        let commentDict = ["writer":writer ,
                           "content":content,
                           "time":time]
       
        DAO.shared.writeByAutoId(path: path, value: commentDict)
        addCommentTF.text = ""
        let comment = Comment(writer: writer, content: content, time: time)
        events[sDate!]?.comments.insert(comment, at: 0)
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
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
    
    
    func readEvents(){
        let eventRef = DAO.shared.ref.child("events").child(groupId!)
        
        eventRef.observe(.value) { (snap) in
            self.events.removeAll()
            for child in snap.children{
                if let snapChild = child as? DataSnapshot,
                    let dict = snapChild.value as? NSDictionary,
                    let date = dict["date"] as? String,
                    let title = dict["title"] as? String,
                    let details = dict["details"] as? String,
                    let writer = dict["writer"] as? String,
                    let uid = dict["uid"] as? String,
                    let isSeen = dict["isSeen"] as? String{
                    
                        var comments = [Comment]()
                        if let commentsDict = dict["comments"] as? NSDictionary{
                            comments.removeAll()
                            for (_,c) in commentsDict{
                                if let comment = c as? NSDictionary,
                                    let writer = comment["writer"] as? String,
                                    let content = comment["content"] as? String,
                                    let time = comment["time"] as? String{
                                    comments.append(Comment(writer: writer, content: content, time: time))
                                }
                            }
                        }
                    let id = snapChild.key
                    let event = Event(id: id, date:date, title: title, details: details, comments: comments, writer: writer, uid: uid, isSeen: isSeen.bool)
                    self.events[date] = event
                
                }
            }
            self.calendar.reloadData()
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
extension EventsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sDate != nil, let event = events[sDate!]{
            return event.comments.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "commentCell")
        
        if sDate != nil, let event = events[sDate!]{
            
            let index = event.comments[indexPath.row]
            let comment = "\(index.writer): \(index.content)"
           
            
            let range = NSRange(location:0,length:index.writer.count + 2)
            let MAS = NSMutableAttributedString(string: comment)
            MAS.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Georgia", size: 18.0), range: range )
            MAS.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range)
            MAS.addAttribute( NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize), range: range)
            
            cell.textLabel?.attributedText = MAS
        }
        
        return cell
    }
}
extension EventsViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
       
        let sDate = String(date: date)
        if events.keys.contains(sDate){
            let event = events[sDate]
            eventTitle.text = event?.title
            eventDetails.text = event?.details
            eventWriter.text = event?.writer
            self.eventId = event?.id
            self.sDate = sDate
            
        }else{
            eventTitle.text = ""
            eventDetails.text = ""
            eventWriter.text = ""
            self.sDate = nil
        }
       tableView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        let date =  String(date: date)
        if events.keys.contains(date) {
            return UIColor.blue
        }else{
            return UIColor.white
        }
    }
}


