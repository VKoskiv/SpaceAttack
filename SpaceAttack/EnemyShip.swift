//
//  EnemyShip.swift
//  SpaceAttack
//
//  Created by Valtteri Koskivuori on 05/06/2017.
//  Copyright © 2017 Valtteri Koskivuori. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class EnemyShip: SpaceShip {
	var level: eDifficultyLevel!
	
	class func randRange (lower: Int , upper: Int) -> Int {
		return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
	}
	
	convenience init() {
		self.init(imageNamed: "Enemy\(EnemyShip.randRange(lower: 0, upper: 3))")
		self.health = 100
		self.level = .easy
		
		self.texture?.filteringMode = .nearest
		self.setScale(5)
	}
	
	enum eDifficultyLevel {
		case easy
		case normal
		case notbad
		case oh_no
		case not_good
		case holy_shit
		case Блядь
	}
}
