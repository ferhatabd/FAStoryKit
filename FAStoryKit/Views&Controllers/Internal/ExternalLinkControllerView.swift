//
//  ExternalLinkControllerView.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 15.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit

internal protocol ExternalLinkControllerDelegate: class {
    func openLink(_ url: URL) -> Void
}

internal class ExternalLinkControllerView: UIView {

    
    // ==================================================== //
    // MARK: Properties
    // ==================================================== //
    
    // -----------------------------------
    // Public properties
    // -----------------------------------
    
    // -----------------------------------
    
    
    // -----------------------------------
    // Internal properties
    // -----------------------------------
    /// Font for the title
    internal var font: UIFont? {
        didSet {
            _setDataUI()
        }
    }
    
    /// Text color
    internal var color: UIColor? {
        didSet {
            _setDataUI()
        }
    }
    
    /// Title
    internal var title: String? {
        didSet {
            _setDataUI()
        }
    }
    
    /// Controller delegate
    internal weak var delegate: ExternalLinkControllerDelegate?
    // -----------------------------------
    
    
    // -----------------------------------
    // Private properties
    // -----------------------------------
    /// Url to be opened
    private var _url: URL
    
    /// label for the link
    private var _lblLink: UILabel!
    
    /// Tap delegate for the label
    private var _tapRecognizer: UITapGestureRecognizer!
    
    // -----------------------------------
    
    
    // ==================================================== //
    // MARK: Init
    // ==================================================== //
    internal init(with url: URL) {
        self._url = url
        super.init(frame: .zero)
        _setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ==================================================== //
    // MARK: View lifecycle
    // ==================================================== //
    override func layoutSubviews() {
        super.layoutSubviews()
        if _lblLink != nil {
            _lblLink.layer.cornerRadius = _lblLink.frame.height / 2
        }
    }
    
    // ==================================================== //
    // MARK: Methods
    // ==================================================== //
    
    // -----------------------------------
    // Public methods
    // -----------------------------------
    /// Replaces the existing url resource
    internal func replaceUrl(_ url: URL) {
        self._url = url 
    }
    // -----------------------------------
    
    
    // -----------------------------------
    // Private methods
    // -----------------------------------
    /// Intenrnal UI setup
    private func _setupUI() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        //
        // Confgiure the label
        //
        _lblLink = UILabel()
        _lblLink.translatesAutoresizingMaskIntoConstraints = false
        _lblLink.backgroundColor = .clear
        _lblLink.numberOfLines = 0
        _lblLink.textAlignment = .center
        _lblLink.clipsToBounds = true 
        _lblLink.layer.borderWidth = 1
        _lblLink.isUserInteractionEnabled = true
        
        
        addSubview(_lblLink)
        
        _lblLink.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6).isActive = true
        _lblLink.heightAnchor.constraint(equalToConstant: 40).isActive = true
        _lblLink.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        _lblLink.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        
        //
        // Gesture recognizer config
        //
        _tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(_didTap(_:)))
        
        _lblLink.addGestureRecognizer(_tapRecognizer)
    }
    
    /// UI data setting
    private func _setDataUI() {
        guard _lblLink != nil else {return}
        
        let _font = self.font ?? UIFont.systemFont(ofSize: 16, weight: .regular)
        let _color: UIColor = self.color ?? .white
        
        DispatchQueue.main.async {
            self._lblLink.text = self.title
            self._lblLink.font  = _font
            self._lblLink.textColor = _color
            self._lblLink.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    /// Label tap recognizer
    @objc
    private func _didTap(_ sender: UITapGestureRecognizer) {
        delegate?.openLink(self._url)
    }
    // -----------------------------------

}
