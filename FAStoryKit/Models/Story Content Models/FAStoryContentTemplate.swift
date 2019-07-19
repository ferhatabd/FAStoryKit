//
//  FAStoryContentTemplate.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 9.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import Foundation
import AVFoundation

/// Story asset wrapper
public struct FAStoryAsset<T> {
    /// Asset Content
    var content: T! {
        didSet {
            guard content != nil else {return}
            isContentReady = true
        }
    }
    
    /// Content is ready to be displayed 
    var isContentReady = false
    
    /// asset external URL
    var externUrl: URL?
    
    init(with asset: T) {
        self.content = asset
    }
}

///
/// Protocol that needs to be adopted by
/// subclasses -that means by each content type-
/// for handling infrastructure issues
internal protocol FAStoryContentProtocol {
    
    /// current progress of the content
    ///
    /// for static contents like images there
    /// will be a fixed duration the content will
    /// be displayed
    /// for dynamic contents like videos
    /// the duration will basically be the duration
    /// of the content
    var progress: Double { get set }
  
    /// method to configure the content
    func contentConfigure() -> Void
}

///
/// Content delegate
///
/// Will send the delegee notifications
/// regarding the content status, whether it's
/// ready or not, is being downloaded and that case
/// also the progress of the download
public protocol FAStoryContentDelegate: class {
    /// content is set
    func contentReady<Asset>(_ asset: FAStoryAsset<Asset>)
    
    /// content has failed
    func contentFailed<Asset>(_ asset: FAStoryAsset<Asset>?)
    
    /// content download started
    func contentDownloadStarted<Asset>(for asset: FAStoryAsset<Asset>)
    
    /// download progress
    ///
    /// - parameter asset: The asset that's being downloaded
    /// - parameter progress: Current download progress
    func contentDownloadProgress<Asset>(for asset: FAStoryAsset<Asset>, progress: Float)
    
    /// download is completed
    ///
    /// - parameter asset: The asset that's being downloaded
    /// - parameter success: The download did or didn't copmlete successfully
    ///
    func contentDownloadFinished<Asset>(for aseet: FAStoryAsset<Asset>, success: Bool)
    
    /// content actual progress changed
    func contentProgressChanged(_ progress: Double)
    
    /// content display is completed
    func contentDisplayFinished<Asset>(for asset: FAStoryAsset<Asset>)
}


/// Main underlying content supplier
public class FAStoryContentTemplate<Asset>: NSObject, FAStoryAddible, FAStoryContentCacher {

    // ==================================================== //
    // MARK: Properties
    // ==================================================== //
    
    // -----------------------------------
    // Public properties
    // -----------------------------------
    public var cacher: NSCache<AnyObject, AnyObject>!
    
    public var cacheName: String {
        return "FAStoryKitCache"
    }
    
    public var contentNature: FAStoryContentNature {
        return _contentNature
    }
    
    public var shouldPurgeWhenReleased: Bool {
        return false
    }
    public var asset: FAStoryAsset<Asset>!
    
    public var contentType: FAStoryContentType = .image
    
    public var interactionUrl: URL?
    
    public var assetUrl: URL!
    
    public var duration: Double = 0
    
    public var content: Asset? {
        guard let _a = asset, _a.isContentReady else {return nil}
        return _a.content ?? nil
    }
    
    public var isContentReady: Bool {
        guard let _a = asset else {return false}
        return _a.isContentReady
    }
    
    public var downloadService: DownloadService!
    
    public var downloadProgress: Float = 0
    
    public weak var delegate: FAStoryContentDelegate?
    // -----------------------------------
    
    // -----------------------------------
    // Internal properties
    // -----------------------------------
    /// content name
    internal var contentName: String {
        guard let _path = assetUrl?.absoluteString else {return "content"}
        
        guard let sub = _path.split(separator: "/").last else {return "content"}
        
        guard let raw = sub.split(separator: ".").last else {return String(sub)}
        
        return String(raw)
    }
    
    /// Remaining duration of the content
    internal var remainingTime: Double = 0
    
    /// Content display is paused
    internal var isPaused = false
    
    /// Timer for keeping track of the content
    ///
    /// Subclasses should add their own targets
    /// to this timer
    internal var contentTimer: Timer!
    
    /// Timer refresh rate
    internal let kTimerInterval: Double = 0.01
    // -----------------------------------
    
    // -----------------------------------
    // Private properties
    // -----------------------------------
    /// content nature
    private var _contentNature = FAStoryContentNature.builtIn
    
    // -----------------------------------
    
    
    // ==================================================== //
    // MARK: Init
    // ==================================================== //
    
    public init(type: FAStoryContentType, duration: Double=0) {
        super.init()
        self.duration = duration
        self.contentType = type
    }
    
    // ==================================================== //
    // MARK: Lifecycle
    // ==================================================== //
    
    
    // ==================================================== //
    // MARK: Methods
    // ==================================================== //
    
    // -----------------------------------
    // Public methods
    // -----------------------------------
    /// Modify the content nature
    public func setContentNature(_ nature: FAStoryContentNature) {
        _contentNature = nature
    }
    
    public func start() -> Bool {
        return true
    }
    
    public func pause() -> Bool {
        return true
    }
    
    public func stop() {}
    // -----------------------------------
    
    
    // -----------------------------------
    // Internal methods
    // -----------------------------------
    
    // -----------------------------------
    
    
    // -----------------------------------
    // Private methods
    // -----------------------------------
    
    // -----------------------------------
  
}


