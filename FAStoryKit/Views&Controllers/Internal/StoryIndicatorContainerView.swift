//
//  StoryIndicatorContainerView.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 9.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit

internal class StoryIndicatorContainerView: UIView {

    
    // ==================================================== //
    // MARK: Properties
    // ==================================================== //
    
    // -----------------------------------
    // Public properties
    // -----------------------------------
    
    // -----------------------------------
    
    
    // -----------------------------------
    // Private properties
    // -----------------------------------
    /// story count
    private var count: Int {
        didSet {
            _setupUI()
        }
    }
    
    /// contained views
    private var indicatorViews = [StoryIndicatorView]()
    
    /// currently active indicator
    private var currentIdx: Int = 0
    
    private var indicatorStack: UIStackView!
    
    private var isUiSet = false
    
    private var current: StoryIndicatorView? {
        guard currentIdx >= 0 && currentIdx < count else {return nil}
        return indicatorViews[currentIdx]
    }
    // -----------------------------------
    
    
    // ==================================================== //
    // MARK: Init
    // ==================================================== //
    init() {
        self.count = 0 
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        _setupUI()
    }
    
    init(count: Int) {
        self.count = count
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false 
        _setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ==================================================== //
    // MARK: View lifecycle
    // ==================================================== //
 
    
    
    // ==================================================== //
    // MARK: Methods
    // ==================================================== //
    
    // -----------------------------------
    // Public methods
    // -----------------------------------
    /// Modifies the current count of indicators
    /// within the stack
    internal func setCount(_ count: Int) {
        self.count = count 
    }
    
    ///
    /// Method that sets the progress
    /// for the current indicator
    ///
    internal func setProgress(_ p: CGFloat) {
        current?.progress = p
    }
    
    ///
    /// Switches to the next indicator
    ///
    internal func next() -> Bool {
        guard currentIdx < count - 1, let c = current else {return false}
        c.progress = 1
        currentIdx += 1
        return true
    }
    
    ///
    /// Switches to the previous indicator
    ///
    internal func previous() -> Bool {
        guard currentIdx > 0 else {
            current?.progress = 0
            return false
        }
        current?.progress = 0
        currentIdx -= 1
        current?.progress = 0
        return true
    }
    // -----------------------------------
    
    
    // -----------------------------------
    // Private methods
    // -----------------------------------
    /// Method for internal UI setup
    private func _setupUI() {
    
        //
        // check the count
        //
        guard count > 0 else {return}
        
        indicatorStack = UIStackView()
        indicatorStack.translatesAutoresizingMaskIntoConstraints = false
        indicatorStack.backgroundColor = .clear
        indicatorStack.axis = .horizontal
        indicatorStack.spacing = 1
        indicatorStack.distribution = .fillEqually
        
        addSubview(indicatorStack)
        
        indicatorStack.heightAnchor.constraint(equalToConstant: 2).isActive = true
        indicatorStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4).isActive = true
        indicatorStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4).isActive = true
        indicatorStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        //
        // create the containers first
        //
        for _ in 0..<count {
          
            let _indicator = StoryIndicatorView()
            _indicator.fillColor = .white
            _indicator.remainingColor = UIColor.white.withAlphaComponent(0.25)
            _indicator.progress = 0
            _indicator.clipsToBounds = true
            _indicator.layer.cornerRadius = 1
            indicatorViews.append(_indicator)
            
            indicatorStack.addArrangedSubview(_indicator)
            
            _indicator.heightAnchor.constraint(equalTo: indicatorStack.heightAnchor).isActive = true
            
        }

    }
    // -----------------------------------
    
}
