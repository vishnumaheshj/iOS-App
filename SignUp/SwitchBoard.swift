//
//  SwitchBoard.swift
//  SignUp
//
//  Created by Pradul MT on 27/07/17.
//  Copyright © 2017 Pradul MT. All rights reserved.
//

import Foundation

class SwitchBoard {
    enum SwitchState {
        case on
        case off
        case notWorking
        case notInUse
        case notPresent
        case unknown
    }
    
    enum SwitchBoardType: Int {
        case typePlug = 1
        case type4x4 = 2
        case unknown = 0
    }
    
    var name: String? = "New Board"
    var switch1Name: String? = "Switch 1"
    var switch2Name: String? = "Switch 2"
    var switch3Name: String? = "Switch 3"
    var switch4Name: String? = "Switch 4"
    var switch5Name: String? = "Switch 5"
    var switch6Name: String? = "Switch 6"
    var switch7Name: String? = "Switch 7"
    var switch8Name: String? = "Switch 8"

    var switchBoardType: SwitchBoardType = .unknown
    var switch1State: SwitchState = .unknown
    var switch2State: SwitchState = .unknown
    var switch3State: SwitchState = .unknown
    var switch4State: SwitchState = .unknown
    var switch5State: SwitchState = .unknown
    var switch6State: SwitchState = .unknown
    var switch7State: SwitchState = .unknown
    var switch8State: SwitchState = .unknown
    var isSwitchBoardOnline: Bool = false
    var id: Int = 0
    
    init(_ name: String?, type: SwitchBoardType, id: Int) {
        self.name = name ?? self.name
        self.switchBoardType = type
        self.isSwitchBoardOnline = false
        self.id = id
    }

    init(_ name: String?, type: SwitchBoardType, id: Int, one: SwitchState, two: SwitchState, three: SwitchState, four: SwitchState ) {
        self.name = name ?? self.name
        self.switchBoardType = type
        self.id = id
        self.isSwitchBoardOnline = true
        self.switchBoardType = .type4x4
        self.switch1State = one
        self.switch2State = two
        self.switch3State = three
        self.switch4State = four
    }

}
