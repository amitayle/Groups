//
//  Event.swift
//  the calander
//
//  Created by amitay levi on 29/06/2019.
//  Copyright © 2019 amitay levi. All rights reserved.
//

import UIKit

struct Event{
    
    let id:String
    let date: String
    let title: String
    let details: String
    var comments: [Comment]
    let writer: String
    let uid: String
    let isSeen: Bool
    
}
