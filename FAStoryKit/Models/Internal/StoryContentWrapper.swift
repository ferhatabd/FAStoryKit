//
//  StoryContentWrapper.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 15.08.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import Foundation



/// Wrapper struct for the story contents
///
/// Instead of directly decoding to __FAStoryAddible__ protocol
/// this struct is decoded first and then added to the contents of the story
internal struct _StoryContentWrapper: Decodable {
    /// content type
    var contentType: FAStoryContentType
    
    /// external interaction URL if there is any
    var interactionUrl: String?
    
    /// duration for the content
    var duration: Double
    
    /// asset name
    var assetName: String
    
    enum CodingKeys: String, CodingKey {
        case assetName = "assetName"
        case contentType
        case interactionUrl = "externalURL"
        case duration
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: _StoryContentWrapper.CodingKeys.self)
        let _contentType = try values.decode(Int.self, forKey: .contentType)
        contentType = FAStoryContentType(rawValue: _contentType)!
        assetName = try values.decode(String.self, forKey: .assetName)
        duration = try values.decode(Double.self, forKey: .duration)
        interactionUrl = try? values.decode(String.self, forKey: .interactionUrl)
    }
    
}
