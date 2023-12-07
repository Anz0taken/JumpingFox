//
//  ObjectClass.swift
//  GameTest
//
//  Created by Luca Gargiulo on 05/12/23.
//

import Foundation

class Object{
    private var x_position:Int
    private var y_position:Int
    
    init(x_position: Int, y_position: Int) {
        self.x_position = x_position
        self.y_position = y_position
    }
    
    public func getX() -> Int{
        return self.x_position
    }
    
    public func getY() -> Int{
        return self.y_position
    }
}
