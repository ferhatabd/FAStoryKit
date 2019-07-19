//
//  StoryIndicatorView.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 9.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit

internal class StoryIndicatorView: UIView {

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
    /// indicator current progress
    internal var progress: CGFloat = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                
                guard self.filledViewWidthConstraint != nil else {return}
                
                self.filledViewWidthConstraint.isActive = false
                
                UIView.animate(withDuration: 0.1,
                               animations: {
                                
                                self.filledViewWidthConstraint = self.filledView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: self._progress)
                                self.filledViewWidthConstraint.isActive = true
                                self.layoutIfNeeded()
                })
            }
        }
    }
    
    /// indicator filled view
    internal var filledView: UIView!
    
    /// filledView width constraint
    internal var filledViewWidthConstraint: NSLayoutConstraint!
    
    /// indicator fill color
    internal var fillColor: UIColor = .white
    
    /// indicator remaining color
    internal var remainingColor: UIColor = UIColor.white.withAlphaComponent(0.5) {
        didSet {
            backgroundColor = remainingColor
        }
    }
    // -----------------------------------
    
    
    // -----------------------------------
    // Private properties
    // -----------------------------------
    private var _progress: CGFloat {
        if progress < 0 {
            return 0
        } else if progress <= 1 {
            return progress
        } else {
            return 1
        }
    }
    // -----------------------------------
    
    
    // ==================================================== //
    // MARK: Init
    // ==================================================== //
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
    }
    
    init() {
        super.init(frame: .zero)
        _setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // ==================================================== //
    // MARK: VC lifecycle
    // ==================================================== //
    
    
    // ==================================================== //
    // MARK: Methods
    // ==================================================== //
    
    // -----------------------------------
    // Public methods
    // -----------------------------------
    
    // -----------------------------------
    
    
    // -----------------------------------
    // Private methods
    // -----------------------------------
    /// internal ui setup
    private func _setupUI() {
        clipsToBounds = true
        layer.masksToBounds = true
        backgroundColor = remainingColor
        
        //
        // create the fillView
        //
        filledView = UIView()
        filledView.translatesAutoresizingMaskIntoConstraints = false
        filledView.backgroundColor = fillColor
        filledView.clipsToBounds = true
        filledView.layer.cornerRadius = layer.cornerRadius
        
        addSubview(filledView)
        
        filledView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        filledView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        filledView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        filledViewWidthConstraint = filledView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: _progress)
        filledViewWidthConstraint.isActive = true
        
    }
    // -----------------------------------
}
