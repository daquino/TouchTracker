import UIKit

class DrawView: UIView {
    var currentLines = [NSValue:Line]()
    var finishedLines = [Line]()
    var currentCircle: Circle?
    var finishedCircles = [Circle]()
    var currentCircleBounds = [NSValue:CGPoint]()
    @IBInspectable var finishedLineColor: UIColor = UIColor.blackColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var currentLineColor: UIColor = UIColor.redColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var lineThickness: CGFloat = 10 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    func strokeLine(line: Line) {
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = CGLineCap.Round
        path.moveToPoint(line.begin)
        path.addLineToPoint(line.end)
        path.stroke()
    }
    
    func strokeCircle(circle: Circle) {
        print("Drawing circle")
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = CGLineCap.Round
        path.addArcWithCenter(circle.center, radius: circle.radius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        path.stroke()
    }
    
    
    override func drawRect(rect: CGRect) {
        finishedLineColor.setStroke()
        //        for line in finishedLines {
        //            strokeLine(line)
        //        }
        for circle in finishedCircles {
            strokeCircle(circle)
        }
        
        currentLineColor.setStroke()
        //        for (_, line) in currentLines {
        //            strokeLine(line)
        //        }
        if let circle = currentCircle {
            strokeCircle(circle)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print(#function)
        
        for touch in touches {
            let location = touch.locationInView(self)
            let newLine = Line(begin: location, end: location)
            let key = NSValue(nonretainedObject: touch)
            currentLines[key] = newLine
        }
        
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            if currentCircleBounds.count < 2 {
                let location = touch.locationInView(self)
                currentCircleBounds[key] = location
            }
            if currentCircleBounds.count == 2 {
                currentCircle = Circle(center: getCenter(), radius: getRadius())
            }
        }
        
        setNeedsDisplay()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print(#function)
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = touch.locationInView(self)
        }
        
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            if currentCircleBounds.count == 2 {
                let location = touch.locationInView(self)
                currentCircleBounds[key] = location
                currentCircle?.center = getCenter()
                currentCircle?.radius = getRadius()
            }
        }
        setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print(#function)
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            if var line = currentLines[key] {
                line.end = touch.locationInView(self)
                finishedLines.append(line)
                currentLines.removeValueForKey(key)
            }
        }
        
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            if currentCircleBounds.count == 2 {
                let location = touch.locationInView(self)
                if let circle = currentCircle {
                    currentCircleBounds[key] = location
                    currentCircle?.center = getCenter()
                    currentCircle?.radius = getRadius()
                    finishedCircles.append(circle)
                }
            }
        }
        currentCircle = nil
        currentCircleBounds.removeAll()
        setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        print(#function)
        currentLines.removeAll()
        setNeedsDisplay()
    }
    
    func getCenter() -> CGPoint {
        let circleBounds = Array(currentCircleBounds.values)
        let bound1 = circleBounds[0]
        let bound2 = circleBounds[1]
        return CGPoint(x: (bound2.x+bound1.x)/2, y: (bound2.y+bound1.y)/2)
    }
    
    func getRadius() -> CGFloat {
        let circleBounds = Array(currentCircleBounds.values)
        let bound1 = circleBounds[0]
        let bound2 = circleBounds[1]
        return sqrt(pow(bound2.x-bound1.x, 2) + pow(bound2.y-bound1.y, 2)) / 2
    }
    
    func applyCurrentLineStrokeColor(line: Line) {
        let angle = getLineAngle(line)
        if angle > 0 && angle <= 90 {
            UIColor.darkGrayColor().setStroke()
        }
        else if angle > 90 && angle <= 180 {
            UIColor.cyanColor().setStroke()
        }
        else if angle > 180 && angle <= 270 {
            UIColor.brownColor().setStroke()
        }
        else {
            UIColor.greenColor().setStroke()
        }
        print("Angle of line = \(angle)")
    }
    
    func getLineAngle(line: Line) -> Double {
        return Double(atan2(line.end.y - line.begin.y, line.end.x - line.end.y)) * 180 / M_PI
    }
}