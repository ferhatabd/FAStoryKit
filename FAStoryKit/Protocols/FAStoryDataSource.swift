//
//  FAStoryDataSource.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 6.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit

public protocol FAStoryDataSource: class {
    func stories() -> [FAStory]?
}
