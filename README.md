#  Using FAStoryKit to implement an Instagram highlights alike

Provides an easy setup for displaying content like Instagram highlights.
Can be used as an alternative onboarding process or just to simply communicate new things, campaigns, features etc to the users.

## Usage 

- Configure the view in your viewController

-- swift
> storyView = FAStoryView(frame: .zero)     
> storyView.backgroundColor = .clear
> storyView.delegate = self
> storyView.dataSource = self

- Implement the delegate & datasource protocols for configurations and display modifications 

-- swift
> public protocol FAStoryDelegate: class {
> /// cell horizontal spacing
> var cellHorizontalSpacing: CGFloat {get}
>
> /// cell height
> var cellHeight: CGFloat {get}
> 
> /// cell aspect ratio
> var cellAspectRatio: CGFloat {get}
> 
> /// display name font
> var displayNameFont: UIFont {get}
> 
> /// display name color
> var displayNameColor: UIColor {get}
> 
> /// vertical cell padding
> func verticalCellPadding() -> CGFloat
> 
> /// did select
> func didSelect(row: Int) -> Void 
> 
> }





