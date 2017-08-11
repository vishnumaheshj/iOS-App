//
//  SwitchBoardTableViewCell.swift
//  SignUp
//
//  Created by Pradul MT on 27/07/17.
//  Copyright © 2017 Pradul MT. All rights reserved.
//

import UIKit

class SwitchBoardTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var boardLabel: UILabel!
    @IBOutlet weak var switch1Label: UILabel!
    @IBOutlet weak var switch1: UISwitch!
    @IBOutlet weak var switch2Label: UILabel!
    @IBOutlet weak var switch2: UISwitch!
    @IBOutlet weak var switch3Label: UILabel!
    @IBOutlet weak var switch3: UISwitch!
    @IBOutlet weak var switch4Label: UILabel!
    @IBOutlet weak var switch4: UISwitch!
    
    
    //MARK: API
    var node: SwitchBoard? {
        didSet {
            updateUI()
        }
    }
    
    //MARK: Private functions
    private func updateUI() {
        if let node = node {
            boardLabel?.text = node.name ?? boardLabel?.text
            switch1Label?.text = node.switch1Name ?? switch1Label?.text
            switch2Label?.text = node.switch2Name ?? switch2Label?.text
            switch3Label?.text = node.switch3Name ?? switch3Label?.text
            switch4Label?.text = node.switch4Name ?? switch4Label?.text
            
            if node.isSwitchBoardOnline {
                if node.switch1State == .on {
                    switch1?.setOn(true, animated: true)
                    switch1?.isEnabled = true
                } else if node.switch1State == .off {
                    switch1?.setOn(false, animated: true)
                    switch1?.isEnabled = true
                } else {
                    switch1?.isOn = false
                    switch1?.isEnabled = false
                }
                
                if node.switch2State == .on {
                    switch2?.setOn(true, animated: true)
                    switch2?.isEnabled = true
                } else if node.switch2State == .off {
                    switch2?.setOn(false, animated: true)
                    switch2?.isEnabled = true
                } else {
                    switch2?.isOn = false
                    switch2?.isEnabled = false
                }
                
                if node.switch3State == .on {
                    switch3?.setOn(true, animated: true)
                    switch3?.isEnabled = true
                } else if node.switch3State == .off {
                    switch3?.setOn(false, animated: true)
                    switch3?.isEnabled = true
                } else {
                    switch3?.isOn = false
                    switch3?.isEnabled = false
                }
                
                if node.switch4State == .on {
                    switch4?.setOn(true, animated: true)
                    switch4?.isEnabled = true
                } else if node.switch4State == .off {
                    switch4?.setOn(false, animated: true)
                    switch4?.isEnabled = true
                } else {
                    switch4?.isOn = false
                    switch4?.isEnabled = false
                }
            } else {
                switch1?.isOn = (node.switch1State == .on)
                switch1?.isEnabled = false
                switch2?.isOn = (node.switch2State == .on)
                switch2?.isEnabled = false
                switch3?.isOn = (node.switch3State == .on)
                switch3?.isEnabled = false
                switch4?.isOn = (node.switch4State == .on)
                switch4?.isEnabled = false
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func switchOneSwitched(_ sender: UISwitch) {
        let tag = sender.tag
        updateServerToNewState(senderTag: tag, switchIndex: 1, isOn: sender.isOn)
    }
    
    @IBAction func switchTwoSwitched(_ sender: UISwitch) {
        let tag = sender.tag
        updateServerToNewState(senderTag: tag, switchIndex: 2, isOn: sender.isOn)
    }
    
    @IBAction func switchThreeSwitched(_ sender: UISwitch) {
        let tag = sender.tag
        updateServerToNewState(senderTag: tag, switchIndex: 3, isOn: sender.isOn)
    }
    
    @IBAction func switchFourSwitched(_ sender: UISwitch) {
        let tag = sender.tag
        updateServerToNewState(senderTag: tag, switchIndex: 4, isOn: sender.isOn)
    }
    
    private func updateServerToNewState(senderTag: Int, switchIndex: Int, isOn: Bool) {
        let hubIndex = senderTag / 100
        let boardIndex = senderTag % 100
        print("hubIndex: \(hubIndex) boardIndex:\(boardIndex)")
        postNotificationToUpdateServer(hubIndex: hubIndex, boardIndex: boardIndex, switchIndex: switchIndex, isOn: isOn)
    }
    
    private func postNotificationToUpdateServer(hubIndex: Int, boardIndex: Int, switchIndex: Int, isOn: Bool) {
        let data = ["singleSwitchUpdate": ["hubIndex": hubIndex, "boardIndex": boardIndex, "switchIndex": switchIndex, "isOn": isOn]]
        let stationName = NSNotification.Name("DSNotificationDataUpload")
        let radioStation = NotificationCenter.default
        
        radioStation.post(name: stationName, object: self, userInfo: data)
    }

}






