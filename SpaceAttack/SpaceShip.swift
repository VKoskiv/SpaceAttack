//
//  SpaceShip.swift
//  SpaceAttack
//
//  Created by Valtteri Koskivuori on 05/06/2017.
//  Copyright © 2017 Valtteri Koskivuori. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class SpaceShip: SKSpriteNode {
	var yVelocity: Float!
	var health: Int!
	var score: Int!
	var livesLeft: Int!
	var weaponType: eWeaponType!
	var armorType: eArmorType!
	var controlDirection: eControlDirection!
	var firing: Bool!
	
	let friction: Float = 20
	let acceleration: Float = 0.40
	let maxSpeed: Float = 5.0
	
	convenience init() {
		self.init(imageNamed: "Spaceship")
		self.health = 1000
		self.yVelocity = 0
		self.score = 0
		self.livesLeft = 5
		self.weaponType = .weaponTypeNormal
		self.armorType = .armorTypeNormal
		self.controlDirection = .neither
		self.firing = false
		self.texture?.filteringMode = .nearest
		self.setScale(5)
		self.zRotation = -90 * .pi / 180
	}
	
	enum eControlDirection {
		case up
		case down
		case neither
	}
	
	enum eWeaponType {
		case weaponTypeNormal
		case weaponTypeFast
		case weaponTypeBomb
	}
	enum eArmorType {
		case armorTypeNormal
		case armorTypeDouble
		case armorTypeFull
	}
	
	var bottomPoint: CGFloat {
		return self.position.y - self.frame.height / 2
	}
	
	var topPoint: CGFloat {
		return self.position.y + self.frame.height / 2
	}
	
	func update() {
		self.position = CGPoint(x: self.position.x, y: self.position.y + CGFloat(self.yVelocity))
		
		//FIXME: Use multipliers here (self.yVelocity = self.yvelocity + (self.yvelocity * acceleration)) 1.something
		if self.controlDirection == .up && self.yVelocity < maxSpeed {
			self.yVelocity = self.yVelocity + acceleration
		} else if self.controlDirection == .down && self.yVelocity > -maxSpeed {
			self.yVelocity = self.yVelocity - acceleration
		} else if self.controlDirection == .neither {
			self.yVelocity = self.yVelocity - self.yVelocity / friction
		}
	}
}
