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
    
    @IBAction private func onProgressTap(_ sender: APButton) {
        sender.startAnimating()
        
        let endDate = Date(timeIntervalSinceNow: 5)
        if #available(iOS 10.0, *) {
            _ = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                let progress = CGFloat((5 - endDate.timeIntervalSinceNow) / 5)
                sender.progress = progress
                
                if Date() > endDate {
                    timer.invalidate()
                    sender.stopAnimating()
                    sender.progress = 0
                }
            }
        }
    }
    
    //-----------------------------------------------------------------------------
    // MARK: - Private Properties
    //-----------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------
    // MARK: - Actions
    //-----------------------------------------------------------------------------
}
