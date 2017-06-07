//
//  Star.swift
//  SpaceAttack
//
//  Created by Valtteri Koskivuori on 07/06/2017.
//  Copyright © 2017 Valtteri Koskivuori. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Star: SKSpriteNode {
	
	var level: starLevel = .level0
	
	class func randRange (lower: Int , upper: Int) -> Int {
		return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
	}
	convenience init() {
		self.init(imageNamed: "Star\(EnemyShip.randRange(lower: 0, upper: 3))")
		self.texture?.filteringMode = .nearest
		self.setScale(1)
		self.alpha = 0.5
	}
	
	var starSpeed: Float {
		switch self.level {
		case .level0:
			return 0.2
		case .level1:
			return 0.4
		case .level2:
			return 0.6
		case .level3:
			return 0.8
		}
	}
	
	enum starLevel {
		case level0
		case level1
		case level2
		case level3
	}
}
