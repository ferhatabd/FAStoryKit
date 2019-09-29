//
//  TransitionAnimator.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 27.09.2019.
//

import UIKit

internal enum TransitionDirection: Int {
    case left = 0
    case right = 1
}

internal final class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let direction: TransitionDirection

 
    init(direction: TransitionDirection) {
        self.direction = direction
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
 
        return TimeInterval(0.5)
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }

        
        let duration = transitionDuration(using: transitionContext)

        let container = transitionContext.containerView
        
        let fromViewTransform, toViewTransform: CGAffineTransform
        
        container.addSubview(toView)
        container.sendSubviewToBack(toView)
        
        switch direction {
        case .left:
            fromViewTransform = CGAffineTransform(translationX: -fromView.frame.width, y: 0).scaledBy(x: 0.7, y: 0.7)
            toViewTransform = CGAffineTransform(translationX: fromView.frame.width, y: 0).scaledBy(x: 0.7, y: 0.7)
        case .right:
            fromViewTransform = CGAffineTransform(translationX: fromView.frame.width, y: 0).scaledBy(x: 0.7, y: 0.7)
            toViewTransform = CGAffineTransform(translationX: -fromView.frame.width, y: 0).scaledBy(x: 0.7, y: 0.7)
        }
        
        toView.transform = toViewTransform
      
        let animations = {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1) {
                toView.transform = .identity
                fromView.transform = fromViewTransform
            }

        }

        UIView.animateKeyframes(withDuration: duration,
                                delay: 0,
                                options: .calculationModeCubic,
                                animations: animations,
                                completion: { finished in
                                    
                                    //
                                    // check if the transition is cancelled
                                    //
                                    if transitionContext.transitionWasCancelled  {
                                        fromView.transform = .identity
                                        toView.removeFromSuperview()
                                    } else {
                                        fromView.removeFromSuperview()
                                    }
                                    
                                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
