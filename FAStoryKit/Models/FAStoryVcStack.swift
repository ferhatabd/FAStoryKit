//
//  FAStoryVcStack.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 27.09.2019.
//

import Foundation


///
/// A static stack that holds FAStoryVC viewControllers.
/// By default it keeps reference of three viewControllers at max
/// These are viewControllers for the current, previous & next story viewControllers
/// In case there is no previous / next stories, they will be empty
///
///

public enum StackVcKeys: Int {
    case prev = 0
    case current = 1
    case next = 2
}

public struct FAStoryVcStack  {
    
    // -----------------------------------------------------
    // MARK: Properties
    // -----------------------------------------------------
    
    // -----------------------------------------------------
    // Public properties
    // -----------------------------------------------------
    
    /// Default stack
    public static var shared = FAStoryVcStack()
    // -----------------------------------------------------
    
    
    // -----------------------------------------------------
    // Internal properties
    // -----------------------------------------------------
    
    /// reference to all stories
    internal var stories: [FAStory]!
    // -----------------------------------------------------
    
    
    // -----------------------------------------------------
    // Private properties
    // -----------------------------------------------------
    /// next Vc
    private var nextVc: FAStoryViewController!
    
    /// current Vc
    private var currentVc: FAStoryViewController!
    
    /// prev Vc
    private var previousVc: FAStoryViewController!

    // -----------------------------------------------------
    
    // -----------------------------------------------------
    // MARK: Methods
    // -----------------------------------------------------
    
    // -----------------------------------------------------
    // Public methods
    // -----------------------------------------------------
    
    /// Accepts the given viewController as the current one and adjusts the stack accordingly
    /// - Parameter vc: The story view controller that's about to be displayed to the user
    public mutating func set(currentViewController vc: FAStoryViewController) {
        guard let story = vc.story else {return}
        guard let idx = stories.firstIndex(of: story) else {return}
        
        let max = stories.endIndex - 1
        
        previousVc = nil
        nextVc = nil
        
        // set the currentVc
        currentVc = vc
        
        // set the previousVc
        if idx > 0 {
            previousVc = FAStoryViewController()
            previousVc.story = stories[idx - 1]
        }
        
        // set the next vc 
        if idx < max {
            nextVc = FAStoryViewController()
            nextVc.story = stories[idx + 1]
        }
        
    }
    
    /// Returns the viewController related with the requested key
    /// - Parameter key: Key for the request
    public func viewController(forKey key: StackVcKeys) -> FAStoryViewController?  {
        switch key {
        case .current:
            guard currentVc != nil else {return nil}
            return currentVc
        case .next:
            guard nextVc != nil else {return nil}
            return nextVc
        case .prev:
            guard previousVc != nil else {return nil}
            return previousVc
        @unknown default:
            assert(false, "handle all types")
            return nil
        }
    }
    // -----------------------------------------------------
    
    
    
    // -----------------------------------------------------
    // Internal methods
    // -----------------------------------------------------
    /// Clears the resources held by the stack
    internal mutating func clear() {
        previousVc = nil
        currentVc = nil
        nextVc = nil
    }
    // -----------------------------------------------------
}
