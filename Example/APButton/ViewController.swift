//
//  ViewController.swift
//  APButton
//
//  Created by Anton Plebanovich on 07/11/2017.
//  Copyright (c) 2017 Anton Plebanovich. All rights reserved.
//

import UIKit
import APButton


class ViewController: UIViewController {
    
    //-----------------------------------------------------------------------------
    // MARK: - @IBActions
    //-----------------------------------------------------------------------------
    
    @IBAction private func onActivityTap(_ sender: APButton) {
        sender.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { 
            sender.stopAnimating()
        }
    }
}
