/**
 
 # Animated Number Counter
 
 The number counter is inspired from SwiftUI contentTransition(.numericText())
 
 Achraf Kassioui
 Created: 14 November 2024
 Updated: 14 November 2024
 
 */

import SwiftUI
import SpriteKit
import CoreImage.CIFilterBuiltins

struct NumberCounterView: View {
    let myScene = NumberCounterScene()
    var body: some View {
        SpriteView(
            scene: myScene
            //,debugOptions: [.showsFPS, .showsNodeCount, .showsQuadCount, .showsFields]
        )
        .ignoresSafeArea()
    }
}

#Preview {
    NumberCounterView()
}

class NumberCounterScene: SKScene {
    
    // MARK: Global Values
    
    var counter: Int = 0
    var previousTens = 0
    var previousUnits = 0
    
    let effectLayer = SKEffectNode()
    
    var emittersOfPreviousUnits: [SKEmitterNode] = []
    var emittersOfCurrentUnits: [SKEmitterNode] = []
    var emittersOfPreviousTens: [SKEmitterNode] = []
    var emittersOfCurrentTens: [SKEmitterNode] = []
    
    var labelForUnits = SKLabelNode()
    var labelForTens = SKLabelNode()
    
    var incrementButton = SKNode()
    var decrementButton = SKNode()
    
    // MARK: Scene Setup
    
    override func didMove(to view: SKView) {
        size = view.bounds.size
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = .gray
        
        createCamera()
        
        createEffectLayer()
        createParticleEmitters()
        
        createIncrementButton(view: view)
        createDecrementButton(view: view)
        createCounterLabels()
        updateCounterLabels()
    }
    
    /// The UI is attached to the camera. The camera can be zoomed in and out for prototyping purposes.
    /// Try different values of camera scale.
    func createCamera() {
        let camera = SKCameraNode()
        camera.setScale(0.5)
        camera.zPosition = 1000
        self.camera = camera
        addChild(camera)
    }
    
    // MARK: Filters
    
    func createEffectLayer() {
        let ciFilter = CIFilter.motionBlur()
        ciFilter.angle = .pi/2
        ciFilter.radius = 5
        effectLayer.shouldEnableEffects = true
        effectLayer.shouldCenterFilter = true
        effectLayer.filter = ciFilter
        addChild(effectLayer)
        
        /// Particle emitters are added as children of this effect node.
        /// Effect nodes are rendered in a different pass.
        /// If the particles have a specific blend mode, re-apply that blend mode on the effect node as well
        //effectLayer.blendMode = .add
    }
    
    // MARK: Buttons
    /// We generate a sprite node from a shape node to reduce the number of quads drawn
    func generateButtonSprite(view: SKView) -> SKSpriteNode {
        let shape = SKShapeNode(rectOf: CGSize(width: 60, height: 60), cornerRadius: 12)
        shape.position = CGPoint(x: 35, y: -100)
        shape.lineWidth = 2
        shape.strokeColor = SKColor(white: 0, alpha: 0.6)
        shape.fillColor = SKColor(white: 0, alpha: 0.3)
        
        var button = SKSpriteNode()
        if let texture = view.texture(from: shape) {
            button = SKSpriteNode(texture: texture, size: texture.size())
        }
        return button
    }
    
    func createIncrementButton(view: SKView) {
        guard let camera = camera else { return }
        incrementButton = generateButtonSprite(view: view)
        incrementButton.position = CGPoint(x: 35, y: -100)
        camera.addChild(incrementButton)
        
        let label = SKLabelNode(text: "+")
        label.fontName = "MenloBold"
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        incrementButton.addChild(label)
    }
    
    func createDecrementButton(view: SKView) {
        guard let camera = camera else { return }
        decrementButton = generateButtonSprite(view: view)
        decrementButton.position = CGPoint(x: -35, y: -100)
        camera.addChild(decrementButton)
        
        let label = SKLabelNode(text: "-")
        label.fontName = "MenloBold"
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        decrementButton.addChild(label)
    }
    
    // MARK: Particles
    
    func createParticleEmitters() {
        let fieldBitMask: UInt32 = 0x1 << 2
        let speed: CGFloat = 150
        let birthRate: CGFloat = 0
        let lifetime: CGFloat = 3
        let particleAlpha: CGFloat = 0.4 /// Default 0.4
        let particleAlphaSpeed: CGFloat = -2 /// Default -1.5
        let particleScaleSpeed: CGFloat = 0 /// Default -1.5
        
        for i in 0...9 {
            /// Create emitter for the previous units digit
            if let emitterUnits = SKEmitterNode(fileNamed: "NumberEmitter") {
                emitterUnits.particleTexture = SKTexture(imageNamed: "\(i)-SF Mono")
                emitterUnits.position = CGPoint(x: 8, y: 0)
                emitterUnits.fieldBitMask = fieldBitMask
                emitterUnits.targetNode = effectLayer
                effectLayer.addChild(emitterUnits)
                
                emitterUnits.particleSpeed = speed
                emitterUnits.particleBirthRate = birthRate
                emitterUnits.particleLifetime = lifetime
                emitterUnits.particleAlpha = particleAlpha
                emitterUnits.particleAlphaSpeed = particleAlphaSpeed
                emitterUnits.particleScaleSpeed = particleScaleSpeed
                
                emittersOfPreviousUnits.append(emitterUnits)
            }
            
            /// Create emitter for the previous tens digit
            if let emitterTens = SKEmitterNode(fileNamed: "NumberEmitter") {
                emitterTens.particleTexture = SKTexture(imageNamed: "\(i)-SF Mono")
                emitterTens.position = CGPoint(x: -8, y: 0)
                emitterTens.fieldBitMask = fieldBitMask
                emitterTens.targetNode = effectLayer
                effectLayer.addChild(emitterTens)
                
                emitterTens.particleSpeed = speed
                emitterTens.particleBirthRate = birthRate
                emitterTens.particleLifetime = lifetime
                emitterTens.particleAlpha = particleAlpha
                emitterTens.particleAlphaSpeed = particleAlphaSpeed
                emitterTens.particleScaleSpeed = particleScaleSpeed
                
                emittersOfPreviousTens.append(emitterTens)
            }
            
            /// Create emitter for the current units digit
            if let emitterUnitsCurrent = SKEmitterNode(fileNamed: "NumberEmitter") {
                emitterUnitsCurrent.particleTexture = SKTexture(imageNamed: "\(i)-SF Mono")
                emitterUnitsCurrent.position = CGPoint(x: 8, y: 10) /// Start above the units label
                emitterUnitsCurrent.fieldBitMask = fieldBitMask
                emitterUnitsCurrent.targetNode = effectLayer
                effectLayer.addChild(emitterUnitsCurrent)
                
                emitterUnitsCurrent.particleSpeed = speed
                emitterUnitsCurrent.particleBirthRate = birthRate
                emitterUnitsCurrent.particleLifetime = lifetime
                emitterUnitsCurrent.particleAlpha = particleAlpha
                emitterUnitsCurrent.particleAlphaSpeed = particleAlphaSpeed
                emitterUnitsCurrent.particleScaleSpeed = particleScaleSpeed
                //emitterUnitsCurrent.particleScale = 1.5
                
                emittersOfCurrentUnits.append(emitterUnitsCurrent)
            }
            
            /// Create emitter for the current tens digit
            if let emitterTensCurrent = SKEmitterNode(fileNamed: "NumberEmitter") {
                emitterTensCurrent.particleTexture = SKTexture(imageNamed: "\(i)-SF Mono")
                emitterTensCurrent.position = CGPoint(x: -8, y: 10) /// Start above the tens label
                emitterTensCurrent.fieldBitMask = fieldBitMask
                emitterTensCurrent.targetNode = effectLayer
                effectLayer.addChild(emitterTensCurrent)
                
                emitterTensCurrent.particleSpeed = speed
                emitterTensCurrent.particleBirthRate = birthRate
                emitterTensCurrent.particleLifetime = lifetime
                emitterTensCurrent.particleAlpha = particleAlpha
                emitterTensCurrent.particleAlphaSpeed = particleAlphaSpeed
                emitterTensCurrent.particleScaleSpeed = particleScaleSpeed
                //emitterTensCurrent.particleScale = 1.5
                
                emittersOfCurrentTens.append(emitterTensCurrent)
            }
        }
    }
    
    // MARK: Labels
    
    let labelOriginalPositionY: CGFloat = -11
    
    func createCounterLabels() {
        labelForUnits.position = CGPoint(x: 8, y: labelOriginalPositionY)
        addChild(labelForUnits)
        
        labelForTens.position = CGPoint(x: -8, y: labelOriginalPositionY)
        addChild(labelForTens)
    }
    
    // MARK: The Counter
    
    /// Define attributes for NSAttributedString in order to use the SF Mono font in SpriteKit
    let labelAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.monospacedSystemFont(ofSize: 25, weight: .bold),
        .foregroundColor: SKColor.white
    ]
    
    func updateCounterLabels() {
        /// Clamp counter between 0 and 99
        counter = max(0, min(99, counter))
        
        /// Separate the counter into tens and units
        let units = counter % 10
        let tens = counter / 10
        
        /// Determine if we are incrementing or decrementing
        let isIncrementing = counter > (previousTens * 10 + previousUnits)
        
        /// Set attributed text for the labels. This will update the label text.
        /// Removing these lines will hide the labels.
        labelForUnits.attributedText = NSAttributedString(string: "\(units)", attributes: labelAttributes)
        labelForTens.attributedText = NSAttributedString(string: "\(tens)", attributes: labelAttributes)
        
        /// Create actions and effects based on incrementing or decrementing
        let labelAnimation = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0),
            SKAction.moveTo(y: isIncrementing ? labelOriginalPositionY+15 : labelOriginalPositionY-15, duration: 0),
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.05),
                SKAction.moveTo(y: isIncrementing ? labelOriginalPositionY-3 : labelOriginalPositionY+3, duration: 0.1)
            ]),
            SKAction.moveTo(y: labelOriginalPositionY, duration: 0.1)
        ])
        labelAnimation.timingMode = .easeInEaseOut
        
        let emissionAngle: CGFloat = isIncrementing ? -.pi/2 : .pi/2
        let previousEmitterPositionY: CGFloat = isIncrementing ? -5 : 5
        let currentEmitterPositionY: CGFloat = isIncrementing ? 20 : -20
        
        /// Animate only changed labels
        if units != previousUnits {
            labelForUnits.removeAction(forKey: "labelAnimation")
            labelForUnits.run(labelAnimation, withKey: "labelAnimation")
            
            let previousUnitsEmitter = emittersOfPreviousUnits[previousUnits]
            previousUnitsEmitter.position.y = previousEmitterPositionY
            previousUnitsEmitter.particleBirthRate = 1
            previousUnitsEmitter.emissionAngle = emissionAngle
            
            let currentUnitsEmitter = emittersOfCurrentUnits[units]
            currentUnitsEmitter.position.y = currentEmitterPositionY
            currentUnitsEmitter.particleBirthRate = 1
            currentUnitsEmitter.emissionAngle = emissionAngle
            
            /// Stop particle emission
            run(SKAction.wait(forDuration: 0.1)) {
                previousUnitsEmitter.particleBirthRate = 0
                currentUnitsEmitter.particleBirthRate = 0
            }
        }
        if tens != previousTens {
            labelForTens.removeAction(forKey: "labelAnimation")
            labelForTens.run(labelAnimation, withKey: "labelAnimation")
            
            let previousTensEmitter = emittersOfPreviousTens[previousTens]
            previousTensEmitter.position.y = previousEmitterPositionY
            previousTensEmitter.particleBirthRate = 1
            previousTensEmitter.emissionAngle = emissionAngle
            
            let currentTensEmitter = emittersOfCurrentTens[tens]
            currentTensEmitter.position.y = currentEmitterPositionY
            currentTensEmitter.particleBirthRate = 1
            currentTensEmitter.emissionAngle = emissionAngle
            
            run(SKAction.wait(forDuration: 0.1)) {
                previousTensEmitter.particleBirthRate = 0
                currentTensEmitter.particleBirthRate = 0
            }
        }
        
        /// Update previous values
        previousTens = tens
        previousUnits = units
    }
    
    // MARK: Touch
    
    func animateButton(_ node: SKNode) {
        node.removeAction(forKey: "buttonPressedAnimation")
        node.run(SKAction.sequence([
            SKAction.scale(to: 0.9, duration: 0.05),
            SKAction.scale(to: 1, duration: 0.05)
        ]), withKey: "buttonPressedAnimation")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let camera = camera else { return }
        
        /// Convert touch location to camera's coordinate space
        let locationInCamera = touch.location(in: camera)
        
        if incrementButton.contains(locationInCamera) {
            counter += 1
            updateCounterLabels()
            animateButton(incrementButton)
        } else if decrementButton.contains(locationInCamera) {
            counter -= 1
            updateCounterLabels()
            animateButton(decrementButton)
        }
    }
}
