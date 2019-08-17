//
//  StoryCollectionViewCell.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 6.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit

internal class FAStoryCollectionViewCell: UICollectionViewCell {

    
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
    
    /// ident
    class var ident: String {
        return "FAStoryCollectionViewCellIDent"
    }
    
    /// imageView for the defaultImage
    internal var imageView: UIImageView!
    
    /// label for the name
    internal var lblDisplayName: UILabel!
    
    // -----------------------------------
    
    
    // -----------------------------------
    // Private properties
    // -----------------------------------
    /// internal ui setup is completed
    private var isUiSetupDone = false
    // -----------------------------------
    
    
    // ==================================================== //
    // MARK: Init
    // ==================================================== //
    
    
    // ==================================================== //
    // MARK: VC lifecycle
    // ==================================================== //
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setupUI()
    }
  
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let iv = imageView {
            iv.layer.cornerRadius = iv.frame.height / 2
        }
    }
    
    
    // ==================================================== //
    // MARK: Methods
    // ==================================================== //
    
    // -----------------------------------
    // Public methods
    // -----------------------------------
    /// Sets the display name
    public func setName(_ name: String, font: UIFont, color: UIColor) {
        guard isUiSetupDone else {return}
        lblDisplayName.font = font
        lblDisplayName.textColor = color
        lblDisplayName.text = name
    }
    
    /// Sets the preview image
    public func setImage(_ image: UIImage) {
        guard isUiSetupDone else {return}
        imageView.image = image 
    }
    
    /// sets tge border width & color for the image
    ///
    /// - Parameters:
    ///   - width: Border width, set 0 to disable
    ///   - color: Border color
    public func setBorder(width: CGFloat, color: UIColor?) {
        guard isUiSetupDone else {return}
        imageView.layer.borderWidth = width
        imageView.layer.borderColor = color?.cgColor
    }
    // -----------------------------------
    
    
    // -----------------------------------
    // Private methods
    // -----------------------------------
    /// UI Setup
    private func _setupUI() {
        
        //
        // clear the background color
        //
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        //
        // imageView Setup
        //
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        
        contentView.addSubview(imageView)
        
        imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1).isActive = true
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        
        //
        // label setup
        //
        lblDisplayName = UILabel()
        lblDisplayName.translatesAutoresizingMaskIntoConstraints = false
        lblDisplayName.numberOfLines = 1
        lblDisplayName.textAlignment = .center
        lblDisplayName.backgroundColor = .clear
        
        contentView.addSubview(lblDisplayName)
        
        lblDisplayName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4).isActive = true
        lblDisplayName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1).isActive = true
        lblDisplayName.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        
        isUiSetupDone = true
        
    }
    // -----------------------------------
    
}
