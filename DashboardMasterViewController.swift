//
//  DashboardMasterViewController.swift
//  SignUp
//
//  Created by Pradul MT on 28/07/17.
//  Copyright © 2017 Pradul MT. All rights reserved.
//

import UIKit
import Starscream

class DashboardMasterViewController: UIViewController, UISplitViewControllerDelegate, WebSocketDelegate {
    
    var dashboard = Dashboard()
    var uploadObserver: NSObjectProtocol?
    var lastUploadHubIndex: Int?
    var lastUploadBoardIndex: Int?
    var lastUploadSwitchIndex: Int?
    var lastUploadIsOn: Bool?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let stationName = NSNotification.Name("DSNotificationDataUpload")
        self.uploadObserver = NotificationCenter.default.addObserver(forName: stationName, object: nil, queue: nil)
        { [weak self] (notification) in
            let info: Any? = notification.userInfo
            if let info = info {
                var data = info as! [String: Any]
                if data["singleSwitchUpdate"] != nil, let data = data["singleSwitchUpdate"] as? [String : Any] {
                    self?.postNotificationToStartSpin()
                    let hubIndex = data["hubIndex"] as! Int
                    let boardIndex = data["boardIndex"] as! Int
                    let switchIndex = data["switchIndex"] as! Int
                    let isOn = data["isOn"] as! Bool
                    let switchKey = "switch" + String(switchIndex)
                    
                    let hub = self?.dashboard.hubs[hubIndex]
                    var msg = self?.createMessageFromHubData(hub: hub!, boardIndex: boardIndex)
                    msg?["type"] = "singleSwitchUpdate"
                    msg?["appSocketID"] = self?.dashboard.appSocketID
                    if isOn {
                        msg?[switchKey] = "on"
                    } else {
                        msg?[switchKey] = "off"
                    }
                    
                    print("\nCurrent")
                    for hub in (self?.dashboard.hubs)! {
                        for board in hub.boards {
                            print(board.id, board.isSwitchBoardOnline, board.name!, board.switch1State, board.switch2State, board.switch3State, board.switch4State)
                        }
                    }
                    
                    if let msg = msg {
                        let jsonData = try? JSONSerialization.data(withJSONObject: msg, options: [])
                        self?.lastUploadHubIndex = hubIndex
                        self?.lastUploadBoardIndex = boardIndex
                        self?.lastUploadSwitchIndex = switchIndex
                        self?.lastUploadIsOn = isOn
                        self?.dashboard.socket.write(data: jsonData!)
                    }
                }
            }
        }

    }
    
    // MARK: Websocket Delegate Methods.
    
    func websocketDidConnect(socket: WebSocket) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
            print("\(e)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        
        if let data = text.data(using: .utf8) {
            do {
                dashboard.serverData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                return
            }
            if let serverMsg = dashboard.serverData {
                if JSONSerialization.isValidJSONObject(serverMsg) {
                    if serverMsg["type"] as? String == "init" {
                        if let id = serverMsg["appSocketID"] as? String {
                            dashboard.appSocketID = id
                        } else {
                            print("Invalid data from server. Disconnecting")
                            dashboard.socket.disconnect()
                        }
                        let authMsg = ["type": "auth", "user": "test", "passcode": "123", "appSocketID": dashboard.appSocketID] as [String : Any]
                        
                        if let jsonAuthMsg = try? JSONSerialization.data(withJSONObject: authMsg, options: []) {
                            dashboard.socket.write(data: jsonAuthMsg)
                        } else {
                            print("Internal error in client. Disconnecting")
                            dashboard.socket.disconnect()
                        }
                    } else if serverMsg["serverPush"] as? String == "stateChange" {
                        if  dashboard.appSocketID != serverMsg["appSocketID"] as? String {
                            postNotificationToStartSpin()
                            processStateChangeFromServer(serverMsg: serverMsg)
                            postNotificationAboutUpdatedData()
                        } else {
                            if let hubIndex = lastUploadHubIndex, let boardIndex = lastUploadBoardIndex,
                                let switchIndex = lastUploadSwitchIndex, let isOn = lastUploadIsOn {
                                if isOn {
                                    switch switchIndex {
                                    case 1:
                                        dashboard.hubs[hubIndex].boards[boardIndex].switch1State = .on
                                    case 2:
                                        dashboard.hubs[hubIndex].boards[boardIndex].switch2State = .on
                                    case 3:
                                        dashboard.hubs[hubIndex].boards[boardIndex].switch3State = .on
                                    case 4:
                                        dashboard.hubs[hubIndex].boards[boardIndex].switch4State = .on
                                    default:
                                        print("internal error")
                                    }
                                } else {
                                    switch switchIndex {
                                    case 1:
                                        dashboard.hubs[hubIndex].boards[boardIndex].switch1State = .off
                                    case 2:
                                        dashboard.hubs[hubIndex].boards[boardIndex].switch2State = .off
                                    case 3:
                                        dashboard.hubs[hubIndex].boards[boardIndex].switch3State = .off
                                    case 4:
                                        dashboard.hubs[hubIndex].boards[boardIndex].switch4State = .off
                                    default:
                                        print("internal error")
                                    }
                                }
                                print("Success. Dashboard reset to this.")
                                for hub in (self.dashboard.hubs) {
                                    for board in hub.boards {
                                        print(board.id, board.isSwitchBoardOnline, board.name!, board.switch1State, board.switch2State, board.switch3State, board.switch4State)
                                    }
                                }

                                
                                postNotificationToStopSpin()
                            }
                        }
                    } else if serverMsg["type"] as? String == "error" {
                        print("Error in Authentication")
                    }
                    
                }
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("Received data: \(data.count)")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // for the UISplitViewControllerDelegate method below to work
    // we have to set ourself as the UISplitViewController's delegate
    // (only we can be that because ImageViewControllers come and goes from the heap)
    // we could probably get away with doing this as late as viewDidLoad
    // but it's a bit safer to do it as early as possible
    // and this is as early as possible
    // (we just came out of the storyboard and "awoke"
    // so we know we are in our UISplitViewController by now)
    override func awakeFromNib() {
        super.awakeFromNib()
        self.splitViewController?.delegate = self
        
        dashboard.socket.delegate = self
        
        // Connecting to server.
        // ADD THIS TO GLOBAL THREAD
         dashboard.socket.connect()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "showOverview", let overviewController = segue.destination.contents as? DashboardDetailTableViewController {
                overviewController.title = "Overview"
                
                if dashboard.hubs.count != 0 {
                    overviewController.isUpdateOngoing = true
                    overviewController.hubs = dashboard.hubs
                    overviewController.isUpdateOngoing = false
                } else {
                    print("Dashboard hubs empty")
                }
            }
        }
    }
    
    // we "fake out" iOS here
    // this delegate method of UISplitViewController
    // allows the delegate to do the work of collapsing the primary view controller (the master)
    // on top of the secondary view controller (the detail)
    // this happens whenever the split view wants to show the detail
    // but the master is on screen in a spot that would be covered up by the detail
    // the return value of this delegate method is a Bool
    // "true" means "yes, Mr. UISplitViewController, I did collapse that for you"
    // "false" means "sorry, Mr. UISplitViewController, I couldn't collapse so you do it for me"
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController
        ) -> Bool {
        if primaryViewController.contents == self {
            if secondaryViewController.contents is DashboardDetailTableViewController {
                return true
            }
        }
        return false
    }
    
    
    
    // MARK: Private Methods
    private func processStateChangeFromServer(serverMsg: [String: Any]) {
        var hub: Hub?
        var isNewHub = false
        
        dashboard.serverData = serverMsg
        
        if let hubAddr = serverMsg["hubAddr"] as? Int64 {
            print("\nHub Address: \(hubAddr)")
            hub = dashboard.getHub(withHubAddr: hubAddr)
            if hub == nil {
                hub = Hub(hubAddr: hubAddr)
                isNewHub = true
            }
        }
        
        for (key, value) in serverMsg {
            if let boardData = value as? [String: Any] {
                var switch1: SwitchBoard.SwitchState, switch2: SwitchBoard.SwitchState,
                    switch3: SwitchBoard.SwitchState, switch4: SwitchBoard.SwitchState;
                let boardName = key
                let boardIndex = boardData["devIndex"] as! Int
                var board: SwitchBoard?
                
                if boardData["type"] as? Int == SwitchBoard.SwitchBoardType.type4x4.rawValue {
                    
                    if boardData["switch1"] as? Int == 1 {
                        switch1 = SwitchBoard.SwitchState.on
                    } else {
                        switch1 = SwitchBoard.SwitchState.off
                    }
                    if boardData["switch2"] as? Int == 1 {
                        switch2 = SwitchBoard.SwitchState.on
                    } else {
                        switch2 = SwitchBoard.SwitchState.off
                    }
                    if boardData["switch3"] as? Int == 1 {
                        switch3 = SwitchBoard.SwitchState.on
                    } else {
                        switch3 = SwitchBoard.SwitchState.off
                    }
                    if boardData["switch4"] as? Int == 1 {
                        switch4 = SwitchBoard.SwitchState.on
                    } else {
                        switch4 = SwitchBoard.SwitchState.off
                    }
                    
                    board = SwitchBoard(boardName, type: .type4x4, id: boardIndex, one: switch1, two: switch2, three: switch3, four: switch4)
                } //type4x4//
                
                if isNewHub, let hub = hub {
                    if let board = board {
                        //print("Board added to New hub")
                        hub.addBoard(newBoard: board)
                    }
                } else if let hub = hub {
                    if let board = board {
                        if hub.getBoard(withId: board.id) != nil {
                            //print("Board replaced in existing hub")
                            hub.replaceBoard(withId: board.id, newBoard: board)
                        } else {
                            //print("New board added to exsisting hub")
                            hub.addBoard(newBoard: board)
                        }
                    }
                }
            } //boardData//
        }

        if isNewHub, let hub = hub {
            dashboard.addHub(newhub: hub)
        }
        
    } //processStateChangeFromServer//
    
    private func postNotificationAboutUpdatedData() {
        let data = ["Hubs": dashboard.hubs]
        let stationName = NSNotification.Name("DSNotificationDataUpdate")
        let radioStation = NotificationCenter.default
        
        radioStation.post(name: stationName, object: self, userInfo: data)
    }
    
    private func postNotificationToStartSpin() {
        let data = ["Spin": true]
        let stationName = NSNotification.Name("DSNotificationDataUpdate")
        let radioStation = NotificationCenter.default
        
        radioStation.post(name: stationName, object: self, userInfo: data)
    }

    private func postNotificationToStopSpin() {
        let data = ["Spin": false]
        let stationName = NSNotification.Name("DSNotificationDataUpdate")
        let radioStation = NotificationCenter.default
        
        radioStation.post(name: stationName, object: self, userInfo: data)
    }
    
    private func createMessageFromHubData(hub: Hub, boardIndex: Int) -> [String: String] {
        let nodeid = hub.boards[boardIndex].id
        let board = hub.boards[boardIndex]
        let boardType = board.switchBoardType
        var dict = ["hubAddr": String(hub.hubAddr), "nodeid": String(nodeid)] as [String : String]
        
        if boardType == .type4x4 {
            if board.switch1State == .on {
                dict["switch1"] = "on"
            } else if board.switch1State == .off {
                dict["switch1"] = "off"
            }
            if board.switch2State == .on {
                dict["switch2"] = "on"
            } else if board.switch2State == .off {
                dict["switch2"] = "off"
            }
            if board.switch3State == .on {
                dict["switch3"] = "on"
            } else if board.switch3State == .off {
                dict["switch3"] = "off"
            }
            if board.switch4State == .on {
                dict["switch4"] = "on"
            } else if board.switch4State == .off {
                dict["switch4"] = "off"
            }
        }
        return dict
    }
    
}

extension UIViewController
{
    // a friendly var we've added to UIViewController
    // it returns the "contents" of this UIViewController
    // which, if this UIViewController is a UINavigationController
    // means "the UIViewController contained in me (and visible)"
    // otherwise, it just means the UIViewController itself
    // could easily imagine extending this for UITabBarController too
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}
