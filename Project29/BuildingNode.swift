//
//  BuildingNode.swift
//  Project29
//
//  Created by Robert Hoover on 2023-05-19.
//

import SpriteKit

class BuildingNode: SKSpriteNode {

    var currentImage: UIImage!
    
    func setup() {
        // set name, texture, and physics for the building
        name = "building"
        
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        
        configurePhysics()
    }
    
    func configurePhysics() {
        // set up per-pixel physics for the sprite's current texture
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        // keep the building fixed in space
        physicsBody?.isDynamic = false
        // what type the thing is (a building)
        physicsBody?.categoryBitMask = CollisionType.building.rawValue
        // we want to know when a building has been hit by a banana
        physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
    }
    
    func drawBuilding(size: CGSize) -> UIImage {
        // create a new core graphics context the size of the building.
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            // fill it with a rectangle that's one of three colors.
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            let color: UIColor
            
            switch Int.random(in: 0...2) {
            case 0:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            
            // fill in the building with our color
            color.setFill()
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)
            
            // draw windows all over the building in one of two colors (yellow or gray)
            let lightOnColor = UIColor(hue: 0.19, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)

            // stride lets you loop from one number to another with a specific interval.
            // stride has two variants:
            // 1. stride(from:to:by) which counts up to, but excluding, the 'to' parameter
            // 2. stride(from:through:by) which counts up to and including the 'through' parameter.
            for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
                for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                    // randomly choose to show a window with the light on or off
                    if Bool.random() {
                        lightOnColor.setFill()
                    } else {
                        lightOffColor.setFill()
                    }
                    
                    ctx.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))
                }
            }
            
            // pull out the result as a UIImage and return it for use elsewhere.
            
        }
        
        return img
    }
    
    func hit(at point: CGPoint) {
        // figure out where the building was hit.
        // note: SpriteKit positions things from the center
        // and CoreGraphics from the bottom left.
        // abs() takes a number and returns the positive value of the number.
        let convertedPoint = CGPoint(x: point.x + size.width / 2, y: abs(point.y - (size.height / 2)))
        
        // create a new CoreGraphics context the same size
        // as our current sprite.
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            // draw the current building image into the context.
            currentImage.draw(at: .zero)
            
            // create an ellipse at the collision point. the exact
            // coordinates will be 32 points up and to the left
            // of the collision and 64x64 in size (centered on
            // the impact point).
            ctx.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
            
            // set the blend mode of the context to .clear then
            // draw the ellipse which will cut an ellipse out
            // from the image.
            ctx.cgContext.setBlendMode(.clear)
            ctx.cgContext.drawPath(using: .fill)
        }
        
        // convert the contents of the CoreGraphics context back
        // to a UIImage (which is saved in the 'currentImage'
        // property) so we can use it for the next time the
        // building is hit.
        texture = SKTexture(image: img)
        currentImage = img
        
        
        // call configurePhysics() again so that SpriteKit will
        // recalculate the per-pixel physics for our damaged
        // building.
        configurePhysics()
    }
    
}
