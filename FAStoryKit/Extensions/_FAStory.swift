//
//  _FAStory.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 9.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import Foundation

public extension FAStory {
    
    convenience init?(dict: [String:Any]) {
        
        //
        // go over the dictionary to create the object
        //
        guard let name = dict["name"] as? String,
            let nature = dict["contentNature"] as? Int,
            let preview = dict["previewAsset"] as? String,
            let contents = dict["contents"] as? Array<[String:Any]> else {return nil}
     
        self.init()
        
        self.name = name
        self.contentNature = nature == 0 ? .builtIn : .online
        switch self.contentNature {
        case .online:
            break // TBA
            
        case .builtIn:
            self.previewImage = UIImage(named: preview)
        }
        
        for content in contents {
            guard let contentType = content["contentType"] as? Int,
                let assetName = content["assetName"] as? String,
                let duration = content["duration"] as? Double else {continue}
            
            let type: FAStoryContentType = contentType == 0 ? .image : .video
            
            let externalUrl: URL?
            if let _path = content["externalURL"] as? String, _path.isValidUrl() {
                externalUrl = URL(string: _path)
            } else {
                externalUrl = nil
            }
            
            let assetUrl: URL
        
            if let _url = URL(string: assetName) {
                assetUrl = _url
            } else {
                assetUrl = Bundle.main.url(forResource: assetName, withExtension: nil)!
                
            }
            
            
            switch type {
            case .image:
                let _content = FAStoryImageContent(assetURL: assetUrl, externUrl: externalUrl, duration: duration)
                _content.setContentNature(self.contentNature)
                self.addContent(_content)
            case .video:
                let _content = FAStoryVideoContent(assetURL: assetUrl, externUrl: externalUrl, duration: duration)
                _content.setContentNature(self.contentNature)
                self.addContent(_content)
            default:
                assert(false, "FAStory - Invalid content type, please implement the corresponding type.")
            }
            
        
        }
        
        
    }
}
