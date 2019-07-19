//
//  FAStory.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 6.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit

/// Main story container object

final public class FAStory: NSObject, FAStoryTeller {
    // ==================================================== //
    // MARK: Properties
    // ==================================================== //
    
    // -----------------------------------
    // Public properties
    // -----------------------------------
    /// Name of the story as seen on the highlights
    public var name: String!
    
    /// Story previewImage as seen on the highlights
    public var previewImage: UIImage!
    
    /// Content(s) of the story
    public var content: [FAStoryAddible]?
    
    /// Nature of the content
    ///
    /// .builtIn || .online
    public var contentNature: FAStoryContentNature
    
    // -----------------------------------
    
    
    // -----------------------------------
    // Private properties
    // -----------------------------------
    
    // -----------------------------------
    
    
    // ==================================================== //
    // MARK: Init
    // ==================================================== //
    /// Full fledged initializer for a story object
    ///
    /// - parameter content: Any object that conforms to __FAStoryAddible__
    /// - parameter name: Name of the story object
    /// - parameter flag: True if the content is builtIn False if otherwise
    public init(with content: FAStoryAddible, name: String, builtIn flag: Bool = true, preview image: UIImage? = nil) {
        self.name = name
        self.content = [content]
        self.contentNature = flag ? .builtIn : .online
        //
        super.init()
        //
    }
    
    /// Convenience initializer
    ///
    /// The created story object nature will be __builtIn__
    public override init() {
        contentNature = .builtIn
        super.init()
    }

    
    // ==================================================== //
    // MARK: Methods
    // ==================================================== //
    
    // -----------------------------------
    // Public methods
    // -----------------------------------
    /// Method that adds a new content to this story
    public func addContent(_ content: FAStoryAddible) {
        if self.content != nil {
            self.content!.append(content)
        } else {
            self.content = [content]
        }
    }
    // -----------------------------------
    
    
    // -----------------------------------
    // Private methods
    // -----------------------------------
    
    // -----------------------------------
}
