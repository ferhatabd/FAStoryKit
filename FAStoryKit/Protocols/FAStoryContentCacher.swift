//
//  FAStoryContentCacher.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 11.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import Foundation
import SessionKit

///
/// Protocol for caching the content
///
/// The cached content will have an expiration date
/// and will be automatically purged by the system.
///
/// Here FAStoryContentCacher handles the downloading & caching
/// of the content making use of NSCache
///
/// Task is basically to download the asset and then to cache it
/// Then upon request the cacher will try and return the cached content
/// if it's purged, it'll then reinitiate a download process

/// Download & progress reporting of the content is handled
/// by __SessionDownloadable__ protocol from __SessionKit__
/// It wraps all the necessary features for downloading an asset
///
/// __FAStoryContentCacher__ overrides the __SessionDownloadable__'s delegate methods
/// to implement its own caching mechanism

public enum FAStoryContentCacherError: Error {
    case cacheNotInitialized
}

public protocol FAStoryContentCacher: SessionDownloadable, NSCacheDelegate {
    
    /// Cache handler
    var cacher: NSCache<AnyObject, AnyObject>! { get set }
    
    //
    // MARK: Cache properties
    //
    /// name of the cache
    var cacheName: String { get }
    
    /// cache should purge released object
    var shouldPurgeWhenReleased: Bool { get }
    
    /// content url
    var assetUrl: URL! { get set }
    
    
}

//
// MARK: Default functionality
//
public extension FAStoryContentCacher {
    /// Method to initialize the cacher
    func start() {
        cacher = NSCache()
        cacher.name = cacheName
        cacher.evictsObjectsWithDiscardedContent = shouldPurgeWhenReleased
        cacher.delegate = self
    }
    
    /// Get object
    func getObject(withName name: String) throws -> AnyObject? {
        guard cacher != nil else {
            throw FAStoryContentCacherError.cacheNotInitialized
        }
        
        return cacher.object(forKey: name as AnyObject)
    }
    
    /// Download a non-existing object
    func downloadContent(name: String, asset: URL) {
        startDownload(url: asset, name: name, destination: .toCache)
    }
    
}

//
// MARK: Download handling - opaque to delegee objects
//
public extension FAStoryContentCacher {
    /**
     Method to initiate a download
     - parameters:
        - url: URL to download from
        - name: Name that will be used for saving downloaded file
        - destination: Destination to save the downloaded file
     */
    func startDownload(url: URL, name: String, destination: FileDestination_enm) {
        print("path: \(FileHandler.shared.linkToCache)")
        //
        // Initialize the service
        //
        let _type: String?

        if let __type = url.path.split(separator: "/", maxSplits: .max, omittingEmptySubsequences: true).last {
            if let c = __type.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: true).last {
                _type = String(c)
            } else {
                _type = nil
            }
        } else {
            _type = nil
        }
       
        guard let _service = DownloadService(url: url,
                                             username: nil,
                                             password: nil,
                                             destPath: .toCache,
                                             filename: name,
                                             fileType: _type) else {return}
        
        downloadService = _service
        downloadService.delegate = self
        downloadService.start()
        
    }
    
    func dlComplete(toPath: String) {
        guard let i = UIImage(contentsOfFile: toPath), let key = assetUrl else {return}
        cacher.setObject(i, forKey: key as AnyObject)
    }
    
    func dlProgress(_ progress: Float) {
        self.downloadProgress = progress
        print("dl progress: \(progress)")
    }
    
    func dlError(err: Error?, errType: DonwloadServiceErrors_enm) {
        print("dl error")
    }
}
