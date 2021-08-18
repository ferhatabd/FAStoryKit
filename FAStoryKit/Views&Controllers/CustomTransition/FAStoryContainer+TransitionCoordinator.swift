//
//  TransitionCoordinator.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 27.09.2019.
//

import UIKit

internal extension FAStoryContainer {
 
    static private var coordinatorHelperKey = "UINavigationController.TransitionCoordinatorHelper"

    var transitionCoordinatorHelper: TransitionCoordinator? {
        guard let coordinator =  objc_getAssociatedObject(self, &FAStoryContainer.coordinatorHelperKey) as? TransitionCoordinator else {return nil}
        
        coordinator.presentationDirection = presentationDirection
        
        return coordinator
    }

    func addCustomTransitioning() {
 
        var object = objc_getAssociatedObject(self, &FAStoryContainer.coordinatorHelperKey)

        guard object == nil else {
            return
        }

        object = TransitionCoordinator()
        let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        objc_setAssociatedObject(self, &FAStoryContainer.coordinatorHelperKey, object, nonatomic)


        delegate = object as? TransitionCoordinator


        let swipeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(_handleTransition(_:)))
        transitionGestureRecognizer = swipeGestureRecognizer
        transitionGestureRecognizer.delegate = self
        view.addGestureRecognizer(transitionGestureRecognizer)
    }


    @objc func handleSwipeTransition(_ gestureRecognizer: UIPanGestureRecognizer, isBegun: Bool) {
        guard let gestureRecognizerView = gestureRecognizer.view else {
            transitionCoordinatorHelper?.interactionController = nil
            return
        }
        
        let location = gestureRecognizer.translation(in: gestureRecognizerView)

        let percent = abs(location.x) / gestureRecognizerView.bounds.size.width
        
        let direction = transitionCoordinatorHelper?.presentationDirection
        
        if isBegun && gestureRecognizer.state != .began {
            transitionCoordinatorHelper?.interactionController = UIPercentDrivenInteractiveTransition()
            
            switch direction {
            case .left:
                jumpForward()
            case .right:
                jumpBackward()
                
            default:
                break
            }
        }

        if gestureRecognizer.state == .began {
            transitionCoordinatorHelper?.interactionController = UIPercentDrivenInteractiveTransition()
            
            switch direction {
            case .left:
                jumpForward()
            case .right:
                jumpBackward()
                
            default:
                break
            }
            
        } else if gestureRecognizer.state == .changed {
            transitionCoordinatorHelper?.interactionController?.update(percent)
        } else if gestureRecognizer.state == .ended {
            if percent > 0.4 || ((oldPanPoint.x) <= (location.x)) {
                transitionCoordinatorHelper?.interactionController?.finish()
            } else {
                transitionCoordinatorHelper?.interactionController?.cancel()
                if let c = transitionCoordinatorHelper {
                    c.isPushing = false
                }
            }
            transitionCoordinatorHelper?.interactionController = nil
        }
        
        oldPanPoint = location
    }
}

final class TransitionCoordinator: NSObject, UINavigationControllerDelegate {
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    var presentationDirection: TransitionDirection = .left
    
    var isPushing = false

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPushing = true
       return TransitionAnimator(direction: presentationDirection)
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        isPushing = false 
    }
    
    
}
