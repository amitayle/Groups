//
//  GroupTableViewCell.swift
//  the calander
//
//  Created by amitay levi on 29/06/2019.
//  Copyright © 2019 amitay levi. All rights reserved.
//

import UIKit
import SDWebImage

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var groupMembers: UILabel!
    @IBOutlet weak var groupTitle: UILabel!
    @IBOutlet weak var groupPic: UIImageView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func populate(with mGroup: Group)  {

        groupPic.sd_setImage(with: URL(string: mGroup.picture ?? ""), placeholderImage: UIImage(named: "group-icon")?.circleMasked)
        groupPic.layer.cornerRadius = groupPic.frame.width / 2
        
        groupTitle.text =   mGroup.name
        var contacts:String{
            var contactsName = [String]()
            for c in mGroup.contacts{
                contactsName.append(c.givenName)
            }
           return contactsName.joined(separator: ",")
        }
        groupMembers.text = contacts
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
