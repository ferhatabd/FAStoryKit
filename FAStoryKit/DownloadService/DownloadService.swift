//
//  DownloadService.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 18.08.2021.
//  Copyright © 2021 Ferhat Abdullahoglu. All rights reserved.
//

import Foundation

public enum DonwloadServiceErrorsEnum {
    case sessionCantBeCreated
    case loginFailed
    case fileCantBeRemoved
    case fileCantBeCopied
    case urlSessionError
}

/* ==================================================== */
/* DownloadService protocols                            */
/* ==================================================== */
public protocol DownloadServiceDelegate: AnyObject {
    func dlError(err: Error?, errType: DonwloadServiceErrorsEnum)   // Error occured during the download session
    func dlComplete(toPath: String)                                 // Download completed and the file has been moved to the "toPath"
    func dlProgress(_ progress: Float)
}


/* ==================================================== */
/* DlHandler_typ definition                             */
/* ==================================================== */
public struct DlHandler {
    var url: URL                        // Url to download from
    var username: String?               // Username if log in is required
    var password: String?               // Password in case a login is required
    var destFileName: String?           // The name of the final file - if this is empty than the downloade file will not be copied
    var fileType: String?               // Type of the final file
    var middleFolder: String?
    var sDestFolder: String? {          // Destination folder in String
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.absoluteString
    }
    
    public var destPathFinal: String? {        // Destination path in URL if the downloaded file needs to be copied to somewhere
        get {
            if let destination = sDestFolder,
               let destinationUrl = URL(string: destination),
               let tmpDestfileName = destFileName {
                var toAppend : String!
                if let tmpFileType = fileType {
                    toAppend = "\(tmpDestfileName).\(tmpFileType)"
                } else {
                    toAppend = "\(tmpDestfileName)"
                }
                return destinationUrl.appendingPathComponent(toAppend).path
            }
            return nil
        } /* end of the get statement */
    } /* var destPathFinal */
    
    // MARKS: Struct initialization
    init?(url: URL, username: String?, password: String?, filename: String?, fileType: String?) {
        if url.absoluteString.isEmpty {
            return nil
        } else {
            self.url = url
            if username != nil {self.username = username}
            if password != nil {self.password = password}
            if filename != nil {self.destFileName = filename}
            if fileType != nil {self.fileType = fileType}
        }
    }
} // DlHandler_typ;

/* ==================================================== */
/* DownloadService class definitions                    */
/* ==================================================== */
public class DownloadService: NSObject {
    // MARKS: Members
    // Public members
    var dlHAndler: DlHandler?
    var username: String?
    var password: String?
    var url: URL
    var fileName: String?
    var fileType: String?
    weak var delegate: DownloadServiceDelegate?
    @objc
    var progress: Float {
        return bytesWritten/bytesExpected * 100
    }
    
    // Private members
    private var logInRequired: Bool?
    fileprivate var uUrl: URL!
    fileprivate var urlSession: URLSession!
    fileprivate var dlTask: URLSessionDownloadTask!
    private var shouldBeCopied: Bool?
    fileprivate var fileManager: FileManager!
    fileprivate var bytesExpected: Float = 0
    fileprivate var bytesWritten: Float = 0
    
    
    // MARKS: Initialization
    init?(url: URL, username: String?, password: String?, filename: String?, fileType: String?, middleFolder: String?=nil) {
        if url.absoluteString.isEmpty {
            self.delegate?.dlError(err: nil, errType: .sessionCantBeCreated)
            print("Download Service: Url is empty")
            return nil
        } else {
            // Check the user credentials info -> both should be empty or both should has information
            if (username == nil && password == nil) {
                self.logInRequired = false
            } else if (username != nil && password != nil) {
                self.username = username
                self.password = password
                self.logInRequired = true
            } else {
                self.delegate?.dlError(err: nil, errType: .sessionCantBeCreated)
                print("Download Service: Invalid credentials - check the parameters")
                return nil
            }
            //
            self.url = url
            if filename != nil {self.fileName = filename}
            if fileName != nil {
                self.shouldBeCopied = true
            } else {
                self.shouldBeCopied = false
            }
            if let tmpFileType = fileType {
                self.fileType = tmpFileType
            }
            //
            guard let tmpHandler = DlHandler(url: self.url, username: self.username, password: self.password, filename: self.fileName, fileType: self.fileType) else {return nil}
            self.dlHAndler = tmpHandler
            self.dlHAndler?.middleFolder = middleFolder
            super.init()
            self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
//            guard let tmpUrl = URL(string: self.url) else {return nil}
            self.dlTask = self.urlSession.downloadTask(with: self.url)
            self.fileManager = FileManager.default
        } /* if url.isempty */
    } // end of the initializer
    
    
    // MARKS: Methods
    // Start the download process
    func start() {
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            self?.dlTask.resume()
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        }
        
    }
    
    // Copy the downloaded file to the local folder
    func moveToLocal(src: String) {
        // Unwrap optionals
        guard (self.dlHAndler?.sDestFolder) != nil else {return}
        guard let tmpPath = self.dlHAndler?.destPathFinal else {return}
        
        // Check first if the local copy already exists at the destination path
        if fileManager.fileExists(atPath: tmpPath) { // file exists -> needs to be removed
            do {
                try fileManager?.removeItem(atPath: tmpPath)
            } catch {
                print("File cannot be removed!")
                self.delegate?.dlError(err: error, errType: .fileCantBeRemoved)  // Notify the delegate
                self.urlSession.invalidateAndCancel()
                return
            }
        }
       
        // Move the file to local copy
        do {
            try fileManager.moveItem(atPath: src, toPath: tmpPath)
            self.delegate?.dlComplete(toPath: tmpPath)
        } catch {
            print(error.localizedDescription)
            self.delegate?.dlError(err: error, errType: .fileCantBeCopied)
            self.urlSession.invalidateAndCancel()
        }
    } /* moveToLocal() */
    
    deinit {
        self.urlSession.invalidateAndCancel()
        self.dlHAndler = nil
        self.fileManager = nil
        self.urlSession.invalidateAndCancel()
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        print("DeInit: DownloadService")
    }
    
} /* DownloadService */


/* ==================================================== */
/* Conforming to URLSession protocols                   */
/* ==================================================== */
extension DownloadService: URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.moveToLocal(src: location.path)
        self.urlSession.invalidateAndCancel()
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let err = error?.localizedDescription { // An error has occured
            print(err)
            self.delegate?.dlError(err: error, errType: .urlSessionError)
            self.urlSession.invalidateAndCancel()
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.bytesWritten = Float(totalBytesWritten)
        bytesExpected = Float(totalBytesExpectedToWrite)
        delegate?.dlProgress(progress)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil { // An error has occurred
            print(error?.localizedDescription as Any)
            self.delegate?.dlError(err: error, errType: .urlSessionError)
            self.urlSession.invalidateAndCancel()
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
