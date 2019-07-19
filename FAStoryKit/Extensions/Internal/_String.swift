//
//  _String.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 15.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import Foundation

internal extension String {
    
    /// method to validate a URL candidate
    /// before adtually initializing it with URL(string:)
    func isValidUrl() -> Bool {
        let urlRegex = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegex)
        
        return urlTest.evaluate(with: self)
    }
 
}
