//
//  GameScene.swift
//  SpaceAttack
//
//  Created by Valtteri Koskivuori on 05/06/2017.
//  Copyright © 2017 Valtteri Koskivuori. All rights reserved.
//

import SpriteKit
import GameplayKit

private enum LayerIndex: CGFloat {
	case background
	case stars
	case extraEffects
	case enemies
	case players
	case projectiles
	
	var zPosition: CGFloat {
		return self.rawValue
	}
}

private enum controlDirection: Int {
	case up
	case down
	case none
	
	var numValue: Int {
		return self.rawValue
	}
}

struct KeyStatus {
	var    up: Bool = false
	var  down: Bool = false
	var  left: Bool = false
	var right: Bool = false
	
	var W: Bool = false
	var A: Bool = false
	var S: Bool = false
	var D: Bool = false
}

class GameScene: SKScene {
	
	//Global constants
	
	let kSteerAcceleration: Float = 0.25
	let kSteerMaxSpeed: Float = 4
	
	//Arrays
	var enemyShips = [EnemyShip]()
	var playerShips = [SpaceShip]()
	
	//Players
	var player1 = SpaceShip()
	var player2 = SpaceShip()
	
	//Keyboard status
	var keys = KeyStatus()
    
    private var lastUpdateTime : TimeInterval = 0
	
	override func didMove(to view: SKView) {
		//Game setup
		self.lastUpdateTime = 0
		initPlayers()
		initEnemies()
	}
	
	func initPlayers() {
		self.addChild(player1)
		player1.zPosition = LayerIndex.players.zPosition
		player1.position = CGPoint(x: -470, y: 0)
		playerShips.append(player1)
		
		self.addChild(player2)
		player2.zPosition = LayerIndex.players.zPosition
		player2.position = CGPoint(x: 470, y:0)
		//Rotate this
		player2.zRotation = 90 * .pi / 180
		playerShips.append(player2)
	}
	
	func initEnemies() {
		
		for i in 1...10 {
			let enemy: EnemyShip = EnemyShip()
			self.addChild(enemy)
			
			enemy.position.x = CGFloat(i * 10)
			
			enemyShips.append(enemy)
		}
		
	}
	
	func destroyEnemy(enemy: EnemyShip) {
		
	}
	
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x0D: //W
			keys.W = true
		case 0x00: //A
			keys.A = true
		case 0x01: //S
			keys.S = true
		case 0x02: //D
			keys.D = true
		//Player 2
		case 0x7E: //Up
			keys.up = true
		case 0x7D: //Down
			keys.down = true
		case 0x7B: //Left
			keys.left = true
		case 0x7C: //Right
			keys.right = true
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
	
	override func keyUp(with event: NSEvent) {
		switch event.keyCode {
		case 0x0D: //W
			keys.W = false
		case 0x00: //A
			keys.A = false
		case 0x01: //S
			keys.S = false
		case 0x02: //D
			keys.D = false
		//Player 2
		case 0x7E: //Up
			keys.up = false
		case 0x7D: //Down
			keys.down = false
		case 0x7B: //Left
			keys.left = false
		case 0x7C: //Right
			keys.right = false
		default:
			print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
		}
	}
	
	func setControls() {
		//Player 1
		if keys.D {
			player1.firing = true
		} else {
			player1.firing = false
		}
		
		if keys.W && keys.S {
			player1.controlDirection = .neither
		} else if keys.W {
			player1.controlDirection = .up
		} else if keys.S {
			player1.controlDirection = .down
		} else {
			player1.controlDirection = .neither
		}
		
		//Player 2
		if keys.left {
			player2.firing = true
		} else {
			player2.firing = false
		}
		
		if keys.up && keys.down {
			player2.controlDirection = .neither
		} else if keys.up {
			player2.controlDirection = .up
		} else if keys.down {
			player2.controlDirection = .down
		} else {
			player2.controlDirection = .neither
		}
	}
	
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
		
		setControls()
		
		// Update players
		for playerShip in self.playerShips {
			playerShip.update()
		}
    }
}
