//
//  MobTimer.swift
//  MobTimer
//
//  Created by Yu Wang on 26/09/15.
//  Copyright © 2015 Yu Wang. All rights reserved.
//

import Foundation

class MobTimer {
    struct Player {
        var name: String
        var keyboard: String
        
        init(name: String, keyboard: String) {
            self.name = name
            self.keyboard = keyboard
        }
    }
    
    enum State {
        case Started, Stopped, Break
    }
    
    private var state: State
    private var curTime: Int
    private var timeToBreak: Int
    private var timeInterval: Int
    private var breakInterval: Int
    
    var players: [Player]
    
    init(timeInterval: Int, breakInterval: Int) {
        self.state = State.Stopped
        self.timeInterval = timeInterval
        self.breakInterval = breakInterval
        self.curTime = timeInterval
        self.timeToBreak = breakInterval
        self.players = [Player]()
    }
    
    convenience init() {
        self.init(timeInterval: 10 * 60, breakInterval: 50 * 60)
    }
    
    var timeInfo: String {
        return String(format: "%02d:%02d", curTime/60, curTime%60)
    }
    
    var nextPause: String {
        return String(format: "%02d:%02d", timeToBreak/60, timeToBreak%60)
    }
    
    var driver: Player? {
        if players.count == 0 || isBreak() {
            return nil
        }
        
        return players[0]
    }
    
    func addPlayer(name: String, keyboard: String) -> Player {
        let player = Player(name: name, keyboard: keyboard)
        players.append(player)
        return player
    }
    
    func removePlayer(id: Int) {
        players.removeAtIndex(id)
    }
    
    func resetTime(timeInterval: Int, breakInterval: Int) {
        self.state = State.Stopped
        self.timeInterval = timeInterval
        self.breakInterval = breakInterval
        self.curTime = timeInterval
        self.timeToBreak = breakInterval
    }
    
    func start() {
        state = State.Started
    }
    
    func pause() {
        state = State.Stopped
    }
    
    func skip() {
        curTime = timeInterval
        state = State.Stopped
        
        // it's time to pause
        if timeToBreak <= 0 {
            timeToBreak = breakInterval + timeInterval
            state = State.Break
            return
        }
        
        // Switch driver
        if players.count == 0 {
            return
        }
        let player = players.removeAtIndex(0)
        players.append(player)
    }
    
    func isStopped() -> Bool {
        return state == State.Stopped
    }
    
    func isBreak() -> Bool {
        return state == State.Break
    }
    
    func notifyDriver() -> Bool {
        return curTime == 2
    }
    
    func update() {
        if isStopped() {
            if (timeToBreak < breakInterval) {
                timeToBreak++
            }
            return
        }
        curTime--
        
        if timeToBreak > 0 {
            timeToBreak--
        }
        
        if curTime <= 0 {
            skip()
        }
    }
    
    func shuffle() {
        if players.count < 2 { return }
        
        for i in 0..<(players.count - 1) {
            let j = Int(arc4random_uniform(UInt32(players.count - i))) + i
            let player = players[i]
            players[i] = players[j]
            players[j] = player
        }
    }
}