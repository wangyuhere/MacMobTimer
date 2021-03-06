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

        // disable app nap on Mac, otherwise the timer is stopped when app is running at backgroud
        let options = NSActivityOptions(
            rawValue: NSActivityOptions.UserInitiated.rawValue | NSActivityOptions.IdleSystemSleepDisabled.rawValue
        )
        activity = NSProcessInfo().beginActivityWithOptions(options, reason: "start timer")

        mainViewController = MainViewController(nibName: "MainViewController", bundle: NSBundle())
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

    @IBAction func toggleStartPause(sender: AnyObject) {
        if let controller = mainViewController {
            controller.timerStarted(self)
        }
    }

    @IBAction func skipPlayer(sender: AnyObject) {
        mainViewController?.skipPlayer(self)
    }

    @IBAction func resetTimer(sender: AnyObject) {
        mainViewController?.resetTimer(self)
    }

    @IBAction func showTimerPage(sender: AnyObject) {
        mainViewController?.showTimerPage()
    }

    @IBAction func showPlayersPage(sender: AnyObject) {
        mainViewController?.showPlayersPage()
    }
    
    @IBAction func preferencesClicked(sender: AnyObject) {
        if preferencesWindow == nil {
            preferencesWindow = PreferencesWindowController(windowNibName: "PreferencesWindowController")
        }
        preferencesWindow!.showWindow(sender)
    }
}
