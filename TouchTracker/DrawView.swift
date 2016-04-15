import UIKit

class DrawView: UIView {
    var currentLines = [NSValue:Line]()
    var finishedLines = [Line]()
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
    
    override func drawRect(rect: CGRect) {
        finishedLineColor.setStroke()
        for line in finishedLines {
            strokeLine(line)
        }
        
        for (_, line) in currentLines {
            applyCurrentLineStrokeColor(line)
            strokeLine(line)
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
            setNeedsDisplay()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print(#function)
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = touch.locationInView(self)
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
        setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        print(#function)
        currentLines.removeAll()
        setNeedsDisplay()
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