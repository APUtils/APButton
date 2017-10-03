//
//  Utils.swift
//  APButton
//
//  Created by Anton Plebanovich on 10/4/17.
//  Copyright © 2017 Anton Plebanovich. All rights reserved.
//

import Foundation


/// Executes a closure if already in main or dispatch asyn in main. Uses GCD.
/// - parameters:
///   - closure: the closure to be executed
func _g_performInMain(_ closure: @escaping () -> ()) {
    if !Thread.isMainThread {
        DispatchQueue.main.async {
            closure()
        }
    } else {
        closure()
    }
}
