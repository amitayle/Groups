//
//  DAO.swift
//  the calander
//
//  Created by amitay levi on 02/07/2019.
//  Copyright © 2019 amitay levi. All rights reserved.
//

import Foundation
import FirebaseDatabase



class DAO {
    let ref = Database.database().reference()

    static let shared = DAO()
   
    private init(){}
    
    func writeByAutoId(path:String, value:[String:Any]) -> String?{
        let p = ref.child(path).childByAutoId()
            let key = p.key
                p.setValue(value)
        return key
    }
    func write(path:String, value:[String:Any]){
        ref.child(path).setValue(value)
    }
    func write(path:String, value:String){
        ref.child(path).setValue(value)
    }
    func read(path:String) -> String {
       return ""
    }
    func update( value:[String:Any]) {
        ref.updateChildValues(value)
    }

    
    
    
}
