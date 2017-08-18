//
//  UserDefaultManager.swift
//  NameIt
//
//  Created by Ranosys on 06/07/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class UserDefaultManager: NSObject {
    
    // MARK: - Set value in userDefault
    func setValue(value:AnyObject, keyText key:NSString) {
        UserDefaults.standard.set(value, forKey: key as String)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Get value from userDefault
    func getValue(key:NSString) -> AnyObject? {
        return UserDefaults.standard.object(forKey: key as String) as AnyObject
    }
    
    // MARK: - Remove value from userDefault
    func removeValue(key:NSString) {
        UserDefaults.standard.removeObject(forKey: key as String)
    }
}
