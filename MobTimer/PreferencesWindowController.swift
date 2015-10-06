//
//  PreferencesWindowController.swift
//  MobTimer
//
//  Created by Yu Wang on 05/10/15.
//  Copyright © 2015 Yu Wang. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController, NSTableViewDataSource {

    @IBOutlet weak var driverTime: NSTextField!
    @IBOutlet weak var breakFrequence: NSTextField!
    @IBOutlet weak var playersTable: NSTableView!
    @IBOutlet weak var playerRemove: NSButton!

    let mobTimer = MobTimer()
    var selectedPlayerId = -1
    
    override func windowDidLoad() {
        super.windowDidLoad()
        playerRemove.enabled = false
    }
    
    @IBAction func playerSelected(sender: AnyObject) {
        selectedPlayerId = playersTable.selectedRow
        playerRemove.enabled = selectedPlayerId >= 0
    }

    @IBAction func playerRemoved(sender: AnyObject) {
        mobTimer.removePlayer(selectedPlayerId)
        mobTimer.savePlayers()
        playersTable.reloadData()
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
