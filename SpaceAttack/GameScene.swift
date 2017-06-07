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

enum enemyVerticalDirection {
	case up
	case down
	case none
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
	
	func randRange (lower: Int , upper: Int) -> Int {
		return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
	}
	
	//Global constants
	let kSteerAcceleration: Float = 0.25
	let kSteerMaxSpeed: Float = 4
	
	let topLimit = 380
	let bottomLimit = -380
	
	//Arrays
	var enemyShips = [EnemyShip]()
	var playerShips = [SpaceShip]()
	var bullets = [Bullet]()
	
	//Players
	var player1 = SpaceShip()
	var player2 = SpaceShip()
	
	//Keep track of enemy direction
	var enemyDir: enemyVerticalDirection = .up
	
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
		player1.side = .left
		playerShips.append(player1)
		
		self.addChild(player2)
		player2.zPosition = LayerIndex.players.zPosition
		player2.position = CGPoint(x: 470, y:0)
		//Rotate this
		player2.zRotation = 90 * .pi / 180
		player2.side = .right
		playerShips.append(player2)
	}
	
	func newEnemyGroup(rows: Int, cols: Int, spacing: CGPoint, offset: CGPoint) -> [EnemyShip] {
		var enemies = [EnemyShip]()
		for y in 0..<rows {
			for x in 0..<cols {
				let enemy = EnemyShip()
				enemy.zPosition = LayerIndex.enemies.rawValue
				enemy.position.x = CGFloat(x) * spacing.x + offset.x
				enemy.position.y = CGFloat(y) * spacing.y + offset.y
				enemies.append(enemy)
			}
		}
		return enemies
	}
	
	func initEnemies() {
		let leftGroup = newEnemyGroup(rows: 12, cols: 3, spacing: CGPoint(x: -75, y: 50), offset: CGPoint(x: -75, y: 0))
		let rightGroup = newEnemyGroup(rows: 12, cols: 3, spacing: CGPoint(x: 75, y: 50), offset: CGPoint(x: 75, y: 0))
		leftGroup.forEach { $0.direction = .left }
		rightGroup.forEach { $0.direction = .right }
		let enemies = leftGroup + rightGroup
		for enemyShip in enemies {
			enemyShip.position.y -= (12/2 - 0.5) * 50
			addChild(enemyShip)
			enemyShips.append(enemyShip)
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
	
	func shoot(player: SpaceShip) {
		let bullet = Bullet(shooter: player)
		bullets.append(bullet)
		addChild(bullet)
	}
	
	//var timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.update), userInfo: nil, repeats: true);
	
	func setControls() {
		//Player 1
		if keys.D {
			player1.firing = true
			Timer.scheduledTimer(timeInterval: TimeInterval(player1.fireInterval), target: self, selector: #selector(self.shoot), userInfo: nil, repeats: false)
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
			Timer.scheduledTimer(timeInterval: TimeInterval(player1.fireInterval), target: self, selector: #selector(self.shoot), userInfo: nil, repeats: false)
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
	
	func shiftEnemies(distance: Double) {
		for enemyShip in self.enemyShips {
			if enemyShip.direction == .left {
				enemyShip.position.x = enemyShip.position.x - CGFloat(distance)
			} else if enemyShip.direction == .right {
				enemyShip.position.x = enemyShip.position.x + CGFloat(distance)
			}
		}
	}
	
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
		
		setControls()
		
		// Update players
		for playerShip in self.playerShips {
			playerShip.update()
			
			if playerShip.topPoint >= CGFloat(topLimit) {
				playerShip.yVelocity = -3
			} else if playerShip.bottomPoint <= CGFloat(bottomLimit) {
				playerShip.yVelocity = 3
			}
		}
		
		//Check if any enemy has collided with top/bottom
		for enemyShip in self.enemyShips {
			if enemyShip.topPoint >= CGFloat(topLimit) {
				enemyDir = .down
				shiftEnemies(distance: 1)
				break
			} else if enemyShip.bottomPoint <= CGFloat(bottomLimit) {
				enemyDir = .up
				shiftEnemies(distance: 1)
				break
			}
		}
		
		//Move enemies
		for enemyShip in self.enemyShips {
			if enemyDir == .up {
				enemyShip.position.y = enemyShip.position.y + 0.5
			} else if enemyDir == .down {
				enemyShip.position.y = enemyShip.position.y - 0.5
			}
		}
    }
}
