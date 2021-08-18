//
//  FAStoryDataSource.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 6.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit

public protocol FAStoryDataSource: AnyObject {
    /// Method to ask for the Stories
    func stories() -> [FAStory]?
}

