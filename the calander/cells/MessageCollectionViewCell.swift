//  MessageCollectionViewCell.swift
//  the calander
//
//  Created by amitay levi on 06/07/2019.
//  Copyright © 2019 amitay levi. All rights reserved.
//

import UIKit

class MessageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var writer: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var time: UILabel!
    
    func populate(message:Message){
        writer.text = message.writer
        content.text = message.content
        dateLabel.text = message.date
        time.text = message.time
    }
    override func layoutSubviews() {
//        content.sizeToFit()
//        mView.sizeToFit()
    }
    
}
