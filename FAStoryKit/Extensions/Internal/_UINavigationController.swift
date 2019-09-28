//
//  _UINavigationController.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 28.09.2019.
//

import UIKit

internal extension UINavigationController {
    
    /// Flag that determines whether a push operation is currenlty ongoing
    /// 
    /// - important:
    /// The default implementation does nothing. Subclasses should override this property
    /// to implement the feature
    var isPushing: Bool {
        return false
    }
    
}
