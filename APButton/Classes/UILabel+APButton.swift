//
//  UILabel+APButton.swift
//  APButton
//
//  Created by Anton Plebanovich on 8/2/17.
//  Copyright © 2017 Anton Plebanovich. All rights reserved.
//

import UIKit


private var defaultTextColorAssociationKey = 0
private var disabledTextColorAssociationKey = 0
private var disabledAssociationKey = 0


internal extension UILabel {
    private var defaultTextColor: UIColor! {
        get {
            return objc_getAssociatedObject(self, &defaultTextColorAssociationKey) as? UIColor ?? textColor
        }
        set {
            objc_setAssociatedObject(self, &defaultTextColorAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var ap_disabledTextColor: UIColor {
        get {
            return objc_getAssociatedObject(self, &disabledTextColorAssociationKey) as? UIColor ?? textColor
        }
        set {
            objc_setAssociatedObject(self, &disabledTextColorAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var ap_disabled: Bool {
        get {
            return objc_getAssociatedObject(self, &disabledAssociationKey) as? Bool ?? false
        }
        set {
            guard newValue != ap_disabled else { return }
            
            objc_setAssociatedObject(self, &disabledAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if newValue {
                defaultTextColor = textColor
                textColor = ap_disabledTextColor
            } else {
                textColor = defaultTextColor
            }
        }
    }
}
