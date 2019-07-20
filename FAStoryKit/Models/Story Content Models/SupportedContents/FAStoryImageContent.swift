//
//  FAStoryImageContent.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 12.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import Foundation
import SessionKit

public class FAStoryImageContent: FAStoryContentTemplate<UIImage>, FAStoryContentProtocol {
 
    // ==================================================== //
    // MARK: Properties
    // ==================================================== //
    
    // -----------------------------------
    // Public properties
    // -----------------------------------
    /// Content actual progress
    var progress: Double {
        get {
            guard remainingTime > 0 else {return 0}
            return max(0, (1 - (remainingTime / duration)))
        }
        set {}
    }
    // -----------------------------------
    
    
    // -----------------------------------
    // Private properties
    // -----------------------------------

    // -----------------------------------
    
    
    // ==================================================== //
    // MARK: Init
    // ==================================================== //
    public required init(assetURL: URL, externUrl: URL?=nil, duration: Double=0) {
        super.init(type: .image, duration: duration)
        self.assetUrl = assetURL
        self.interactionUrl = externUrl
        self.duration = duration
        self.contentType = .image
        self.asset = FAStoryAsset(with: UIImage())
        self.asset.externUrl = externUrl
        print("asset url: \(externUrl?.absoluteString ?? "no urls")")
    }
    
    deinit {
        if let t = contentTimer {
            t.invalidate()
        }
    }
    
    // ==================================================== //
    // MARK: Methods
    // ==================================================== //
    
    // -----------------------------------
    // Public methods
    // -----------------------------------
    // MARK: FAStoryContentProtocol
    /// Configure the content
    func contentConfigure() {
        
        let flag: Bool
        
        if contentTimer == nil {
            flag = true
        } else if let t = contentTimer, !t.isValid {
            flag = true
        } else {
            flag = false
        }
        
        if flag {
            remainingTime = duration
            
            // create the timer
            contentTimer = Timer.scheduledTimer(timeInterval: kTimerInterval,
                                                target: self,
                                                selector: #selector(timerUpdate),
                                                userInfo: nil,
                                                repeats: true)
        }
        
        switch contentNature {
        case .builtIn:
            if let image = UIImage(named: assetUrl.absoluteString) {
                asset.content = image
                asset.externUrl = interactionUrl
                delegate?.contentReady(asset)
                _ = start()
            } else {
                delegate?.contentFailed(asset)
            }
        case .online:
            guard let _cachedImage = try? getObject(withName: contentName) as? UIImage else {
                startDownload(url: assetUrl, name: contentName, destination: .toCache)
                delegate?.contentDownloadStarted(for: asset)
                return
            }
            asset.content = _cachedImage
            delegate?.contentReady(asset)
            _  = start()
        }
    }
    
    /// Method to start the content
    public override func start() -> Bool {
        _ = super.start()
        
        if asset.isContentReady {
            isPaused = false
            return true
        } else {
            delegate?.contentPlayerInitStarted()
            contentConfigure()
            return false
        }
    }
   
    /// Method to pause the content
    public override func pause() -> Bool {
        _ = super.pause()
        
        isPaused = true
        return true
    }
    
    
    
    /// Method to stop the content
    public override func stop() {
        _ = pause()
        remainingTime = duration
        contentTimer?.invalidate()
    }
    
    // -----------------------------------
    
    
    // -----------------------------------
    // Private methods
    // -----------------------------------
    @objc
    private func timerUpdate() {
        guard !isPaused else {return}
        
        //
        // Calculate the remainingTime & update the progress info
        //
        remainingTime = max(0, remainingTime - kTimerInterval)
        
        delegate?.contentProgressChanged(progress)
        
        if remainingTime == 0 {
            _ = pause()
            delegate?.contentDisplayFinished(for: asset)
        }
        
    }
    // -----------------------------------
    
   
   
}

//
// MARK: DownloadServiceDelegate
//
internal extension FAStoryImageContent {
    
    func dlComplete(toPath: String) {
        guard let i = UIImage(contentsOfFile: toPath), let key = assetUrl else {return}
        cacher.setObject(i, forKey: key as AnyObject)
        delegate?.contentDownloadFinished(for: asset, success: true)
        contentConfigure()
        _ = start()
    }
    
    func dlProgress(_ progress: Float) {
        self.downloadProgress = progress
        delegate?.contentDownloadProgress(for: asset, progress: progress)
        print("dl progress: \(progress)")
    }
    
    func dlError(err: Error?, errType: DonwloadServiceErrors_enm) {
        delegate?.contentDownloadFinished(for: asset, success: false)
        print("dl error")
    }
    
}
