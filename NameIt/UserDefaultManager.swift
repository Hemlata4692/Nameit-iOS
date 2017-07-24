//
//  UserDefaultManager.swift
//  NameIt
//
//  Created by Ranosys on 06/07/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class UserDefaultManager: NSObject {
    
    func setValue(value:AnyObject, keyText key:NSString) {
        
        UserDefaults.standard.set(value, forKey: key as String)
        UserDefaults.standard.synchronize()
    }
    
    func getValue(key:NSString) -> AnyObject? {
        
        return UserDefaults.standard.object(forKey: key as String) as AnyObject
    }
    
    func removeValue(key:NSString) {
        
        UserDefaults.standard.removeObject(forKey: key as String)
    }
}
