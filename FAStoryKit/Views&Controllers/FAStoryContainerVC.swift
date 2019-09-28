//
//  FAStoryContainerVC.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 27.09.2019.
//

import UIKit
import FAGlobalKit

/// Container for FAStoryViewControllers
/// __FAStoryContainerVC__ supplied as a container view controller
/// in order to make it easier to display multiple story  view controllers
/// with custom push & pop animations it's easy to implement
/// a transition between multiple story highlight objects
public class FAStoryContainer: UINavigationController, SwipeDismissInteractibleNavigationController {
  
   
    // ==================================================== //
    // MARK: IBOutlets
    // ==================================================== //
    
    
    // ==================================================== //
    // MARK: IBActions
    // ==================================================== //
    
    
    // ==================================================== //
    // MARK: Properties
    // ==================================================== //
    
    // -----------------------------------
    // Public properties
    // -----------------------------------
    public var gestureView: UIView {
        return view
    }
    
    /// Can show a next viewController
    public var canShowNext: Bool {
        return FAStoryVcStack.shared.viewController(forKey: .next) != nil
    }
    
    /// Can show a previous viewController
    public var canShowPrevious: Bool {
        return FAStoryVcStack.shared.viewController(forKey: .prev) != nil
    }
    
    public var dismissInteractionController: SwipeInteractionController?
    
    // -----------------------------------
    // Internal properties
    // -----------------------------------
    
    /// current presentation direction
    internal var presentationDirection: TransitionDirection = .left
    
    /// transition gesture recognizer
    internal var transitionGestureRecognizer: UIPanGestureRecognizer!
    
    /// Flag that indicates whether there is a push operation in process
    internal var _isPushing = false
    
    internal var oldPanPoint: CGPoint = .zero
    
    // -----------------------------------
    // Private properties
    // -----------------------------------
    
    private var panCalculator = TouchProgressCalculator(origin: .zero)
    
    private var transitionDecided = false
    
    private var dismissDecided = false
    
    private var gestureBegan = false
    
    
    // ==================================================== //
    // MARK: Init
    // ==================================================== //
    /// Initialize the controller with the initial FAStoryViewController object
    public init(storyController vc: FAStoryViewController) {
        super.init(rootViewController: vc)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("DeInit: FAStoryContainerVC")
        FAStoryVcStack.shared.clear()
    }
    
    // ==================================================== //
    // MARK: VC lifecycle
    // ==================================================== //
    public override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarHidden(true, animated: false)
        addCustomTransitioning()
        dismissInteractionController = SwipeInteractionController(navigationController: self)
        
    }
    
    
    // ==================================================== //
    // MARK: Methods
    // ==================================================== //
    
    // -----------------------------------
    // Public methods
    // -----------------------------------
    /// Presents the next highlight  if there i any
    /// - returns:
    /// True if there is a next story, False if otherwise
    public func jumpForward() {
        guard let next = FAStoryVcStack.shared.viewController(forKey: .next),
            let current = FAStoryVcStack.shared.viewController(forKey: .current) else { return }
        
        current.pause()
        
        presentationDirection = .left
        pushViewController(next, animated: true)
    }
    
    
    /// Presents the next highlight  if there i any
    /// - returns:
    /// True if there is a previous story, False if otherwise
    public func jumpBackward() {
        guard let prev = FAStoryVcStack.shared.viewController(forKey: .prev),
            let current = FAStoryVcStack.shared.viewController(forKey: .current) else { return }
        
        current.pause()
        
        presentationDirection = .right
        pushViewController(prev, animated: true)
    }
    
    public func gestureToBeFailedByDismiss(gesture: UIGestureRecognizer) -> UIGestureRecognizer? {
        return transitionGestureRecognizer
    }
    
    public func gestureToUse() -> UIPanGestureRecognizer? {
        return transitionGestureRecognizer
    }
    
    // -----------------------------------
    // Internal methods
    // -----------------------------------
    /// Method to handle the common pan gesture recognizer
    ///
    /// Depending on the angle of the pan, here will be decided whether to dismiss the view or
    /// to transition to another viewController
    /// - Parameter gestureRecognizer: Pan gesture recognizer
    @objc
    internal func _handleTransition(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        let location = gestureRecognizer.translation(in: view)
        
        switch gestureRecognizer.state {
        case .began:
            transitionDecided = false
            dismissDecided = false
            let origin = location
            panCalculator = TouchProgressCalculator(origin: origin)
            gestureBegan = true
            
        case .changed:
            
            //
            // Check what to do
            //
            if !transitionDecided && !dismissDecided {
                decideAction(panCalculator.getAngleToOrigin(location).toDegrees)
            } else if transitionDecided {
                presentationDirection = location.x >= panCalculator.origin.x ? .right : .left
                handleSwipeTransition(gestureRecognizer, isBegun: gestureBegan)
                gestureBegan = false
            } else if dismissDecided {
                dismissInteractionController?.handleGesture(gestureRecognizer, isBegun: gestureBegan)
                gestureBegan = false
            }
            
        case .ended:
            if transitionDecided {
                handleSwipeTransition(gestureRecognizer, isBegun: false)
            } else if dismissDecided {
                dismissInteractionController?.handleGesture(gestureRecognizer, isBegun: false)
            }
            
            transitionDecided = false
            dismissDecided = false
            
        default:
            break
        }
        
    }
    
    
    private func decideAction(_ angle: Double) {
        if angle >= -45 && angle <= 45 {
            dismissDecided = true
        } else {
            transitionDecided = true
        }
    }
      
}

// ==================================================== //
// MARK: UIGestureRecognizerDelegate
// ==================================================== //
extension FAStoryContainer: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer is UISwipeGestureRecognizer
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === transitionGestureRecognizer {
            return !(transitionCoordinatorHelper?.isPushing ?? false)
        } else {
            return true 
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !(otherGestureRecognizer is UISwipeGestureRecognizer)
    }
}

