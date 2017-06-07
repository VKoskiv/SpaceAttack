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
	
	convenience init(shooter: SpaceShip) {
		self.init(imageNamed: "Bullet")
		self.texture?.filteringMode = .nearest
		self.setScale(5)
		self.position = shooter.cannonPoint
		switch shooter.side {
		case .left:
			self.velocity = shooter.fireVelocity
		case .right:
			self.velocity = -shooter.fireVelocity
		}
	}
}
