//
//  FAStoryDelegate.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 6.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit

public protocol FAStoryDelegate: class {
    /// cell horizontal spacing
    var cellHorizontalSpacing: CGFloat {get}
    
    /// cell height
    var cellHeight: CGFloat {get}
    
    /// cell aspect ratio
    var cellAspectRatio: CGFloat {get}
    
    /// display name font
    var displayNameFont: UIFont {get}
    
    /// vertical cell padding
    func verticalCellPadding() -> CGFloat
    
    /// did select
    func didSelect(row: Int) -> Void 
    
}

public extension FAStoryDelegate {
    /// cell horizontal spacing
    var cellHorizontalSpacing: CGFloat {
        return DefaultValues.shared.cellHorizontalSpacing
    }
    
    /// cell width
    var cellHeight: CGFloat {
        return DefaultValues.shared.cellWidth
    }
    
    /// cell aspect ratio
    var cellAspectRatio: CGFloat {
        return DefaultValues.shared.cellAspectRatio
    }
    
    /// display name font
    var displayNameFont: UIFont {
        return DefaultValues.shared.displayNameFont
    }
    
    /// vertical cell padding
    func verticalCellPadding() -> CGFloat { return 4 }
}
