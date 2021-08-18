//
//  SwipeDismissInteractible.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 18.08.2021.
//  Copyright © 2021 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit

public protocol SwipeDismissInteractible where Self: UIViewController & UIGestureRecognizerDelegate {
    /// Variable to add the gesture recognizer to
    var gestureView: UIView {get}
}

public protocol SwipeDismissInteractibleNavigationController where Self: UINavigationController & UIGestureRecognizerDelegate {
    /// Variable to add the gesture recognizer to
    var gestureView: UIView {get}
    
    /// Asks for a gestureRecognizer from the delegate, which will be added to be failed by the dismissGesture of the SwipeInteractionController
    /// - Parameter gesture: SwipeInteractionController dismiss gesture
    /// - returns:
    /// the gesture recognizer to be failed
    func gestureToBeFailedByDismiss(gesture: UIGestureRecognizer) -> UIGestureRecognizer?
    
    /// Asks the delegate for a gesture to be used for the dismissal
    /// it could be that the delegate is using already a panGestureRecognizer
    /// for another task.
    /// In this case here we won't add another gestureREcognizer as it would
    /// be impossible to handle two different panRecognizers. Instead the higher control
    /// should call the gestureAction in that case manually for the interactor to do its job
    func gestureToUse() -> UIPanGestureRecognizer?
}

public enum SwipeIntetactionControllerDirection: Int {
    case horizontal = 0
    case vertical = 1
    case horizontalLeftEdge = 2
}

public class SwipeInteractionController: UIPercentDrivenInteractiveTransition {
    
    private enum InteractorType: Int {
        case viewController = 0
        case navigationController = 1
    }
    
    public var interactionInProgress = false
    
    private var shouldCompleteTransition = false
    private weak var viewController: SwipeDismissInteractible!
    private weak var navigationController: SwipeDismissInteractibleNavigationController!
    private let interactorType: InteractorType
    private var oldTranslation: CGFloat = 0
    private let interactionDirection: SwipeIntetactionControllerDirection
    
    public init(viewController: UIViewController & SwipeDismissInteractible, direction: SwipeIntetactionControllerDirection = .vertical) {
        self.interactorType = .viewController
        self.interactionDirection = direction
        super.init()
        self.viewController = viewController
        
        switch interactionDirection {
        case .horizontal, .vertical:
            prepareGestureRecognizer(in: self.viewController.gestureView)
        case .horizontalLeftEdge:
            prepareEdgeGestureRecognizer(in: self.viewController.gestureView, side: interactionDirection)
        }
    }
    
    init(navigationController: SwipeDismissInteractibleNavigationController, direction: SwipeIntetactionControllerDirection = .vertical) {
        self.interactorType = .navigationController
        self.interactionDirection = direction
        
        super.init()
        self.navigationController = navigationController
        
        if navigationController.gestureToUse() == nil {
            switch interactionDirection {
            case .horizontal, .vertical:
                prepareGestureRecognizer(in: self.navigationController.gestureView)
            case .horizontalLeftEdge:
                prepareEdgeGestureRecognizer(in: self.navigationController.gestureView, side: interactionDirection)
            }
        }
    }
 
    
    private func prepareEdgeGestureRecognizer(in view: UIView, side: SwipeIntetactionControllerDirection) {
        
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleGesture(_:isBegun:)))
        
        gesture.edges = [.left]
        
        view.addGestureRecognizer(gesture)
        
        switch interactorType {
        case .viewController:
            gesture.delegate = viewController
        case .navigationController:
            gesture.delegate = navigationController
        }
    }
    
    
    private func prepareGestureRecognizer(in view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:isBegun:)))
        
        view.addGestureRecognizer(gesture)
        
        switch interactorType {
        case .viewController:
            gesture.delegate = viewController
        case .navigationController:
            gesture.delegate = navigationController
        }
    }

    
    @objc
    func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer, isBegun: Bool) {
        
        let viewToCheck: UIView
        
        switch interactorType {
        case .viewController:
            viewToCheck = viewController.view
        case .navigationController:
            viewToCheck = navigationController.view
        }
        
        let translation = gestureRecognizer.translation(in: viewToCheck)
        
        let position: CGFloat
        
        switch interactionDirection {
        case .horizontal, .horizontalLeftEdge:
            position  = translation.x
        case .vertical:
            position = translation.y
        }
        
        var progress = ((position * 1) / viewToCheck.bounds.height)
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        if isBegun && gestureRecognizer.state != .began {
            interactionInProgress = true
            switch interactorType {
            case .viewController:
                if interactionDirection == .horizontalLeftEdge {
                    viewController.navigationController?.popViewController(animated: true)
                } else {
                    if let presenting = viewController.presentingViewController {
                        presenting.dismiss(animated: true, completion: nil)
                    } else {
                        viewController.dismiss(animated: true, completion: nil)
                    }
                }
            case .navigationController:
                if interactionDirection == .horizontalLeftEdge {
                    navigationController.popViewController(animated: true)
                } else {
                    navigationController.dismiss(animated: true, completion: nil)
                }
            }
            completionSpeed = 1
        }
        
        switch gestureRecognizer.state {
        case .began:
            interactionInProgress = true
            switch interactorType {
            case .viewController:
                if interactionDirection == .horizontalLeftEdge {
                    viewController.navigationController?.popViewController(animated: true)
                } else {
                    if let presenting = viewController.presentingViewController {
                        presenting.dismiss(animated: true, completion: nil)
                    } else {
                        viewController.dismiss(animated: true, completion: nil)
                    }
                }
            case .navigationController:
                if interactionDirection == .horizontalLeftEdge {
                    navigationController.popViewController(animated: true)
                } else {
                    navigationController.dismiss(animated: true, completion: nil)
                }
            }
            completionSpeed = 1
        case .changed:
            interactionInProgress = true
            shouldCompleteTransition = progress > 0.4 || ((translation.y - oldTranslation) > 5)
            update(progress)
        case .cancelled:
            completionCurve = .easeOut
            completionSpeed = 0.5
            interactionInProgress = false
            cancel()
        case .ended:
            interactionInProgress = false
            if shouldCompleteTransition {
                finish()
            } else {
                completionCurve = .easeOut
                completionSpeed = 0.5
                cancel()
            }
        default:
            break
        }
        
        oldTranslation = translation.y
    }
}
