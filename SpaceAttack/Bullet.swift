//
//  Bullet.swift
//  SpaceAttack
//
//  Created by Valtteri Koskivuori on 07/06/2017.
//  Copyright © 2017 Valtteri Koskivuori. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Bullet: SKSpriteNode {
	var effectiveness: Int!
	var velocity: Float!
	var shooter: SpaceShip!
}
