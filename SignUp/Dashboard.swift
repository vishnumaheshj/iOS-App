//
//  Dashboard.swift
//  SignUp
//
//  Created by Pradul MT on 01/08/17.
//  Copyright © 2017 Pradul MT. All rights reserved.
//

import Foundation
import Starscream

class Dashboard {
    var socket = WebSocket(url: URL(string: "http://192.168.0.106:8888/app/websocket")!)
    var username: String?
    var password: String?
    var appSocketID = ""
    var serverData: [String: Any]?
    var updateOngoing = false
    var boardsAffectedOnLastUpdate: [Int] = []
    var newBoardsOnLastUpdate = false
    
    var numberOfHubs = 0
    
    var hubs = [Hub]()
    
    func getHub(withHubAddr hubAddr: Int64) -> Hub? {
        if let index = hubs.index(where: {$0.hubAddr == hubAddr}) {
            return hubs[index]
        }
        
        return nil
    }
    
    func addHub(newhub: Hub) {
        if hubs.index(where: {$0.hubAddr == newhub.hubAddr}) != nil {
            return
        }
        hubs.append(newhub)
        numberOfHubs += 1
    }
    
}
