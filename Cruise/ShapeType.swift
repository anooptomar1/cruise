//
//  ShapeType.swift
//  Cruise
//
//  Created by Mark Anderson on 2/11/17.
//  Copyright © 2017 MartianRover. All rights reserved.
//

import Foundation

enum ShapeType:Int {
    case box = 0
    case sphere
    case pyramid
    case torus
    case capsule
    case cylinder
    case cone
    case tube
    
    static func random() -> ShapeType {
        let maxValue = tube.rawValue
        let rand = arc4random_uniform(UInt32(maxValue+1))
        return ShapeType(rawValue: Int(rand))!
    }
}