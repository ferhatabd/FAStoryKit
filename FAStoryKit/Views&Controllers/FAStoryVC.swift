//
//  FAStoryVC.swift
//  FAStoryKit
//
//  Created by Ferhat Abdullahoglu on 7.07.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices
import FAGlobalKit

public protocol FAStoryViewControllerDelegate: class {
    /// Asks the delegee for an image to be used
    /// for the dismiss button
    func dismissButtonImage() -> UIImage?
}

final public class FAStoryViewController: UIViewController, StoryControllerDelegate, SwipeDismissInteractible {

  
    // ==================================================== //
    // MARK: IBOutlets
    // ==================================================== //
    
    
    // ==================================================== //
    // MARK: IBActions
    // ==================================================== //
    
    
    // ==================================================== //
    // MARK: Properties
    // ==================================================== //
    
    // -----------------------------------
    // Public properties
    // -----------------------------------
    
    // MARK: UIViewController overrides
    public override var prefersStatusBarHidden: Bool { return true }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .fade }
    
    // MARK: Self properties
    
    /// story object
    public var story: FAStory! {
        didSet {
            guard isViewLoaded else {return}
            guard let s = story else {return}
            storyController = FAStoryController(with: s)
            storyController.delegate = self
            nature = s.contentNature
            _configUI()
        }
    }
    
    /// gesture view for the VC dismisal
    public var gestureView: UIView {
        return view
    }
    
    /// Interaction controller for dismissal
    public var dismissInteractionController: SwipeInteractionController?
    
    
    /// delegate object
    public weak var delegate: FAStoryViewControllerDelegate?
 
    // -----------------------------------
    
    
    // -----------------------------------
    // Internal properties
    // -----------------------------------
    /// header height
    internal var headerHeight: CGFloat = 60
    
    
    // -----------------------------------
    // Private properties
    // -----------------------------------
    
    /// story controller
    private var storyController: FAStoryController!
    
    /// story nature
    private var nature: FAStoryContentNature!
    
    /// contentView
    private var contentView: UIView!
    
    /// overall page container view
    ///
    /// Contains the currentStoryContainers & header
    private var containerView: UIView!
    
    /// Header view
    private var headerView: UIView!
    
    /// preview imageView
    private var imgViewPreview: UIImageView!
    
    /// button to dismiss
    private var btnDismiss: UIButton!
    
    /// title label
    private var lblTitle: UILabel!
    
    /// story count indicator
    private var currentStoryIndicator: StoryIndicatorContainerView!
    
    /// UIImageView to show the image
    /// in case we have an image content
    private var imgView: UIImageView!
    
    /// Gesture recognizer to stop the story
    /// from playing and hiding the peripherals
    private var longPressRecognizer: UILongPressGestureRecognizer!
    
    /// Right edge tap for showing the next content
    private var rightEdgeTap: UITapGestureRecognizer!
    
    /// Left edge tap for showing the previous content
    private var leftEdgeTap: UITapGestureRecognizer!
    
    /// Right edge view
    private var rightEdgeView: UIView!
    
    /// Left edge view
    private var leftEdgeView: UIView!
    
    /// video player view
    private var playerView: FAPlayerView!
    
    /// Activity view
    private var activityView: UIActivityIndicatorView!
    
    /// Error label
    private var lblError: UILabel!
    
    /// Error container view
    private var errorContainerView: UIView!
    
    /// Extenrnal link view
    private var externUrlView: ExternalLinkControllerView!
    
    /// ContentView bottom offset
    private var kContentBottomOffset: CGFloat = 60
    
    /// Safari VC for external url's
    private var safariVc: SFSafariViewController!
    
    /// Gradient layer for the headerView
    private let headerGradientLayer = CAGradientLayer()
    
    /// Gradient layer view
    /// It's the background view of the headerView
    /// so that the rest of the content on the header
    /// is not overlayed
    private var overlayView: UIView!
    // -----------------------------------
    
    
    // ==================================================== //
    // MARK: Init
    // ==================================================== //
    deinit {
        storyController?.stop()
        print("DeInit: FAStoryViewController")
    }
    
    // ==================================================== //
    // MARK: VC lifecycle
    // ==================================================== //
    public override func viewDidLoad() {
        super.viewDidLoad()
        _init()
        _configUI()
        _gradSetup()
        
        //
        // Prepeare the dismiss interactor in case
        // the VC is not embedded in a navigationController
        // if it is, it's upto the navigationController
        // to decide whether or not to have a dismiss interaction controller
        //
        if navigationController == nil {
            dismissInteractionController = SwipeInteractionController(viewController: self)
        }
    }
 
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layoutIfNeeded()
        if let iv = imgViewPreview {
            iv.layer.cornerRadius = iv.frame.height / 2
        }
        _addGradientLayer()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if parent != nil {
            FAStoryVcStack.shared.set(currentViewController: self)
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        storyController.start()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        storyController?.pause()
    }
  
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        storyController?.stop()
    }
    
    
    // ==================================================== //
    // MARK: Methods
    // ==================================================== //
    
    // -----------------------------------
    // Public methods
    // -----------------------------------
    
    //
    // MARK: StoryControllerDelegate
    //
    func storyProgressChanged(_ progress: Double) {
        let p = CGFloat(progress)
        currentStoryIndicator?.setProgress(p)
    }
    
    func shouldShowNext() -> Bool {
        guard let containerVC = parent as? FAStoryContainer else { return false }
        let canShow = containerVC.canShowNext
        if canShow {
            containerVC.jumpForward()
        }
        return canShow
    }
    
    func shouldShowPrevious() -> Bool {
        guard let containerVC = parent as? FAStoryContainer else { return false }
        let canShow = containerVC.canShowPrevious
        if canShow {
            containerVC.jumpBackward()
        }
        return canShow
    }
    
    func storyAssetDownloadProgress<Asset>(_ asset: FAStoryAsset<Asset>, progress: Float) { }
    
    func storyAssetDownloadCompleted<Asset>(_ asset: FAStoryAsset<Asset>) { }
    
    func storyAssetChanged<Asset>(_ asset: FAStoryAsset<Asset>?) {
        print("story content changed")
        
        _hideActivity()
        
        if let a = asset as? FAStoryAsset<UIImage> {
            _contentConfigImage(with: a.content)
        } else if let a = asset as? FAStoryAsset<AVPlayer> {
            _contentConfigVideo(with: a.content)
        }
        
        _externUrlView(url: asset?.externUrl)
        
    }
    
    func storyAssetInitStart() {
        _displayActivity()
    }
    
    func storyAssetReady<Asset>(_ asset: FAStoryAsset<Asset>?) {
        _hideActivity()
        if let _asset = asset as? FAStoryAsset<AVPlayer> {
            _contentConfigVideo(with: _asset.content)
        } else if let _asset = asset as? FAStoryAsset<UIImage> {
            _contentConfigImage(with: _asset.content)
        }
    }
    
    func storyAssetFailed<Asset>(_ asset: FAStoryAsset<Asset>?) {
        _hideActivity()
        _displayError()
    }

    func storyCurrentContentFinished() {
        let isParentBeingDismissed = parent?.isBeingDismissed ?? false
        
        if !storyController.setNext() && !isBeingDismissed && !isParentBeingDismissed {
            presentingViewController?.dismiss(animated: true)
        }  else {
            storyController.start()
            _ = currentStoryIndicator.next()
        }
    }
    // -----------------------------------
    
    
    // -----------------------------------
    // Private methods
    // -----------------------------------
    
    /// self initialiation
    private func _init() {
        view.backgroundColor = .clear
        
        // container view
        _containerView()
        
        // indicators
        _indicators()
        
        // contentView
        _contentView()
        
        // header
        _header()
        
        // gestureRecgonizer
        _configureGestures()
        
        view.bringSubviewToFront(containerView)
        view.bringSubviewToFront(leftEdgeView)
        view.bringSubviewToFront(rightEdgeView)
        headerView.sendSubviewToBack(overlayView)
        containerView.bringSubviewToFront(currentStoryIndicator)
    }
    
    public func start() { }
    
    public func pause() {
        storyController?.pause()
    }
    
    public func stop() {
        
    }
    

    /// Internal UI config
    private func _configUI() {
        guard story != nil else {return}
       
        imgViewPreview.image = story.previewImage
        lblTitle.text = story.name
        
        // indicators
        // configure the indicators with a new set
        currentStoryIndicator.setCount(story.content?.count ?? 0)
        
        //
        // configure the imageView for the main content
        //
        imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        imgView.isHidden = false
        
        contentView.addSubview(imgView)
        
        imgView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        //
        // configure the playerView for the main content
        //
        playerView = FAPlayerView()
        
        contentView.addSubview(playerView)
        
        playerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        playerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        playerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        storyController = FAStoryController(with: story)
        storyController.delegate = self
 
    }
    
    
    /// containerView setup
    private func _containerView() {
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        
        view.addSubview(containerView)
        
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        if #available(iOS 11, *) {
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            containerView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        }
    }
    
    
    /// contentView setup
    private func _contentView() {
        //
        // intiailize the contentView
        //
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .black
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true
        
        view.addSubview(contentView)
        
        if #available(iOS 11, *) {
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant:  -kContentBottomOffset).isActive = true
        } else {
            contentView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
            contentView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -kContentBottomOffset).isActive = true
        }
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }
    
    
    /// indicatorContainerSetup
    private func _indicators() {
        currentStoryIndicator = StoryIndicatorContainerView()
        containerView.addSubview(currentStoryIndicator)
        currentStoryIndicator.heightAnchor.constraint(equalToConstant: 4).isActive = true
        currentStoryIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2).isActive = true
        currentStoryIndicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2).isActive = true
        currentStoryIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).isActive = true
        
    }
    
    

    /// Colors for the gradients
    private func _getColors() -> [CGColor] {
        return [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor]
    }
    
  
    /// Gradient locations
    private func _getLocations() -> [CGFloat] {
        return [0.4,  0.9]
    }
    
     /// Gradient setup
    private func _gradSetup() {
        headerGradientLayer.startPoint = CGPoint(x: 0.6, y: 0)
        headerGradientLayer.endPoint = CGPoint(x: 0.6, y: 1)
        
        let colors = _getColors()
        headerGradientLayer.colors = colors
        headerGradientLayer.isOpaque = false
        headerGradientLayer.locations = nil//_getLocations() as [NSNumber]?
    }
    
   
    /// Method to add the gradient layer
    private func _addGradientLayer(){
        if headerGradientLayer.superlayer == nil {
            headerGradientLayer.frame = overlayView.layer.bounds
            overlayView.layer.addSublayer(headerGradientLayer)
        }
    }
    
    /// preview header setup
    private func _header() {
        // header container
        headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .clear
        
        containerView.addSubview(headerView)
        
        headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: headerHeight).isActive = true
        
        // imageView
        imgViewPreview = UIImageView()
        imgViewPreview.translatesAutoresizingMaskIntoConstraints = false
        imgViewPreview.backgroundColor = .clear
        imgViewPreview.contentMode = .scaleAspectFill
        imgViewPreview.clipsToBounds = true
        imgViewPreview.layer.masksToBounds = true
        
        headerView.addSubview(imgViewPreview)
        
        imgViewPreview.topAnchor.constraint(equalTo: currentStoryIndicator.bottomAnchor, constant: 8).isActive = true
        imgViewPreview.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 4).isActive = true
        imgViewPreview.widthAnchor.constraint(equalToConstant: 40).isActive = true
        imgViewPreview.heightAnchor.constraint(equalTo: imgViewPreview.widthAnchor).isActive = true
        
        // title label
        lblTitle = UILabel()
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        lblTitle.backgroundColor = .clear
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: "Brown-Regular", size: 16)
        lblTitle.textAlignment = .left
        lblTitle.numberOfLines = 1
        
        headerView.addSubview(lblTitle)
        
        lblTitle.leadingAnchor.constraint(equalTo: imgViewPreview.trailingAnchor, constant: 12).isActive = true
        lblTitle.heightAnchor.constraint(equalToConstant: 40).isActive = true
        lblTitle.centerYAnchor.constraint(equalTo: imgViewPreview.centerYAnchor).isActive = true
        
        // dismiss button
        btnDismiss = UIButton()
        btnDismiss.translatesAutoresizingMaskIntoConstraints = false
        btnDismiss.backgroundColor = .clear
        btnDismiss.tintColor = .white
        btnDismiss.contentMode = .scaleAspectFit
        if let image = delegate?.dismissButtonImage() {
            let imgView = UIImageView()
            imgView.translatesAutoresizingMaskIntoConstraints = false
            imgView.backgroundColor = .clear
            imgView.tintColor = .white
            imgView.image = image
            imgView.contentMode = .scaleAspectFill
            //
            btnDismiss.addSubview(imgView)
            //
            imgView.widthAnchor.constraint(equalTo: btnDismiss.widthAnchor, multiplier: 0.4).isActive = true
            imgView.heightAnchor.constraint(equalTo: btnDismiss.heightAnchor, multiplier: 0.4).isActive = true
            imgView.centerXAnchor.constraint(equalTo: btnDismiss.centerXAnchor).isActive = true
            imgView.centerYAnchor.constraint(equalTo: btnDismiss.centerYAnchor).isActive = true
    
        } else {
            btnDismiss.setTitle("X", for: .normal)
        }
        btnDismiss.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        btnDismiss.titleLabel?.textAlignment = .center
        
        
        headerView.addSubview(btnDismiss)
        
        btnDismiss.widthAnchor.constraint(equalToConstant: 40).isActive = true
        btnDismiss.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnDismiss.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -4).isActive = true
        btnDismiss.centerYAnchor.constraint(equalTo: imgViewPreview.centerYAnchor).isActive = true
        btnDismiss.addTarget(self, action: #selector(_dismiss), for: .touchUpInside)
        
        containerView.bringSubviewToFront(btnDismiss)
        
        overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = .clear
        
        headerView.addSubview(overlayView)
        
        overlayView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        overlayView.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
    
    }
    
    
    /// gesture recognizer setup
    private func _configureGestures() {
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(_longPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.2
        view.addGestureRecognizer(longPressRecognizer)
        
        //
        // create the right edge view for the next content tap
        //
        rightEdgeTap = UITapGestureRecognizer(target: self, action: #selector(_nextTap(_:)))
        rightEdgeTap.delegate = self
        rightEdgeView = _createEdgeView(rigtEdge: true)
        rightEdgeView.addGestureRecognizer(rightEdgeTap)
        
        //
        // create the left edge view for the next content tap
        //
        leftEdgeTap = UITapGestureRecognizer(target: self, action: #selector(_prevTap(_:)))
        leftEdgeTap.delegate = self
        leftEdgeView = _createEdgeView(rigtEdge: false)
        leftEdgeView.addGestureRecognizer(leftEdgeTap)
    }
    
    
    /// create edge view
    private func _createEdgeView(rigtEdge: Bool) -> UIView {
        
        let _view = UIView()
        _view.backgroundColor = .clear
        _view.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.insertSubview(_view, at: 0)
        
        _view.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.4).isActive = true
        _view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        _view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        if rigtEdge {
            _view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        } else {
            _view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        }
        
        return _view
    }
    
    
    /// External URL view
    private func _externUrlView(url: URL?) {
        guard let _url = url else {
            externUrlView?.removeFromSuperview()
            if externUrlView != nil {
                externUrlView = nil 
            }
            return
        }
        
        if externUrlView == nil {
            externUrlView = ExternalLinkControllerView(with: _url)
            externUrlView.title = "Daha fazlası"
            externUrlView.color = .white
            externUrlView.font = UIFont(name: "Brown-Regular", size: 14)
            externUrlView.delegate = self
            
            containerView.addSubview(externUrlView)
            containerView.bringSubviewToFront(externUrlView)
            
            externUrlView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            externUrlView.heightAnchor.constraint(equalToConstant: kContentBottomOffset).isActive = true
            externUrlView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            
            if #available(iOS 11, *) {
                externUrlView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            } else {
                externUrlView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
            }
        } else {
            externUrlView.replaceUrl(_url)
        }
        
    }
    
    
    /// longHold gesture
    /// touch down
    @objc
    private func _longPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            UIView.animate(withDuration: 0.2) {
                self.containerView.alpha = 0
            }
            storyController?.pause()
        default:
            UIView.animate(withDuration: 0.2) {
                self.containerView.alpha = 1
            }
            storyController?.start()
        }
    }
    
    
    /// rightEdge tap
    @objc
    private func _nextTap(_ sender: UITapGestureRecognizer) {
        guard storyController != nil else {return}
        if storyController.setNext() {
            _ = currentStoryIndicator.next()
        }
    }
    
    
    /// leftEdge tap
    @objc
    private func _prevTap(_ sender: UITapGestureRecognizer) {
        guard storyController != nil else {return}
        _ = storyController.setPrev()
        _ = currentStoryIndicator.previous()
    }
    
    
    /// Dismiss button
    @objc
    private func _dismiss() {
        if let _presenting = presentingViewController {
            _presenting.dismiss(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    
    /// Configure the view for an image content
    private func _contentConfigImage(with image: UIImage) {
        DispatchQueue.main.async {
            self.errorContainerView?.isHidden = true
            self.contentView.isHidden = false
            //
            self.imgView.image = image
            //
            self.playerView?.isHidden = true
            self.imgView?.isHidden = false
        }
     
    }
    
    
    /// Configure the view for a video content
    private func _contentConfigVideo(with player: AVPlayer) {
        DispatchQueue.main.async {
            self.errorContainerView?.isHidden = true
            self.contentView.isHidden = false
            //
            self.imgView?.isHidden = true
            self.playerView?.isHidden = false
            //
            guard let p = self.playerView else {return}
            
            p.player = player
            p.play()
        }
      
    }
    
    
    /// Display error
    private func _displayError() {
        //
        // Create the error container view first
        //
        errorContainerView?.removeFromSuperview()
        errorContainerView = UIView()
        errorContainerView.translatesAutoresizingMaskIntoConstraints = false
        errorContainerView.backgroundColor = .black
        
        view.addSubview(errorContainerView)
        
        errorContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        errorContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        errorContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        errorContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        view.insertSubview(errorContainerView, belowSubview: containerView)
        
        lblError?.removeFromSuperview()
        lblError = UILabel()
        lblError.backgroundColor = .clear
        lblError.alpha = 0
        lblError.translatesAutoresizingMaskIntoConstraints = false
        lblError.numberOfLines = 0
        lblError.font = UIFont(name: "Brown-Regular", size: 16)
        lblError.textColor = .white
        lblError.text = "Bu içeriğe şu anda ulaşılamıyor, lütfen daha sonra tekrar deneyiniz."
        lblError.textAlignment = .center
        
        
        errorContainerView.addSubview(lblError)
        
        lblError.widthAnchor.constraint(equalTo: errorContainerView.widthAnchor, multiplier: 0.8).isActive = true
        lblError.centerXAnchor.constraint(equalTo: errorContainerView.centerXAnchor).isActive = true
        lblError.centerYAnchor.constraint(equalTo: errorContainerView.centerYAnchor).isActive = true
        lblError.heightAnchor.constraint(lessThanOrEqualTo: errorContainerView.heightAnchor, multiplier: 0.5).isActive = true
        
        view.layoutIfNeeded()
        
        contentView.isHidden = true
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else {return}
            self.lblError.alpha = 1
        }
    }
    
    
    /// Show the activity view
    private func _displayActivity() {
        activityView?.removeFromSuperview()
        activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        contentView.insertSubview(activityView, at: 0)
        activityView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        activityView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        activityView.startAnimating()
    }
    
    
    /// Hide the activity view
    private func _hideActivity() {
        activityView?.stopAnimating()
        activityView?.removeFromSuperview()
    }
    // -----------------------------------
}

//
// MARK: ExternalLinkControllerDelegate
//
extension FAStoryViewController: ExternalLinkControllerDelegate, SFSafariViewControllerDelegate {
    func openLink(_ url: URL) {
        safariVc = SFSafariViewController(url: url)
        safariVc.delegate = self
        storyController.pause()
        present(safariVc, animated: true)
    }
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        storyController.start()
    }
}


//
// MARK: UIGestureRecognizerDelegate
//
extension FAStoryViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer === rightEdgeTap {
            return !btnDismiss.frame.contains(gestureRecognizer.location(in: headerView))
        }
        
        return true
    }
    
}

//
// MARK: NSMutableCopying
//
extension FAStoryViewController: NSMutableCopying {
    public func mutableCopy(with zone: NSZone? = nil) -> Any {
        let vc = FAStoryViewController()
        vc.story = story
        return vc
    }
}
