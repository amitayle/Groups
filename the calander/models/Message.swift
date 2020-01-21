//
//  Message.swift
//  the calander
//
//  Created by amitay levi on 29/06/2019.
//  Copyright © 2019 amitay levi. All rights reserved.
//

import UIKit

struct Message{

    let id:String
    let date: String
    let time:String
    let content: String
    let comments: [Comment]?
    let writer: String
    let isSeen: Bool
}
