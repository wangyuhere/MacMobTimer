//
//  MainViewController.swift
//  MobTimer
//
//  Created by Yu Wang on 05/10/15.
//  Copyright © 2015 Yu Wang. All rights reserved.
//

import Cocoa
import Carbon
import AVFoundation

class MainViewController: NSViewController, NSTableViewDataSource {

    var window: NSWindow?

    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var message: NSTextField!
    @IBOutlet weak var nextBreakMessage: NSTextField!
    @IBOutlet weak var driver: NSTextField!
    @IBOutlet weak var nextDriver: NSTextField!
    @IBOutlet weak var timerDisplay: NSTextField!
    @IBOutlet weak var timerStart: NSButton!
    @IBOutlet weak var players: NSTableView!

    @IBOutlet weak var playerRemove: NSButton!

    var addPlayerWindow: AddPlayerWindow?
    var timer: NSTimer?
    var audioPlayer: AVAudioPlayer!
    var mobTimer = MobTimer()
    var selectedPlayerId = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        playerRemove.enabled = false

        mobTimer.shuffle()
        players.reloadData()

        updateUI()
        timer = startTimer()
    }
    
    @IBAction func timerStarted(sender: AnyObject) {
        if mobTimer.isBreak() {
            return
        }

        if mobTimer.isStopped() {
            mobTimer.start()
            window!.level = Int(CGWindowLevelForKey(CGWindowLevelKey.NormalWindowLevelKey))
            timerStart.title = "Pause"
            if let player = mobTimer.driver {
                switchInput(player.keyboard)
            }
            players.reloadData()
        } else {
            mobTimer.pause()
            timerStart.title = "Start"
        }
    }

    @IBAction func resetTimer(sender: AnyObject) {
        mobTimer.resetTime()
        window!.level = Int(CGWindowLevelForKey(CGWindowLevelKey.NormalWindowLevelKey))
        updateUI()
    }

    @IBAction func skipPlayer(sender: AnyObject) {
        mobTimer.skip()
        players.reloadData()
        timerStart.title = "Start"
        updateUI()
    }

    @IBAction func addPlayer(sender: AnyObject) {
        if addPlayerWindow == nil {
            addPlayerWindow = AddPlayerWindow(windowNibName: "AddPlayerWindow")
        }

        let window = addPlayerWindow!.window!
        let point = NSPoint(
            x: self.window!.frame.midX - window.frame.size.width/2,
            y: self.window!.frame.midY + window.frame.size.height/2
        )
        window.setFrameTopLeftPoint(point)
        NSApp.runModalForWindow(window)

        if addPlayerWindow!.name != "" {
            let name = addPlayerWindow!.name
            let keyboard = addPlayerWindow!.keyboard
            mobTimer.addPlayer(name, keyboard: keyboard)
            players.reloadData()
        }
        addPlayerWindow = nil
    }

    @IBAction func playerSelected(sender: AnyObject) {
        selectedPlayerId = players.selectedRow
        playerRemove.enabled = selectedPlayerId >= 0
    }

    @IBAction func removePlayer(sender: AnyObject) {
        if selectedPlayerId < 0 {
            return
        }
        mobTimer.removePlayer(selectedPlayerId)
        players.reloadData()
    }

    @IBAction func shufflePlayers(sender: AnyObject) {
        mobTimer.shuffle()
        players.reloadData()
    }
    
    func startTimer() -> NSTimer? {
        return NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTime", userInfo: nil, repeats: true)
    }

    func updateTime() {
        if mobTimer.notifyDriver() {
            timerStart.enabled = false
            window!.makeKeyAndOrderFront(self)
            window!.level = Int(CGWindowLevelForKey(CGWindowLevelKey.PopUpMenuWindowLevelKey))
            playSound()
        }

        mobTimer.update()
        updateUI()
    }

    func updateUI() {
        timerDisplay.stringValue = String(mobTimer.timeInfo)
        if mobTimer.isBreak() {
            timerStart.enabled = false
        } else if mobTimer.isStopped() {
            timerStart.title = "Start"
            timerStart.enabled = true
        } else {
            timerStart.title = "Pause"
        }
        updateMessage()
    }

    func updateMessage() {
        if let player = mobTimer.driver {
            driver.stringValue = "Driver: " + player.name
        } else {
            driver.stringValue = "Break Time"
        }
        message.stringValue = mobTimer.message
        nextBreakMessage.stringValue = mobTimer.nextPauseMessage
        nextDriver.stringValue = mobTimer.nextDriverMessage
    }

    func playSound() {
        let name = mobTimer.sound
        let alertSound = NSBundle.mainBundle().URLForResource(name, withExtension: "aiff")!

        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: alertSound)
            audioPlayer.prepareToPlay()
            audioPlayer.numberOfLoops = 2
            audioPlayer.play()
        } catch {
            print("Error")
        }
    }

    // Switch input source to specified language
    func switchInput(lang: String) {
        let allInputs = TISCreateInputSourceList(nil, false).takeRetainedValue()
        let count = CFArrayGetCount(allInputs)

        for (var i = 0; i < count; i++) {
            let source = unsafeBitCast(CFArrayGetValueAtIndex(allInputs, i), TISInputSource.self)
            let sourceLang = unsafeBitCast(TISGetInputSourceProperty(source, kTISPropertyLocalizedName), NSString.self) as String
            if sourceLang == lang {
                TISSelectInputSource(source)
                break
            }
        }
    }

    func showTimerPage() {
        tabView.selectTabViewItemWithIdentifier("timer")
    }

    func showPlayersPage() {
        tabView.selectTabViewItemWithIdentifier("players")
    }

    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return self.mobTimer.players.count
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView

        let player = self.mobTimer.players[row]
        cellView.textField!.stringValue = String(format: "%@ (%@)", player.name, player.keyboard)

        return cellView
    }

}
