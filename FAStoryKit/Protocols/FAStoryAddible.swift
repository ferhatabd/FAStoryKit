//
//  FAStoryAddible.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 6.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import Foundation


///
/// Define the content necessities of a FAStory so that
/// any object that adopts the protocol will be eligible
/// to be added as a FAStory



public protocol FAStoryAddible {
    
    /// content type
    var contentType: FAStoryContentType {get set}
    
    /// asset url
    var assetUrl: URL! {get set}
    
    /// external interaction URL if there is any
    var interactionUrl: URL? {get set}
    
    /// duration for the content
    var duration: Double {get set}
    
    /// content display start
    func start() -> Bool
    
    /// content display pause
    func pause() -> Bool
    
    /// content display stop
    func stop() 
    
}


