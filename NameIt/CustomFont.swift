//
//  CustomFont.swift
//  NameIt
//
//  Created by Ranosys on 12/07/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

extension UIFont {
    
    func montserratBoldWithSize(size:Int) -> UIFont {
        
        let font:UIFont = UIFont.init(name: "Montserrat-Bold", size: CGFloat(size))!
        return font
    }
    
    func montserratRegularWithSize(size:Int) -> UIFont {
        
        let font:UIFont = UIFont.init(name: "Montserrat-Regular", size: CGFloat(size))!
        return font
    }
    func montserratLightWithSize(size:Int) -> UIFont {
        
        let font:UIFont = UIFont.init(name: "Montserrat-Light", size: CGFloat(size))!
        return font
    }
}
