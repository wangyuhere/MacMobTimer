//
//  AppDelegate.swift
//  MobTimer
//
//  Created by Yu Wang on 25/09/15.
//  Copyright © 2015 Yu Wang. All rights reserved.
//

import Cocoa
import Carbon
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var preferencesWindow: PreferencesWindowController?
    var mainViewController: MainViewController?
    var activity: NSObjectProtocol?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        appInit()
        mainViewController = MainViewController(nibName: "MainViewController", bundle: nil)
        mainViewController?.window = window
        window.contentView!.addSubview(mainViewController!.view)
        mainViewController!.view.frame = window.contentView!.bounds
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        if let a = activity {
            NSProcessInfo().endActivity(a)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    func appInit() {
        let options = NSActivityOptions(
            rawValue: NSActivityOptions.UserInitiated.rawValue | NSActivityOptions.IdleSystemSleepDisabled.rawValue
        )
        activity = NSProcessInfo().beginActivityWithOptions(options, reason: "start timer")
        MobTimer.initDefaults()
    }

    func addGlobalShortcut() {
        let accessEnabled = AXIsProcessTrustedWithOptions(
            [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true])
        if accessEnabled {
            NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask, handler: self.handleEvent)
        }
        NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask, handler: self.handleLocalEvent)
    }

    func handleLocalEvent(event: NSEvent) -> NSEvent {
        handleEvent(event)
        return event
    }
    
    func handleEvent(event: NSEvent) {
        if event.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask)
        && event.modifierFlags.contains(NSEventModifierFlags.AlternateKeyMask)
        && event.modifierFlags.contains(NSEventModifierFlags.ShiftKeyMask)
        && event.modifierFlags.contains(NSEventModifierFlags.ControlKeyMask)
        && event.charactersIgnoringModifiers != nil
        && event.charactersIgnoringModifiers == "P" {
            
            if let controller = mainViewController {
                controller.timerStarted(self)
            }
        }
    }
    
    @IBAction func preferencesClicked(sender: AnyObject) {
        if preferencesWindow == nil {
            preferencesWindow = PreferencesWindowController(windowNibName: "PreferencesWindowController")
        }
        preferencesWindow!.showWindow(sender)
    }
}
