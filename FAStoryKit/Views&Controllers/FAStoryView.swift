//
//  FAStoryView.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 6.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit

final public class FAStoryView: UIView {

    // ==================================================== //
    // MARK: IBOutlets
    // ==================================================== //
    @IBOutlet internal var storyView: UIView!
    
    @IBOutlet internal weak var collectionView: UICollectionView! 
    
    @IBOutlet internal weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet internal weak var collectionViewHeight: NSLayoutConstraint!
    
    // ==================================================== //
    // MARK: IBActions
    // ==================================================== //
    
    
    // ==================================================== //
    // MARK: Properties
    // ==================================================== //
    
    // -----------------------------------
    // Public properties
    // -----------------------------------
    /// FAStoryDataSource
    ///
    /// Reloads the collectionView data in case
    /// the collectionView was already loaded and
    /// the dataSource has changed afterwards
    public weak var dataSource: FAStoryDataSource? {
        didSet {
            DispatchQueue.main.async {
                self.stories = self.dataSource?.stories()
                guard let cv = self.collectionView else {return}
                cv.reloadData()
            }
        }
    }
    
    /// FAStoryDelegate
    public weak var delegate: FAStoryDelegate? {
        didSet {
            collectionViewHeight?.constant = (delegate?.cellHeight ?? DefaultValues.shared.cellHeight) * 1.15
        }
    }
    // -----------------------------------
    
    
    // -----------------------------------
    // Private properties
    // -----------------------------------
    private var stories: [FAStory]?
    
    // -----------------------------------
    
    
    // ==================================================== //
    // MARK: Init
    // ==================================================== //
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setupUI()
    }
    
    // ==================================================== //
    // MARK: View lifecycle
    // ==================================================== //
    public override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    
    
    // ==================================================== //
    // MARK: Methods
    // ==================================================== //
    
    // -----------------------------------
    // Public methods
    // -----------------------------------
    /// hides the scroll indicators
    public func setScrollIndicators(hidden: Bool) {
        collectionView?.showsVerticalScrollIndicator = !hidden
        collectionView?.showsHorizontalScrollIndicator = !hidden
    }
    
    // -----------------------------------
    
    
    // -----------------------------------
    // Private methods
    // -----------------------------------
    private func _setupUI() {
        // load the nib file
        let bundle = Bundle(for: FAStoryView.self)
        
        bundle.loadNibNamed("FAStoryView", owner: self, options: nil)
        
        addSubview(storyView)
        
        storyView.frame = bounds
        storyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        _cvSetup()
    }
    
    
    /// prepares the collectionView for usage
    private func _cvSetup() {
        //
        // register collectionViewCell for usage
        //
        collectionView.register(FAStoryCollectionViewCell.self, forCellWithReuseIdentifier: FAStoryCollectionViewCell.ident)
        
        //
        // content inset for the leading edge
        //
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
        //
        // delay touches
        //
        collectionView.delaysContentTouches = false
    }
    
    /// calculates the cell size based on the current configuration
    private func _cellSize(height h: CGFloat, aspectRatio r: CGFloat) -> CGSize {
        return CGSize(width: h * r, height: h)
    }
    // -----------------------------------
}

//
// MARK: CollectionView Datasource
//
extension FAStoryView: UICollectionViewDataSource {
    /// Number of items = number of stories
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories?.count ?? 0
    }
    
    /// Cell for stories
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FAStoryCollectionViewCell.ident, for: indexPath) as! FAStoryCollectionViewCell
        
        cell.setName(stories![indexPath.row].name, font: delegate?.displayNameFont ?? DefaultValues.shared.displayNameFont, color: .black)
        
        if let image = stories?[indexPath.row].previewImage {
            cell.setImage(image)
        }
        
        return cell
        
    }
    
    /// Number of sections -- in case the default value changes in future
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

//
// MARK: CollectionView Delegate
//
extension FAStoryView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    /// cell size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     
        let h = delegate?.cellHeight ?? DefaultValues.shared.cellHeight
        let r = delegate?.cellAspectRatio ?? DefaultValues.shared.cellAspectRatio
        
        return _cellSize(height: h, aspectRatio: r)
    }
    
    /// horizontal spacing between items
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return delegate?.cellHorizontalSpacing ?? DefaultValues.shared.cellHorizontalSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: delegate?.cellHorizontalSpacing ?? DefaultValues.shared.cellHorizontalSpacing, bottom: 0, right: delegate?.cellHorizontalSpacing ?? DefaultValues.shared.cellHorizontalSpacing)
    }
    
    /// user selected a cell
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelect(row: indexPath.row)
    }
    
}
