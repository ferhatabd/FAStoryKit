//
//  FAStoryContentNature.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 6.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import Foundation

/// Content nature defines whether the Story is
/// a built in one or a dynamic one that needs to be
/// streamed from an external resource

public enum FAStoryContentNature: Int {
    case builtIn = 0
    case online = 1 
}
