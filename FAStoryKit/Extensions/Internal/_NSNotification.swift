//
//  _NSNotification.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 29.09.2019.
//

import Foundation


internal extension Notification.Name {
    /// notification name for a story being seen for the first time
    static var storySeen: Notification.Name {
        return Notification.Name(rawValue: "storySeenNotification")
    }
}
