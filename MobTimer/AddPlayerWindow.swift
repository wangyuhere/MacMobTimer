//
//  AddPlayerWindow.swift
//  MobTimer
//
//  Created by Yu Wang on 06/10/15.
//  Copyright © 2015 Yu Wang. All rights reserved.
//

import Cocoa
import Carbon

class AddPlayerWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var playerName: NSTextField!
    @IBOutlet weak var keyboardSelector: NSPopUpButton!

    var name = ""
    var keyboard = ""

    override func windowDidLoad() {
        super.windowDidLoad()

        initKeyboardSelector()
    }

    func windowWillClose(notification: NSNotification) {
        NSApp.stopModal()
    }

    @IBAction func addPlayer(sender: AnyObject) {
        name = playerName.stringValue
        if name.isEmpty {
            return
        }
        keyboard = keyboardSelector.selectedItem!.title
        
        window?.close()
    }

    @IBAction func cancel(sender: AnyObject) {
        name = ""
        keyboard = ""
        window?.close()
    }

    func initKeyboardSelector() {
        keyboardSelector.removeAllItems()
        let allInputs = TISCreateInputSourceList(nil, false).takeRetainedValue()
        let count = CFArrayGetCount(allInputs)

        for (var i = 0; i < count; i++) {
            let source = unsafeBitCast(CFArrayGetValueAtIndex(allInputs, i), TISInputSource.self)
            let sourceLang = unsafeBitCast(TISGetInputSourceProperty(source, kTISPropertyLocalizedName), NSString.self) as String
            keyboardSelector.addItemWithTitle(sourceLang)
        }
    }
}
