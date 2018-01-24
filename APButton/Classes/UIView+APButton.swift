//
//  UIView+APButton.swift
//  APButton
//
//  Created by Anton Plebanovich on 8/2/17.
//  Copyright © 2017 Anton Plebanovich. All rights reserved.
//

import UIKit


private var defaultAlphaAssociationKey = 0
private var defaultIsHiddenAssociationKey = 0


extension UIView {
    private var defaultAlpha: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &defaultAlphaAssociationKey) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &defaultAlphaAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var ap_highlighted: Bool {
        get {
            return defaultAlpha != nil
        }
        set {
            guard newValue != ap_highlighted else { return }
            
            if newValue {
                defaultAlpha = alpha
                alpha = alpha * g_ButtonHighlightAlphaCoef
            } else {
                if let defaultAlpha = defaultAlpha {
                    // Check if alpha did not changed
                    // Changed alpha indicates that something else took control over alpha so better to not interupt it
                    if _g_isCGFloatsEqual(first: alpha, second: defaultAlpha * g_ButtonHighlightAlphaCoef) {
                        alpha = defaultAlpha
                    }
                    self.defaultAlpha = nil
                }
            }
        }
    }
    
    private var defaultIsHidden: Bool? {
        get {
            return objc_getAssociatedObject(self, &defaultIsHiddenAssociationKey) as? Bool
        }
        set {
            objc_setAssociatedObject(self, &defaultIsHiddenAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var ap_isHidden: Bool {
        get {
            return isHidden
        }
        set {
            guard newValue != isHidden else { return }
            
            if newValue {
                defaultIsHidden = isHidden
                isHidden = true
            } else {
                if let defaultIsHidden = defaultIsHidden {
                    isHidden = defaultIsHidden
                    self.defaultIsHidden = nil
                }
            }
        }
    }
}
