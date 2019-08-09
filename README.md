#  Using FAStoryKit to implement an Instagram highlights alike

Provides an easy setup for displaying content like Instagram highlights.
Can be used as an alternative onboarding process or just to simply communicate new things, campaigns, features etc to the users.

## Features 

- Story content implementation 
- Generic content backing template (see __FAStoryContentTemplate__) for future extensions.
Currently __UIImage__ and __AVPlayer__ is supported as possible contents of a story but it's possible to subclass the generic template to create further content types.
- Custom container view for the highlights (see __FAStoryView__)
- Custom view controller that is able to display an array of stories (therefore __[FAStory]__) with next/previous/pause on touch down action support  (see __FAStoryViewController__)
- Segmented progress to display the current progress of the stories embedded in the view controller.

## Some previews 


![Alt text](/../screenshots/1.png?raw=true "FAStoryView in a view controller")


![Alt text](/../screenshots/2.png?raw=true "FAStoryViewController that has 2 stories")


![Alt text](/../screenshots/3.png?raw=true "2nd story with a detail view button")


![Alt text](/../screenshots/4.png?raw=true "Details of the story displayed in Safari")


## Configuring the FAStoryView in any parent view controller

- Configure the view in your viewController

```swift
storyView = FAStoryView(frame: .zero)     
storyView.backgroundColor = .clear
storyView.delegate = self
storyView.dataSource = self
```

- Implement the delegate & datasource protocols for configurations and display modifications 

```swift
public protocol FAStoryDelegate: class {
    /// cell horizontal spacing
    var cellHorizontalSpacing: CGFloat {get}

    /// cell height
    var cellHeight: CGFloat {get}

    /// cell aspect ratio
    var cellAspectRatio: CGFloat {get}

    /// display name font
    var displayNameFont: UIFont {get}

    /// display name color
    var displayNameColor: UIColor {get}

    /// vertical cell padding
    func verticalCellPadding() -> CGFloat

    /// did select
    func didSelect(row: Int) -> Void 
}
```

- The datasource asks for the Stories to be displayed. Only thing that needs to be done is to return an array of the __FAStory__ objects.

```swift
extension YourVC: FAStoryDataSource {
    func stories() -> [FAStory]? {
        return storyHandler.stories
    }
}
```


## FAStoryViewController to display the contents of the story 

Currently the framework supports __UIImage__ and __AVPlayer__ objects as the contents of the stories. Therefore images and videos can be displayed in any Story view. 

To do that there is a dedicate ViewController that controls the rewind / next / previous features and that displays a progress indicator as well. 

All it takes is to initialize the viewController, pass the __FAStory__ object and present the view controller. 

```swift
storyVc = FAStoryViewController()
storyVc.delegate = self
storyVc.story = _stories[idx]

storyVc.modalPresentationStyle = .overFullScreen
storyVc.modalPresentationCapturesStatusBarAppearance = true
storyVc.transitioningDelegate = self

present(storyVc, animated: true)
```



