//
//  Constants.swift
//  Breakout
//
//  Created by Arturs Derkintis on 8/21/15.
//  Copyright © 2015 Starfly. All rights reserved.
//

import UIKit

enum Level : Int{
    case easy = 10
    case normal = 15
    case hard = 20
}
enum Direction{
    case left
    case right
    case up
    case down
}
struct Bounciness {
    static let Borders: CGFloat = 1.0
    static let Paddle : CGFloat = 0.4
    static let Ball : CGFloat = 1.0
    static let Bricks : CGFloat = 0.0
}

struct Category {
    static let Ball: UInt32 = 1
    static let Paddle: UInt32 = 2
    static let Bricks: UInt32 = 4
    static let Bottom: UInt32 = 8
}

struct Layer {
    static let Background : CGFloat = 1
    static let Ball : CGFloat = 2
    static let Bricks : CGFloat = 3
    static let Paddle : CGFloat = 4
}

struct Names {
    static let Paddle = "paddle"
    static let Ball = "ball"
    static let Bottom = "gameEnder"
    static let Brick = "bb"
}
