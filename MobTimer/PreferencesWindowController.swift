//
//  PreferencesWindowController.swift
//  MobTimer
//
//  Created by Yu Wang on 05/10/15.
//  Copyright © 2015 Yu Wang. All rights reserved.
//

import Cocoa
import AVFoundation

class PreferencesWindowController: NSWindowController, NSWindowDelegate, NSTableViewDataSource {

    @IBOutlet weak var driverTime: NSTextField!
    @IBOutlet weak var breakInterval: NSTextField!
    @IBOutlet weak var playersTable: NSTableView!
    @IBOutlet weak var playerRemove: NSButton!
    @IBOutlet weak var sounds: NSPopUpButton!

    var addPlayerWindow: AddPlayerWindow?
    var audioPlayer: AVAudioPlayer!
    let mobTimer = MobTimer()
    var selectedPlayerId = -1
    
    override func windowDidLoad() {
        super.windowDidLoad()
        playerRemove.enabled = false

        sounds.removeAllItems()
        sounds.addItemsWithTitles(MobTimer.sounds)
        sounds.selectItemWithTitle(mobTimer.sound)
    }

    func windowWillClose(notification: NSNotification) {
        mobTimer.resetTime()
        mobTimer.saveUserDefaults()
    }
    
    @IBAction func playerSelected(sender: AnyObject) {
        selectedPlayerId = playersTable.selectedRow
        playerRemove.enabled = selectedPlayerId >= 0
    }

    @IBAction func playerRemoved(sender: AnyObject) {
        mobTimer.removePlayer(selectedPlayerId)
        playersTable.reloadData()
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
            playersTable.reloadData()
        }
        addPlayerWindow = nil
    }

    @IBAction func playSound(sender: AnyObject) {
        playSoundByName(mobTimer.sound)
    }

    @IBAction func soundSelected(sender: AnyObject) {
        mobTimer.sound = sounds.selectedItem!.title
    }

    func playSoundByName(name: String) {
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

    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return mobTimer.players.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        
        let player = self.mobTimer.players[row]
        cellView.textField!.stringValue = String(format: "%@ (%@)", player.name, player.keyboard)
        
        return cellView
    }

}
