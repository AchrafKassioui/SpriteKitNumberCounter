/**
 
 # Animated Number Counter
 
 Achraf Kassioui
 Created: 13 November 2024
 Updated: 14 November 2024
 
 */

import SwiftUI
import SpriteKit
import CoreImage.CIFilterBuiltins

struct FirstVersionView: View {
    let myScene = FirstNumberCounterScene()
    var body: some View {
        SpriteView(
            scene: myScene
            //,debugOptions: [.showsFPS, .showsNodeCount, .showsQuadCount, .showsFields]
        )
        .ignoresSafeArea()
    }
}

#Preview {
    FirstVersionView()
}

class FirstNumberCounterScene: SKScene {
    
    var counter: Int = 0
    var counterlabel = SKLabelNode()
    
    var previousTens = 0
    var previousUnits = 0
    
    let effectLayer = SKEffectNode()
    var digitEmittersUnits: [SKEmitterNode] = []
    var digitEmittersTens: [SKEmitterNode] = []
    var incrementButton = SKShapeNode()
    var decrementButton = SKShapeNode()
    
    override func didMove(to view: SKView) {
        size = view.bounds.size
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = .gray
        
        effectLayer.shouldEnableEffects = true
        effectLayer.shouldCenterFilter = true
        effectLayer.blendMode = .add
        let filter = CIFilter.motionBlur()
        filter.radius = 8
        filter.angle = .pi/2
        effectLayer.filter = filter
        addChild(effectLayer)
        
        createParticleEmitters()
        createIncrementButton()
        createDecrementButton()
        createCounterLabel()
        createFields()
        
        updateParticleEmitters()
    }
    
    // MARK: Fields
    
    func createFields() {
        let field = SKFieldNode.vortexField()
        field.categoryBitMask = 0x1 << 2
        field.strength = 10
        addChild(field)
    }
    
    // MARK: Particles
    
    func createParticleEmitters() {
        for i in 0...9 {
            // Create and configure emitter for units
            if let emitterUnits = SKEmitterNode(fileNamed: "NumberEmitter") {
                emitterUnits.particleTexture = SKTexture(imageNamed: "\(i)-SF Mono")
                emitterUnits.position = CGPoint(x: 8, y: 0)
                emitterUnits.fieldBitMask = 0x1 << 2
                emitterUnits.targetNode = effectLayer
                effectLayer.addChild(emitterUnits)
                
                emitterUnits.particleBirthRate = 0
                emitterUnits.particleLifetime = 2
                emitterUnits.particleAlpha = 0.4
                emitterUnits.particleAlphaSpeed = -0.5
                emitterUnits.particleScaleSpeed = -0
                
                digitEmittersUnits.append(emitterUnits)
            }
            
            // Create and configure emitter for tens
            if let emitterTens = SKEmitterNode(fileNamed: "NumberEmitter") {
                emitterTens.particleTexture = SKTexture(imageNamed: "\(i)-SF Mono")
                emitterTens.position = CGPoint(x: -8, y: 0)
                emitterTens.fieldBitMask = 0x1 << 2
                emitterTens.targetNode = effectLayer
                effectLayer.addChild(emitterTens)
                
                emitterTens.particleBirthRate = 0
                emitterTens.particleLifetime = 2
                emitterTens.particleAlpha = 0.4
                emitterTens.particleScale = 1.5
                emitterTens.particleAlphaSpeed = -0.5
                
                digitEmittersTens.append(emitterTens)
            }
        }
    }
    
    // MARK: Buttons
    
    func createIncrementButton() {
        incrementButton = SKShapeNode(rectOf: CGSize(width: 60, height: 60), cornerRadius: 30)
        incrementButton.position = CGPoint(x: 0, y: 100)
        incrementButton.lineWidth = 2
        incrementButton.strokeColor = SKColor(white: 0, alpha: 0.6)
        incrementButton.fillColor = SKColor(white: 0, alpha: 0.3)
        addChild(incrementButton)
        
        let label = SKLabelNode(text: "+")
        label.fontName = "MenloBold"
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        incrementButton.addChild(label)
    }
    
    func createDecrementButton() {
        decrementButton = SKShapeNode(rectOf: CGSize(width: 60, height: 60), cornerRadius: 30)
        decrementButton.position = CGPoint(x: 0, y: -100)
        decrementButton.lineWidth = 2
        decrementButton.strokeColor = SKColor(white: 0, alpha: 0.6)
        decrementButton.fillColor = SKColor(white: 0, alpha: 0.3)
        addChild(decrementButton)
        
        let label = SKLabelNode(text: "-")
        label.fontName = "MenloBold"
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        decrementButton.addChild(label)
    }
    
    // MARK: Counter
    
    func createCounterLabel() {
        counterlabel.zPosition = 10
        addChild(counterlabel)
    }
    
    func updateParticleEmitters() {
        // Clamp counter between 0 and 99
        counter = max(0, min(99, counter))
        
        // Format counter as a two-digit string
        let formattedCounter = String(format: "%02d", counter)
        
        // Display the counter label
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 25, weight: .bold),
            .foregroundColor: SKColor.white,
        ]
        
        counterlabel.verticalAlignmentMode = .center
        counterlabel.horizontalAlignmentMode = .center
        counterlabel.attributedText = NSAttributedString(string: formattedCounter, attributes: attributes)
        
        // Separate the counter into tens and units
        let tens = counter / 10
        let units = counter % 10
        
        // Determine if we are incrementing or decrementing
        let isIncrementing = counter > (previousTens * 10 + previousUnits)
        
        // Adjust effects based on incrementing or decrementing
        let particleSpeed: CGFloat = isIncrementing ? -300 : 300
        let colorSequence: SKKeyframeSequence = isIncrementing ? SKKeyframeSequence(
            keyframeValues: [SKColor.white, SKColor.systemGreen],
            times: [0.0, 0.1]
        ) : SKKeyframeSequence(
            keyframeValues: [SKColor.white, SKColor.systemYellow],
            times: [0.0, 0.1]
        )
        let popUpAction = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.1),
            SKAction.scale(to: 1, duration: 0.1)
        ])
        let popDownAction = SKAction.sequence([
            SKAction.scale(to: 0.7, duration: 0.1),
            SKAction.scale(to: 1, duration: 0.1)
        ])
        counterlabel.removeAllActions()
        counterlabel.run(isIncrementing ? popUpAction : popDownAction)
        
        // Check if units changed and trigger corresponding emitter with previous value
        if units != previousUnits {
            let previousUnitsEmitter = digitEmittersUnits[previousUnits]
            previousUnitsEmitter.particleBirthRate = 1
            previousUnitsEmitter.particleSpeed = particleSpeed
            previousUnitsEmitter.particleColorSequence = colorSequence
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                previousUnitsEmitter.particleBirthRate = 0
            }
        }
        
        // Check if tens changed and trigger corresponding emitter with previous value
        if tens != previousTens {
            let previousTensEmitter = digitEmittersTens[previousTens]
            previousTensEmitter.particleBirthRate = 1
            previousTensEmitter.particleSpeed = particleSpeed
            previousTensEmitter.particleColorSequence = colorSequence
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                previousTensEmitter.particleBirthRate = 0
            }
        }
        
        // Update previous values
        previousTens = tens
        previousUnits = units
    }
    
    // MARK: Touch
    
    func animateButton(_ node: SKNode) {
        node.removeAllActions()
        let action1 = SKAction.scale(to: 0.9, duration: 0.05)
        let action2 = SKAction.scale(to: 1, duration: 0.05)
        let sequence = SKAction.sequence([action1, action2])
        node.run(sequence)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if incrementButton.contains(location) {
            counter += 1
            updateParticleEmitters()
            animateButton(incrementButton)
        } else if decrementButton.contains(location) {
            counter += -1
            updateParticleEmitters()
            animateButton(decrementButton)
        }
    }
}
