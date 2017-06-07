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
		playerShips.append(player1)
		
		self.addChild(player2)
		player2.zPosition = LayerIndex.players.zPosition
		player2.position = CGPoint(x: 470, y:0)
		//Rotate this
		player2.zRotation = 90 * .pi / 180
		playerShips.append(player2)
	}
	
	//800x600
	func initEnemies() {
		var yPos: CGFloat = CGFloat(0)
		var xPos: CGFloat = CGFloat(0)
		
		var yBank: Int = 0; //when reaches 12, inc xBank by 1
		var xBank: Int = 0;
		
		//72 total, 36 either side, in 12 columns
		for _ in 1...72 {
			let enemy: EnemyShip = EnemyShip()
			enemy.zPosition = LayerIndex.enemies.rawValue
			self.addChild(enemy)
			
			switch xBank {
			case 0:
				xPos = CGFloat(-225)
				enemy.direction = .left
			case 1:
				xPos = CGFloat(-150)
				enemy.direction = .left
			case 2:
				xPos = CGFloat(-75)
				enemy.direction = .left
			case 3:
				xPos = CGFloat(75)
				enemy.direction = .right
			case 4:
				xPos = CGFloat(150)
				enemy.direction = .right
			case 5:
				xPos = CGFloat(225)
				enemy.direction = .right
			default:
				xPos = CGFloat(0)
				enemy.direction = .neither
			}
			
			switch yBank {
			case 0:
				yPos = -300
			case 1:
				yPos = -250
			case 2:
				yPos = -200
			case 3:
				yPos = -150
			case 4:
				yPos = -100
			case 5:
				yPos = -50
			case 6:
				yPos = 0
			case 7:
				yPos = 50
			case 8:
				yPos = 100
			case 9:
				yPos = 150
			case 10:
				yPos = 200
			case 11:
				yPos = 250
			default:
				yPos = 0
			}
			
			//Banks
			yBank = yBank + 1
			if yBank == 12 {
				xBank = xBank + 1
				yBank = 0
			}
			
			enemy.position.y = CGFloat(yPos)
			enemy.position.x = CGFloat(xPos)
			
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
	
	func shiftEnemies(distance: Int) {
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
				//shiftEnemies(distance: 10)
			} else if enemyShip.bottomPoint <= CGFloat(bottomLimit) {
				enemyDir = .up
				//shiftEnemies(distance: 10)
			}
		}
		
		//Move enemies
		for enemyShip in self.enemyShips {
			if enemyDir == .up {
				enemyShip.position.y = enemyShip.position.y + 1
			} else if enemyDir == .down {
				enemyShip.position.y = enemyShip.position.y - 1
			}
		}
		
		/*for enemyShip in self.enemyShips {
			if enemyShip.direction == .left {
				enemyShip.position.x = enemyShip.position.x - 1
			} else if enemyShip.direction == .right {
				enemyShip.position.x = enemyShip.position.x + 1
			}
		}*/
    }
}
