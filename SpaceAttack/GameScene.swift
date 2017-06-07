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
	case stars0
	case stars1
	case stars2
	case stars3
	case enemies
	case extraEffects
	case players
	case projectiles
	case labels
	
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
	
	let topLimit = 400
	let bottomLimit = -400
	let leftLimit = -640
	let rightLimit = 640
	
	//Arrays
	var enemyShips = [EnemyShip]()
	var playerShips = [SpaceShip]()
	var bullets = [Bullet]()
	var stars = [Star]()
	
	//Players
	var player1 = SpaceShip()
	var player2 = SpaceShip()
	
	//Keep track of enemy direction
	var enemyDir: enemyVerticalDirection = .up
	//And current difficulty
	var currentDifficulty: EnemyShip.eDifficultyLevel = .easy
	
	var levelLabel: SKLabelNode!
	
	//Keyboard status
	var keys = KeyStatus()
    
    private var lastUpdateTime : TimeInterval = 0
	
	override func didMove(to view: SKView) {
		//Game setup
		self.lastUpdateTime = 0
		
		//self.size = view.frame.size
		
		levelLabel = SKLabelNode(fontNamed: "HelveticaNeue-Light")
		levelLabel.text = "Level: \(EnemyShip.getDifficultyText(diff: currentDifficulty))"
		levelLabel.position = CGPoint(x: -75, y: topLimit - 50)
		levelLabel.horizontalAlignmentMode = .left
		levelLabel.zPosition = LayerIndex.labels.rawValue
		addChild(levelLabel)
		
		initPlayers()
		initStars()
		initEnemies(difficulty: currentDifficulty)
	}
	
	func initStars() {
		for _ in 0...100 {
			let star = Star()
			star.position = CGPoint(x: randRange(lower: leftLimit, upper: rightLimit), y: randRange(lower: bottomLimit, upper: topLimit))
			star.zPosition = LayerIndex.stars0.rawValue
			star.level = .level0
			stars.append(star)
			addChild(star)
		}
		for _ in 0...100 {
			let star = Star()
			star.position = CGPoint(x: randRange(lower: leftLimit, upper: rightLimit), y: randRange(lower: bottomLimit, upper: topLimit))
			star.zPosition = LayerIndex.stars1.rawValue
			star.level = .level1
			stars.append(star)
			addChild(star)
		}
		for _ in 0...100 {
			let star = Star()
			star.position = CGPoint(x: randRange(lower: leftLimit, upper: rightLimit), y: randRange(lower: bottomLimit, upper: topLimit))
			star.zPosition = LayerIndex.stars2.rawValue
			star.level = .level2
			stars.append(star)
			addChild(star)
		}
		for _ in 0...100 {
			let star = Star()
			star.position = CGPoint(x: randRange(lower: leftLimit, upper: rightLimit), y: randRange(lower: bottomLimit, upper: topLimit))
			star.zPosition = LayerIndex.stars3.rawValue
			star.level = .level3
			stars.append(star)
			addChild(star)
		}
	}
	
	func initPlayers() {
		self.addChild(player1)
		player1.zPosition = LayerIndex.players.zPosition
		player1.position = CGPoint(x: leftLimit + 30, y: 0)
		player1.side = .left
		playerShips.append(player1)
		player1.scoreLabel.position = CGPoint(x: leftLimit + 50, y: 350)
		player1.scoreLabel.zPosition = LayerIndex.labels.rawValue
		player1.lifeLabel.position = CGPoint(x: leftLimit + 50, y: 300)
		player1.lifeLabel.zPosition = LayerIndex.labels.rawValue
		addChild(player1.scoreLabel)
		addChild(player1.lifeLabel)
		
		self.addChild(player2)
		player2.zPosition = LayerIndex.players.zPosition
		player2.position = CGPoint(x: rightLimit - 30, y:0)
		//Rotate this
		player2.zRotation = 90 * .pi / 180
		player2.side = .right
		playerShips.append(player2)
		player2.scoreLabel.position = CGPoint(x: rightLimit - 200, y: 350)
		player2.scoreLabel.zPosition = LayerIndex.labels.rawValue
		player2.lifeLabel.position = CGPoint(x: rightLimit - 200, y: 300)
		player2.lifeLabel.zPosition = LayerIndex.labels.rawValue
		addChild(player2.scoreLabel)
		addChild(player2.lifeLabel)
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
	
	func initEnemies(difficulty: EnemyShip.eDifficultyLevel) {
		let leftGroup = newEnemyGroup(rows: 12, cols: 3, spacing: CGPoint(x: -75, y: 50), offset: CGPoint(x: -75, y: 0))
		let rightGroup = newEnemyGroup(rows: 12, cols: 3, spacing: CGPoint(x: 75, y: 50), offset: CGPoint(x: 75, y: 0))
		leftGroup.forEach { $0.direction = .left }
		rightGroup.forEach { $0.direction = .right }
		let enemies = leftGroup + rightGroup
		for enemyShip in enemies {
			enemyShip.level = difficulty
			enemyShip.position.y -= (12/2 - 0.5) * 50
			addChild(enemyShip)
			enemyShips.append(enemyShip)
		}
	}
	
	func clearBullets() {
		for bullet in self.bullets {
			bullet.removeFromParent()
			if let idx = self.bullets.index(of: bullet) {
				self.bullets.remove(at: idx)
			}
		}
	}
	
	func nextLevel() {
		clearBullets()
		currentDifficulty = EnemyShip.getNextDifficulty(diff: currentDifficulty)
		levelLabel.text = "Level: \(EnemyShip.getDifficultyText(diff: currentDifficulty))"
		initEnemies(difficulty: currentDifficulty)
		if currentDifficulty == .oh_no {
			player1.fireInterval = 0.3
			player2.fireInterval = 0.3
			player1.fireVelocity = 8.0
			player2.fireVelocity = 8.0
		}
		if currentDifficulty == .Блядь {
			player1.fireInterval = 0.2
			player2.fireInterval = 0.2
			player1.fireVelocity = 10.0
			player2.fireVelocity = 10.0
		}
	}
	
	func destroyEnemy(enemy: EnemyShip) {
		if let emitter = SKEmitterNode(fileNamed: "EnemyDestroyed") {
			emitter.position = enemy.position
			emitter.setScale(0.5)
			emitter.zPosition = LayerIndex.extraEffects.rawValue
			let emitterToAdd = emitter.copy() as! SKEmitterNode
			emitterToAdd.position = enemy.position
			let addEmitterAction = SKAction.run({self.addChild(emitterToAdd)})
			let wait = SKAction.wait(forDuration: TimeInterval(1))
			let remove = SKAction.run({emitterToAdd.removeFromParent()})
			let sequence = SKAction.sequence([addEmitterAction, wait, remove])
			self.run(sequence)
		}
		enemy.removeFromParent()
		if let idx = self.enemyShips.index(of: enemy) {
			self.enemyShips.remove(at: idx)
			if self.enemyShips.count == 0 {
				//Next level!
				nextLevel()
			}
		}
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
		player.lastFired = 0
		let bullet = Bullet(shooter: player)
		bullets.append(bullet)
		addChild(bullet)
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
	
	func shiftEnemies(distance: Double) {
		for enemyShip in self.enemyShips {
			if enemyShip.direction == .left {
				enemyShip.position.x = enemyShip.position.x - CGFloat(distance)
			} else if enemyShip.direction == .right {
				enemyShip.position.x = enemyShip.position.x + CGFloat(distance)
			}
		}
	}
	
	func handleShooting(currentTime: TimeInterval) {
		for playerShip in self.playerShips {
			if playerShip.lastFired == 0 {
				playerShip.lastFired = currentTime
			}
			
			let dt = currentTime - playerShip.lastFired
			
			if Float(dt) >= playerShip.fireInterval && playerShip.firing {
				shoot(player: playerShip)
			}
		}
	}
	
	func gameOver() {
		
	}
	
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
		
		setControls()
		handleShooting(currentTime: currentTime)
		
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
				shiftEnemies(distance: enemyShip.shiftSpeed)
				break
			} else if enemyShip.bottomPoint <= CGFloat(bottomLimit) {
				enemyDir = .up
				shiftEnemies(distance: enemyShip.shiftSpeed)
				break
			}
		}
		
		//Move enemies
		for enemyShip in self.enemyShips {
			if enemyDir == .up {
				enemyShip.position.y = enemyShip.position.y + enemyShip.currentSpeed
			} else if enemyDir == .down {
				enemyShip.position.y = enemyShip.position.y - enemyShip.currentSpeed
			}
		}
		
		for bullet in self.bullets {
			for enemy in self.enemyShips {
				if bullet.intersects(enemy) {
					destroyEnemy(enemy: enemy)
					
					//Set score
					bullet.shooter.score += enemy.scoreYield
					
					bullet.removeFromParent()
					if let idx = self.bullets.index(of: bullet) {
						self.bullets.remove(at: idx)
					}
				}
			}
			for player in self.playerShips {
				if bullet.intersects(player) && bullet.shooter != player {
					//Hit player
					bullet.shooter.score += 300
					player.score -= 300
					bullet.removeFromParent()
					if let idx = self.bullets.index(of: bullet) {
						self.bullets.remove(at: idx)
					}
				}
			}
		}
		
		//Check if player is fucked
		for enemy in enemyShips {
			if enemy.rightEdge > player2.cannonPoint.x {
				//TODO
			}
		}
		
		//Move bullets
		for bullet in self.bullets {
			if bullet.shooter.side == .left {
				bullet.position = CGPoint(x: bullet.position.x + CGFloat(bullet.dirSpeed), y: bullet.position.y)
			} else if bullet.shooter.side == .right {
				bullet.position = CGPoint(x: bullet.position.x + CGFloat(bullet.dirSpeed), y: bullet.position.y)
			}
		}
		
		//Move stars
		for star in self.stars {
			star.position = CGPoint(x: star.position.x - CGFloat(star.starSpeed), y: star.position.y)
			if star.position.x < CGFloat(leftLimit - 40) {
				star.position.x = CGFloat(rightLimit + 40)
			}
		}
    }
}
