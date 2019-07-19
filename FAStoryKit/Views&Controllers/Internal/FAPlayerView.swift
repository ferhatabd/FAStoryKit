//
//  FAPlayerView.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 11.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit
import AVFoundation

internal class FAPlayerView: UIView {

    
    // ==================================================== //
    // MARK: Properties
    // ==================================================== //
    
    // -----------------------------------
    // Public properties
    // -----------------------------------
    
    /// Default layer class is overridden
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    
    /// Player object
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
            currenItem = newValue?.currentItem
        }
    }
    

    /// Player Layer
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    // -----------------------------------
    
    
    // -----------------------------------
    // Private properties
    // -----------------------------------
    /// Current playerItem
    private var currenItem: AVPlayerItem!
    // -----------------------------------
    
    
    // ==================================================== //
    // MARK: Init
    // ==================================================== //
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
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
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }

    // -----------------------------------
    
    
    // -----------------------------------
    // Private methods
    // -----------------------------------

   
 
    // -----------------------------------

}
