//
//  FAStoryController.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 9.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit
import AVFoundation


internal protocol StoryControllerDelegate: class {
    func storyProgressChanged(_ progress: Double)
    func storyCurrentContentFinished()
    /// is called when the current story has no more content
    /// to let the higher control to show the next highlight content 
    func shouldShowNext() -> Bool
    /// is called when the current story has no more previous content
    /// to let the higher control to show the previous highlight content
    func shouldShowPrevious() -> Bool
    func storyAssetChanged<Asset>(_ asset: FAStoryAsset<Asset>?)
    func storyAssetInitStart()
    func storyAssetReady<Asset>(_ asset: FAStoryAsset<Asset>?)
    func storyAssetFailed<Asset>(_ asset: FAStoryAsset<Asset>?)
    func storyAssetDownloadProgress<Asset>(_ asset: FAStoryAsset<Asset>, progress: Float)
    func storyAssetDownloadCompleted<Asset>(_ asset: FAStoryAsset<Asset>)
}


internal class FAStoryController: NSObject, FAStoryContentDelegate {
    func contentReady<Asset>(_ asset: FAStoryAsset<Asset>) {
        delegate?.storyAssetReady(asset)
    }
    
    func contentDownloadStarted<Asset>(for asset: FAStoryAsset<Asset>) {
        delegate?.storyAssetInitStart()
    }
    
    func contentDownloadProgress<Asset>(for asset: FAStoryAsset<Asset>, progress: Float) {
        delegate?.storyAssetDownloadProgress(asset, progress: progress)
    }
    
    func contentDownloadFinished<Asset>(for asset: FAStoryAsset<Asset>, success: Bool) {
        delegate?.storyAssetDownloadCompleted(asset)
    }
    
    func contentProgressChanged(_ progress: Double) {
        delegate?.storyProgressChanged(progress)
    }
    
    func contentDisplayFinished<Asset>(for asset: FAStoryAsset<Asset>) {
        currentContent?.stop()
        delegate?.storyCurrentContentFinished()
    }
    
    func contentPlayerInitStarted() {
        delegate?.storyAssetInitStart()
    }
    
    func contentFailed<Asset>(_ asset: FAStoryAsset<Asset>?) {
        delegate?.storyAssetFailed(asset)
    }
    
  
   
    // ==================================================== //
    // MARK: Properties
    // ==================================================== //
    
    // -----------------------------------
    // Public properties
    // -----------------------------------
    /// Story object
    var story: FAStory
    
    /// Currently active content
    var currentContent: FAStoryAddible? {
        willSet {
            currentContent?.stop()
            if let _c = currentContent as? FAStoryVideoContent {
                _c.delegate = nil
                _c.stop()
            } else if let _c = currentContent as? FAStoryImageContent {
                _c.delegate = nil
                _c.stop()
            }
        }
        didSet {
            if let _c = currentContent as? FAStoryImageContent {
                _c.delegate = self
                _c.contentConfigure()
            } else if let _c = currentContent as? FAStoryVideoContent {
                _c.delegate = self
                _c.contentConfigure()
            }
            _sendAssetMessage()
        }
    }
    
    
    /// Delegate
    weak var delegate: StoryControllerDelegate? {
        didSet {
            _sendAssetMessage()
        }
    }

    // -----------------------------------
    
    
    // -----------------------------------
    // Private properties
    // -----------------------------------
    /// Number of contents within the story
    private let contentCount: Int
    
    /// Index of the currently shown content
    private var currentIdx: Int = 0
    
    /// Current content type
    private var currentContentType: FAStoryContentType = .image
    
    
    
    // -----------------------------------
    
    
    // ==================================================== //
    // MARK: Init
    // ==================================================== //
    init(with story: FAStory) {
        self.story = story
        self.contentCount = story.content?.count ?? 0
        self.currentContent = story.content?.first
        if let c = currentContent as? FAStoryVideoContent {
            c.contentConfigure()
        }
        super.init()
        _ = _initContent(story.content?.first)
        
    }

    // ==================================================== //
    // MARK: Methods
    // ==================================================== //
    
    // -----------------------------------
    // Public methods
    // -----------------------------------

    /// Makes the next content visible
    func setNext() -> Bool {
        guard contentCount > 0 else {return false}
       
        //
        if currentIdx < contentCount - 1 {
            currentIdx += 1
            currentContent = story.content?[currentIdx]
            start()
            return true
        }
        
        //
        return delegate?.shouldShowNext() ?? false
    }
    
    
    /// Makes the previous content visible
    func setPrev() -> Bool {
      
        guard currentIdx > 0 else {
            
            if !(delegate?.shouldShowPrevious() ?? false) {
                
                  _ = _initContent(story.content?[0])
                  currentContent?.stop()
                  switch currentContentType {
                  case .image:
                      guard let c = currentContent as? FAStoryImageContent else {break}
                      delegate?.storyAssetChanged(c.asset)
                  case .video:
                      guard let c = currentContent as? FAStoryVideoContent else {break}
                      delegate?.storyAssetChanged(c.asset)
                      
                  }
                  start()
                  return true
            } else {
                return true 
            }
  
        }
        //
        currentIdx -= 1
        currentContent = story.content?[currentIdx]
        start()
        //
        
        return true
    }
    
   
    
    /// Pause the current content
    func pause() {
        _ = currentContent?.pause()
    }
    
    
    /// Start / Continue the current content
    func start() {
        if let c = currentContent as? FAStoryImageContent {
            c.contentConfigure()
        }
        _ = currentContent?.start()
    }
    
    /// Stops the content totally
    func stop() {
        currentContent?.stop()
    }
    // -----------------------------------
    
    
    // -----------------------------------
    // Private methods
    // -----------------------------------
    /// Initialize the content
    private func _initContent(_ c: FAStoryAddible?) -> Bool {
   
        guard let _c = c else {return false}
        
        if let __c = c as? FAStoryImageContent {
            __c.delegate = self
        } else if let __c = c as? FAStoryVideoContent {
            __c.delegate = self
        }
        
        currentContentType = _c.contentType
        
        return true
    }
    
    /// Send content asset change message to the delegee
    private func _sendAssetMessage() {
        guard let c = currentContent else {return}
        currentContentType = c.contentType
        
        switch currentContentType {
        case .image:
            guard let _c = currentContent as? FAStoryImageContent else {return}
            delegate?.storyAssetChanged(_c.asset)
            
        case .video:
            guard let _c = currentContent as? FAStoryVideoContent else {return}
            delegate?.storyAssetChanged(_c.asset)
        }
        
        delegate?.storyAssetInitStart()
    }
   
    // -----------------------------------
}
