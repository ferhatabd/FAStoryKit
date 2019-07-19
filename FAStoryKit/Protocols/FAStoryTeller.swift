//
//  FAStoryTeller.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 6.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit

/// Defines a story serving content

public protocol FAStoryTeller {
    
    /// name of the story
    var name: String! {get set}
    
    /// preview image to be displayed
    var previewImage: UIImage! {get set}
    
    /// content that's included under the story
    var content: [FAStoryAddible]? {get set}
    
    /// nature of the content - whether the content is built in or online
    var contentNature: FAStoryContentNature {get set}
    
}
