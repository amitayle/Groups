//
//  popUpsServies.swift
//  the calander
//
//  Created by amitay levi on 08/07/2019.
//  Copyright © 2019 amitay levi. All rights reserved.
//

import UIKit

struct PopUpService {
   
    func addEventPopUp() -> addEventViewController {
        let storyBoard = UIStoryboard(name: "popUps", bundle: .main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "addEventViewController") as! addEventViewController
        
        return vc
    }
    
    func addMessagePopUp() -> addMessageViewController {
        let storyBoard = UIStoryboard(name: "popUps", bundle: .main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "addMessageViewController") as! addMessageViewController
        
        return vc
    }
    
    func showMessageContent() -> ShowMessageViewController {
        let storyBoard = UIStoryboard(name: "popUps", bundle: .main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ShowMessageViewController") as! ShowMessageViewController
        
        return vc
    }
}
