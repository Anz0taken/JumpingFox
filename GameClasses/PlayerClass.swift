//
//  PlayerSettings.swift
//  GameTest
//
//  Created by Luca Gargiulo on 05/12/23.
//

import Foundation

class Player: Object{
    private var alreadyJumping: Bool = false
    
    public func isJumping() -> Bool {
        return alreadyJumping
    }
    
    public func startEndJump(){
        alreadyJumping = !alreadyJumping
    }
    
    static public var PLAYER_WIDTH: Int  = Int(80*1.5)
    static public var PLAYER_HEIGTH: Int = Int(48*1.5)
}
