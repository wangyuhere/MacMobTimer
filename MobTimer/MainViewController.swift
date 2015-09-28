//
//  MainViewController.swift
//  MobTimer
//
//  Created by Yu Wang on 25/09/15.
//  Copyright © 2015 Yu Wang. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    @IBOutlet weak var timerDisplay: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        timerDisplay.stringValue = "Hello World"
    }
    
}
