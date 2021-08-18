//
//  FAStoryImageContent.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 12.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import Foundation
import AVFoundation


public extension FAStoryContentDelegate {
    /// Video player initialization started
    func contentPlayerInitStarted() {}

}

public class FAStoryVideoContent: FAStoryContentTemplate<AVPlayer>, FAStoryContentProtocol {
  
    // ==================================================== //
    // MARK: Properties
    // ==================================================== //
    
    // -----------------------------------
    // Public properties
    // -----------------------------------
    var progress: Double {
        get {
            guard let i = playerItem else {return 0}
            guard i.duration.seconds > 0 else {return 0}
            guard let p = player else {return 0}
            return p.currentTime().seconds / i.duration.seconds
        }
        set {}
    }
    
    override var remainingTime: Double {
        get {
            guard let i = playerItem else {return 0}
            guard i.duration.seconds > 0 else {return 0}
            guard let p = player else {return 0}
            return i.duration.seconds - p.currentTime().seconds
        }
        set {}
    }
    
    
    /// AVPlayerLayer
    public weak var playerLayer: AVPlayerLayer? {
        guard let p = player else {return nil}
        return AVPlayerLayer(player: p)
    }
    
    // -----------------------------------
    
    
    // -----------------------------------
    // Private properties
    // -----------------------------------
  
    /// player item
    private var playerItem: AVPlayerItem!
    
    /// AVPlayer object for video playing
    private var player: AVPlayer!
    
    /// AVPlayer status observer
    private var playerStatusObserverContext: Int = 1
    
    /// AVPlayer time observer token
    private var playerObserverToken: Any?
    
    /// Flag: Player status is being observed
    private var isObserving = false
    
    // -----------------------------------
    
    
    // ==================================================== //
    // MARK: Init
    // ==================================================== //
    public required init(assetURL: URL, externUrl: URL?=nil, duration: Double=0) {
        super.init(type: .video, duration: duration)
        self.assetUrl = assetURL
        self.interactionUrl = externUrl
        self.duration = duration
        self.contentType = .video
        self.asset = FAStoryAsset(with: AVPlayer())
        self.asset.externUrl = externUrl
    }
    
    deinit {
        if let p = player {
            p.pause()
        }
        
        if let item = playerItem {
            guard isObserving else {return}
            item.removeObserver(self,
                                forKeyPath: #keyPath(AVPlayerItem.status),
                                context: &playerStatusObserverContext)
            isObserving = false
        }
        
        if let t = contentTimer {
            t.invalidate()
        }
    }
    
    
    // ==================================================== //
    // MARK: Lifecycle
    // ==================================================== //
    /// observer
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &playerStatusObserverContext {
            if let _status = change?[.newKey] as? Int {
                
                guard let playerStatus = AVPlayerItem.Status(rawValue: _status) else {return}
                
                ///
                /// @default case is skipped intentionally
                /// so that the code won't compile in case
                /// a new status is added to the AVPlayerItem
                /// in future. Since this is operation critical, it's better to have to
                /// handle new status than not realizing this change
                ///
                switch playerStatus {
                case .unknown:
                    fallthrough
                case .failed:
                    delegate?.contentFailed(asset)
                case .readyToPlay:
                   delegate?.contentReady(asset)
                   player.play()
                default:
                    assert(false, "Please handle all cases from AVPlayer.Status")
                }
                playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
                isObserving = false
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // ==================================================== //
    // MARK: Methods
    // ==================================================== //
    
    // -----------------------------------
    // Public methods
    // -----------------------------------
    //
    // MARK: FAStoryContentProtocol
    func contentConfigure() {
        let asset = AVAsset(url: assetUrl)
        let _p = AVPlayerItem(asset: asset)
        
        delegate?.contentPlayerInitStarted()
        
        if isObserving {
            playerItem?.removeObserver(self,
                                       forKeyPath: #keyPath(AVPlayerItem.status),
                                       context: &playerStatusObserverContext)
        }
        
        isObserving = false
        
        playerItem = _p
        
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.status),
                               options: .new,
                               context: &playerStatusObserverContext)
        
        isObserving = true
        
        //
        // Check if the player is already initialized
        // if not, initialize it and manage the observers
        //
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
            
        } else {
            player.replaceCurrentItem(with: playerItem)
        }
        
        // set the player asset
        self.asset.content = player

    }
    
    /// Method to start the content
    public override func start() -> Bool {
     
        guard player != nil else {
            return false
        }
        
        if playerObserverToken == nil  {
            playerObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.02, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: nil) {[weak self] (_time) in
                guard let self = self else {return}
                self.isPaused = self.player.rate == 0
                self.playerProgress(currentTime: _time)
            }
        } else {
            player.play()
        }
        isPaused = player.rate == 0
        return true
    }
    
    /// Method to pause the content
    public override func pause() -> Bool {
        isPaused = true
        player.pause()
        return true
    }
    
    /// Method to stop the content
    public override func stop() {
        player?.pause()
        player?.seek(to: CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
    }
    // -----------------------------------
    
    
    // -----------------------------------
    // Private methods
    // -----------------------------------
    /// Player progress observer
    private func playerProgress(currentTime time: CMTime) {
        guard !isPaused, let i = playerItem else {return}
        
        let elapsed = time.seconds
        
        let progress: Double
        
        if i.duration.isIndefinite || !i.duration.isNumeric || !i.duration.isValid {
            progress = 0
        } else {
           progress = elapsed / i.duration.seconds
        }
        
        let stopped = progress >= 1
        
        delegate?.contentProgressChanged(progress)
        
        //
        // check if the player is done playing
        //
        if stopped {
            isPaused = true
            if isObserving {
                playerItem?.removeObserver(self,
                                           forKeyPath: #keyPath(AVPlayerItem.status),
                                           context: &playerStatusObserverContext)
            }
            
            isObserving = false
            
            if playerObserverToken != nil, let p = player {
                p.removeTimeObserver(playerObserverToken!)
            }
            delegate?.contentDisplayFinished(for: asset)
        }
    }
    // -----------------------------------
    
    
    
}
