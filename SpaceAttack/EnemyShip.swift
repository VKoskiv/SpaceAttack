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
	var level: eDifficultyLevel = .easy
	var direction: motionDirection!
	
	class func randRange (lower: Int , upper: Int) -> Int {
		return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
	}
	
	convenience init() {
		self.init(imageNamed: "Enemy\(EnemyShip.randRange(lower: 0, upper: 3))")
		self.health = 100
		self.direction = .neither
		
		self.texture?.filteringMode = .nearest
		self.setScale(5)
	}
	
	var leftEdge: CGFloat {
		return self.position.x - self.frame.width / 2
	}
	
	var rightEdge: CGFloat {
		return self.position.x + self.frame.width / 2
	}
	
	var scoreYield: Int {
		switch self.level {
		case .easy:
			return 25
		case .normal:
			return 50
		case .notbad:
			return 100
		case .oh_no:
			return 125
		case .not_good:
			return 150
		case .holy_shit:
			return 150
		case .Блядь:
			return 300
		}
	}
	
	var currentSpeed: CGFloat {
		switch self.level {
		case .easy:
			return 0.5
		case .normal:
			return 1.0
		case .notbad:
			return 2.0
		case .oh_no:
			return 3.0
		case .not_good:
			return 4.0
		case .holy_shit:
			return 6.0
		case .Блядь:
			return 8.0
		}
	}
	
	var shiftSpeed: Double {
		switch self.level {
		case .easy:
			return 1.0
		case .normal:
			return 1.0
		case .notbad:
			return 2.0
		case .oh_no:
			return 4.0
		case .not_good:
			return 6.0
		case .holy_shit:
			return 7.0
		case .Блядь:
			return 8.0
		}
	}
	
	static func getNextDifficulty(diff: eDifficultyLevel) -> eDifficultyLevel {
		switch diff {
		case .easy:
			return .normal
		case .normal:
			return .notbad
		case .notbad:
			return .oh_no
		case .oh_no:
			return .not_good
		case .not_good:
			return .holy_shit
		case .holy_shit:
			return .Блядь
		default:
			return .Блядь
		}
	}
	
	static func getDifficultyText(diff: eDifficultyLevel) -> String {
		switch diff {
		case .easy:
			return "Easy"
		case .normal:
			return "Normal"
		case .notbad:
			return "Not bad"
		case .oh_no:
			return "Oh no"
		case .not_good:
			return "Not good"
		case .holy_shit:
			return "Holy shit"
		case .Блядь:
			return "Блядь!"
		}
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
	
	enum motionDirection {
		case left
		case right
		case neither
	}
}
