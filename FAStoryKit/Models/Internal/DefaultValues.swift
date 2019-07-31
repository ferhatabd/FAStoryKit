//
//  DefaultValues.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 7.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit

internal class DefaultValues: FAStoryDelegate {
    
    /// internally shared singleton
    static var shared = DefaultValues()
    
    /// cell horizontal spacing
    var cellHorizontalSpacing: CGFloat {
        return 4
    }
    
    /// cell width
    var cellWidth: CGFloat {
        return 80
    }
    
    /// cell aspect ratio
    var cellAspectRatio: CGFloat {
        return 1
    }
    
    /// display name font
    var displayNameFont: UIFont {
        return UIFont(name: "Brown-Regular", size: 12)!
    }
    
    func didSelect(row: Int) {  }
    
    func verticalCellPadding() -> CGFloat {
        return 4
    }
}
