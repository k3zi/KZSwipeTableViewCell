//
//  KZSwipeTableViewCell.swift
//  Convenient UITableViewCell subclass that implements a swippable content to trigger actions
//  Swift Port of MCSwipeTableViewCell
//
//  Created by Kesi Maduka on 2/7/16.
//  LICENSE: MIT
//

import UIKit

enum KZSwipeTableViewCellDirection {
    case Left
    case Right
    case Center
}

public enum KZSwipeTableViewCellState {
    case None
    case State1
    case State2
    case State3
    case State4
}

public enum KZSwipeTableViewCellMode {
    case None
    case Exit
    case Switch
}

public typealias KZSwipeCompletionBlock = (cell: KZSwipeTableViewCell, state: KZSwipeTableViewCellState, mode: KZSwipeTableViewCellMode) -> Void

public class KZSwipeTableViewCell: UITableViewCell {
    let _panGestureRecognizer = UIPanGestureRecognizer()
    var _contentScreenshotView: UIImageView?
    var _colorIndicatorView: UIView?
    var _slidingView: UIView?
    var _direction = KZSwipeTableViewCellDirection.Center
    
    var _isExited = false
    var settings_damping = CGFloat(0.6)
    var settings_velocity = CGFloat(0.9)
    var settings_animationDuration = NSTimeInterval(0.4)
    var currentPercentage = CGFloat(0)
    
    var settings_firstTrigger = CGFloat(0.15)
    var settings_secondTrigger = CGFloat(0.47)
    var settings_startImmediately = false
    
    var defaultColor = UIColor.whiteColor()
    
    var _view1: UIView?
    var _view2: UIView?
    var _view3: UIView?
    var _view4: UIView?
    
    var _color1: UIColor?
    var _color2: UIColor?
    var _color3: UIColor?
    var _color4: UIColor?
    
    var _modeForState1 = KZSwipeTableViewCellMode.None
    var _modeForState2 = KZSwipeTableViewCellMode.None
    var _modeForState3 = KZSwipeTableViewCellMode.None
    var _modeForState4 = KZSwipeTableViewCellMode.None
    
    var completionBlock1: KZSwipeCompletionBlock?
    var completionBlock2: KZSwipeCompletionBlock?
    var completionBlock3: KZSwipeCompletionBlock?
    var completionBlock4: KZSwipeCompletionBlock?
    
    var _activeView: UIView?
    
    required override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        _panGestureRecognizer.addTarget(self, action: Selector("handlePanGestureRecognizer:"))
        self.addGestureRecognizer(_panGestureRecognizer)
        _panGestureRecognizer.delegate = self
    }
    
    //MARK: Init
    
    //MARK: Prepare For Reuse
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        uninstallSwipingView()
        _isExited = false
        
        _view1 = nil
        _view2 = nil
        _view3 = nil
        _view4 = nil
        
        _color1 = nil
        _color2 = nil
        _color3 = nil
        _color4 = nil
        
        _modeForState1 = .None
        _modeForState2 = .None
        _modeForState3 = .None
        _modeForState4 = .None
        
        completionBlock1 = nil
        completionBlock2 = nil
        completionBlock3 = nil
        completionBlock4 = nil
    }
    
    //MARK: View Manipulation
    
    func setupSwipingView() {
        if _contentScreenshotView != nil {
            return
        }
        
        let contentViewScreenshotImage = imageWithView(self)
        
        let colorIndicatorView = UIView(frame: self.bounds)
        colorIndicatorView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        colorIndicatorView.backgroundColor = defaultColor
        self.addSubview(colorIndicatorView)
        
        let slidingView = UIView()
        slidingView.contentMode = .Center
        colorIndicatorView.addSubview(slidingView)
        
        let contentScreenshotView = UIImageView(image: contentViewScreenshotImage)
        self.addSubview(contentScreenshotView)
        
        _slidingView = slidingView
        _colorIndicatorView = colorIndicatorView
        _contentScreenshotView = contentScreenshotView
    }
    
    func uninstallSwipingView() {
        if let contentScreenshotView = _contentScreenshotView {
            if let slidingView = _slidingView {
                slidingView.removeFromSuperview()
                _slidingView = nil
            }
            
            if let colorIndicatorView = _colorIndicatorView {
                colorIndicatorView.removeFromSuperview()
                _colorIndicatorView = nil
            }
            
            contentScreenshotView.removeFromSuperview()
            _contentScreenshotView = nil
        }
    }
    
    func setViewOfSlidingView(slidingView: UIView) {
        if let parentSlidingView = _slidingView {
            parentSlidingView.subviews.forEach({ $0.removeFromSuperview() })
            parentSlidingView.addSubview(slidingView)
        }
    }
    
    //MARK: Swipe Config
    
    public func setSwipeGestureWith(view: UIView, color: UIColor, mode: KZSwipeTableViewCellMode = .None, state: KZSwipeTableViewCellState = .State1, completionBlock: KZSwipeCompletionBlock) {
        if state == .State1 {
            completionBlock1 = completionBlock
            _color1 = color
            _view1 = view
            _modeForState1 = mode
        }
        
        if state == .State2 {
            completionBlock2 = completionBlock
            _color2 = color
            _view2 = view
            _modeForState2 = mode
        }
        
        if state == .State3 {
            completionBlock3 = completionBlock
            _color3 = color
            _view3 = view
            _modeForState3 = mode
        }
        
        if state == .State4 {
            completionBlock4 = completionBlock
            _color4 = color
            _view4 = view
            _modeForState4 = mode
        }
    }
    
    //MARK: Gestures
    
    func handlePanGestureRecognizer(gesture: UIPanGestureRecognizer) {
        if _isExited {
            return
        }
        
        let translation = gesture.translationInView(self)
        let velocity = gesture.velocityInView(self)
        let animationDuration = animationDurationWithVelocity(velocity)
        var percentage = CGFloat(0)
        if let contentScreenshotView = _contentScreenshotView {
            percentage = percentageWithOffset(CGRectGetMinX(contentScreenshotView.frame), relativeToWidth: CGRectGetWidth(self.bounds))
            _direction = directionWithPercentage(percentage)
        }
        
        //------------------ ----------------\\
        
        if gesture.state == .Began || gesture.state == .Changed {
            setupSwipingView()
            
            if let contentScreenshotView = _contentScreenshotView {
                if (canTravelTo(percentage)) {
                    contentScreenshotView.center = CGPoint(x: contentScreenshotView.center.x + translation.x, y: contentScreenshotView.center.y)
                    animateWithOffset(CGRectGetMinX(contentScreenshotView.frame))
                    gesture.setTranslation(CGPoint.zero, inView: self)
                }
            }
        } else if gesture.state == .Ended || gesture.state == .Cancelled {
            _activeView = self.viewWithPercentage(percentage)
            currentPercentage = percentage
            
            let state = stateWithPercentage(percentage)
            var mode = KZSwipeTableViewCellMode.None
            
            if state == .State1 {
                mode = _modeForState1
            } else if state == .State2 {
                mode = _modeForState2
            } else if state == .State2 {
                mode = _modeForState3
            } else if state == .State4 {
                mode = _modeForState4
            }
            
            if mode == .Exit && _direction != .Center {
                self.moveWithDuration(animationDuration, direction: _direction)
            } else {
                self.swipeToOriginWithCompletion({ () -> Void in
                    self.executeCompletionBlock()
                })
            }
        }
    }
    
    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let point = gesture.velocityInView(self)
            
            if fabs(point.x) > fabs(point.y) {
                if point.x > 0 && _modeForState1 == .None && _modeForState2 == .None {
                    return false
                }
                
                return true
            }
        }
        
        return false
    }
    
    //MARK: Movement
    
    func animateWithOffset(offset: CGFloat) {
        let percentage = percentageWithOffset(offset, relativeToWidth: CGRectGetWidth(self.bounds))
        
        if let view = viewWithPercentage(percentage) {
            setViewOfSlidingView(view)
            if let slidingView = _slidingView {
                slidingView.alpha = alphaWithPercentage(percentage)
            }
            slideViewWithPercentage(percentage, view: view, isDragging: true)
        }
        
        let color = colorWithPercentage(percentage)
        if let colorIndicatorView = _colorIndicatorView {
            colorIndicatorView.backgroundColor = color
        }
    }
    
    func slideViewWithPercentage(percentage: CGFloat, view: UIView?, isDragging: Bool) {
        guard let view = view else {
            return
        }
        
        var position = CGPoint.zero
        position.y = CGRectGetHeight(self.bounds) / 2.0
        
        if isDragging {
            if percentage >= 0 && percentage < settings_firstTrigger {
                position.x = offsetWithPercentage(settings_firstTrigger/2, relativeToWidth: CGRectGetWidth(self.bounds))
            } else if percentage >= settings_firstTrigger {
                position.x = offsetWithPercentage(percentage - (settings_firstTrigger/2), relativeToWidth: CGRectGetWidth(self.bounds))
            } else if percentage < 0 && percentage >= -settings_firstTrigger {
                position.x = CGRectGetWidth(self.bounds) - offsetWithPercentage(settings_firstTrigger/2, relativeToWidth: CGRectGetWidth(self.bounds))
            } else if percentage < -settings_firstTrigger {
                position.x = CGRectGetWidth(self.bounds) + offsetWithPercentage(percentage + (settings_firstTrigger/2), relativeToWidth: CGRectGetWidth(self.bounds))
            }
        } else {
            if _direction == .Right {
                position.x = offsetWithPercentage(settings_firstTrigger/2, relativeToWidth: CGRectGetWidth(self.bounds))
            } else if _direction == .Left {
                position.x = CGRectGetWidth(self.bounds) - offsetWithPercentage(settings_firstTrigger/2, relativeToWidth: CGRectGetWidth(self.bounds))
            } else {
                return
            }
        }
        
        let activeViewSize = view.bounds.size
        var activeViewFrame = CGRect(x: position.x - activeViewSize.width / 2.0, y: position.y - activeViewSize.height / 2.0, width: activeViewSize.width, height: activeViewSize.height)
        activeViewFrame = CGRectIntegral(activeViewFrame)
        
        if let slidingView = _slidingView {
            slidingView.frame = activeViewFrame
        }
    }
    
    func moveWithDuration(duration: NSTimeInterval, direction: KZSwipeTableViewCellDirection) {
        _isExited = true
        
        var origin = CGFloat(0)
        if direction == .Left {
            origin = -CGRectGetWidth(self.bounds)
        } else if direction == .Right {
            origin = CGRectGetWidth(self.bounds)
        }
        
        guard let contentScreenshotView = _contentScreenshotView else {
            return
        }
        
        guard let slidingView = _slidingView else {
            return
        }
        
        let percentage = percentageWithOffset(origin, relativeToWidth: CGRectGetWidth(self.bounds))
        var frame = contentScreenshotView.frame
        frame.origin.x = origin
        
        UIView.animateWithDuration(duration, delay: 0, options: [.CurveEaseOut, .AllowUserInteraction], animations: { () -> Void in
            contentScreenshotView.frame = frame
            slidingView.alpha = 0
            self.slideViewWithPercentage(percentage, view: self._activeView, isDragging: true)
            }) { (finished) -> Void in
                self.executeCompletionBlock()
        }
    }
    
    func swipeToOriginWithCompletion(completion: (()->Void)?) {
        UIView.animateWithDuration(settings_animationDuration, delay: 0.0, usingSpringWithDamping: settings_damping, initialSpringVelocity: settings_velocity, options: [.CurveEaseInOut], animations: { () -> Void in
            if let contentScreenshotView = self._contentScreenshotView {
                contentScreenshotView.frame.origin.x = 0
            }
            if let colorIndicatorView = self._colorIndicatorView {
                colorIndicatorView.backgroundColor = self.defaultColor
            }
            
            if let slidingView = self._slidingView {
                slidingView.alpha = 0.0
            }
            
            self.slideViewWithPercentage(0, view: self._activeView, isDragging: false)
            }) { (finished) -> Void in
                self._isExited = false
                self.uninstallSwipingView()
                
                if let completion = completion {
                    completion()
                }
        }
    }
    
    func imageWithView(view: UIView) -> UIImage {
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale)
        
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.renderInContext(context)
            let image =  UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        
        return UIImage()
    }
    
    func canTravelTo(percentage: CGFloat) -> Bool {
        if _modeForState1 == .None && _modeForState2 == .None {
            if percentage > 0.0 {
                return false
            }
        }
        
        if _modeForState3 == .None && _modeForState4 == .None {
            if percentage < 0.0 {
                return false
            }
        }
        
        return true
    }
    
    //MARK: Percentage
    
    func offsetWithPercentage(percentage: CGFloat, relativeToWidth width: CGFloat) -> CGFloat{
        var offset = percentage * width
        if offset < -width {
            offset = -width
        } else if offset > width {
            offset = width
        }
        
        return offset
    }
    
    func percentageWithOffset(offset: CGFloat, relativeToWidth width: CGFloat) -> CGFloat {
        var percentage = offset/width
        if percentage < -1.0 {
            percentage = -1.0
        } else if percentage > 1.0 {
            percentage = 1.0
        }
        
        return percentage
    }
    
    func animationDurationWithVelocity(velocity: CGPoint) -> NSTimeInterval {
        let width = CGRectGetWidth(self.bounds)
        let animationDurationDiff = CGFloat(0.1 - 0.25)
        var horizontalVelocity = velocity.x
        
        if horizontalVelocity < -width {
            horizontalVelocity = -width
        } else if horizontalVelocity > width {
            horizontalVelocity = width
        }
        
        return (0.1 + 0.25) - NSTimeInterval(((horizontalVelocity / width) * animationDurationDiff));
    }
    
    func directionWithPercentage(percentage: CGFloat) -> KZSwipeTableViewCellDirection {
        if percentage < 0 {
            return .Left
        } else if percentage > 0 {
            return .Right
        }
        
        return .Center
    }
    
    func viewWithPercentage(percentage: CGFloat) -> UIView? {
        var view: UIView?
        
        if percentage >= 0 && _modeForState1 != .None {
            view = _view1
        }
        
        if percentage >= settings_secondTrigger && _modeForState2 != .None {
            view = _view2
        }
        
        if percentage < 0 && _modeForState3 != .None {
            view = _view3
        }
        
        if percentage <= -settings_secondTrigger && _modeForState4 != .None {
            view = _view4
        }
        
        return view
    }
    
    func alphaWithPercentage(percentage: CGFloat) -> CGFloat {
        var alpha = CGFloat(1.0)
        
        if percentage >= 0 && percentage < settings_firstTrigger {
            alpha = percentage / settings_firstTrigger
        } else if percentage < 0 && percentage > -settings_firstTrigger {
            alpha = fabs(percentage / settings_firstTrigger)
        } else {
            alpha = 1.0
        }
        
        return alpha;
    }
    
    func colorWithPercentage(percentage: CGFloat) -> UIColor {
        var color = defaultColor
        
        if (percentage > settings_firstTrigger || (settings_startImmediately && percentage > 0)) && _modeForState1 != .None {
            color = _color1 ?? color
        }
        
        if percentage > settings_secondTrigger && _modeForState2 != .None {
            color = _color2 ?? color
        }
        
        if (percentage < -settings_firstTrigger || (settings_startImmediately && percentage < 0)) && _modeForState3 != .None {
            color = _color3 ?? color
        }
        
        if percentage <= -settings_secondTrigger && _modeForState4 != .None {
            color = _color4 ?? color
        }
        
        return color
    }
    
    func stateWithPercentage(percentage: CGFloat) -> KZSwipeTableViewCellState {
        var state = KZSwipeTableViewCellState.None
        
        if percentage > settings_firstTrigger && _modeForState1 != .None {
            state = .State1
        }
        
        if percentage >= settings_secondTrigger && _modeForState2 != .None {
            state = .State2
        }
        
        if percentage <= -settings_firstTrigger && _modeForState3 != .None {
            state = .State3
        }
        
        if percentage <= -settings_secondTrigger && _modeForState4 != .None {
            state = .State4
        }
        
        return state
    }
    
    class func viewWithImageName(name: String) -> UIView {
        let image = UIImage(named: name)
        let imageView = UIImageView(image: image)
        imageView.contentMode = UIViewContentMode.Center
        return imageView
    }
    
    func executeCompletionBlock(){
        let state = stateWithPercentage(currentPercentage)
        var mode = KZSwipeTableViewCellMode.None
        var completionBlock: KZSwipeCompletionBlock?
        
        switch state {
        case .State1:
            mode = _modeForState1
            completionBlock = completionBlock1
            break;
        case .State2:
            mode = _modeForState2
            completionBlock = completionBlock2
            break;
        case .State3:
            mode = _modeForState3
            completionBlock = completionBlock3
            break;
        case .State4:
            mode = _modeForState4
            completionBlock = completionBlock4
            break;
            
        default:
            break;
        }
        
        if let completionBlock = completionBlock {
            completionBlock(cell: self, state: state, mode: mode)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
