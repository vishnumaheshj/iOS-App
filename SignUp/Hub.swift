//
//  Hub.swift
//  SignUp
//
//  Created by Pradul MT on 02/08/17.
//  Copyright © 2017 Pradul MT. All rights reserved.
//

import Foundation

class Hub {
    var hubAddr: Int64 = 0
    var name: String = "New Hub"
    var numberOfBoards: Int = 0
    var isActive: Bool = false
    var boards = [SwitchBoard]()
    
    init(hubAddr: Int64) {
        self.hubAddr = hubAddr
    }
    
    func addBoard(newBoard: SwitchBoard) {
        if boards.index(where: {$0.id == newBoard.id}) != nil {
            return
        }
        self.boards.append(newBoard)
        self.numberOfBoards += 1
    }
    
    func getBoard(withId id: Int) -> SwitchBoard? {
        if let index = boards.index(where: {$0.id == id}) {
            return boards[index]
        }
        return nil
    }
    
    func replaceBoard(withId id: Int, newBoard: SwitchBoard) {
        if let index = boards.index(where: {$0.id == id}) {
            boards.remove(at: index)
        }
        boards.append(newBoard)
    }
    

}
