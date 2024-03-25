# APButton

[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Version](https://img.shields.io/cocoapods/v/APButton.svg?style=flat)](http://cocoapods.org/pods/APButton)
[![License](https://img.shields.io/cocoapods/l/APButton.svg?style=flat)](http://cocoapods.org/pods/APButton)
[![Platform](https://img.shields.io/cocoapods/p/APButton.svg?style=flat)](http://cocoapods.org/pods/APButton)
[![CI Status](http://img.shields.io/travis/APUtils/APButton.svg?style=flat)](https://travis-ci.org/APUtils/APButton)

Button with ability to show loading indicator and animate depended views according to button state. Try to mimic system button animations while provides ability to make button from several views: background view, image view, overlay view, etc.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## GIF animations

#### Activity indication:

<img src="Example/APButton/activity.gif"/>

#### Tap:

<img src="Example/APButton/clicks.gif"/>

## Installation

#### CocoaPods

APButton is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'APButton', '~> 6.0'
```

## Usage

#### Setup

Set custom class for your button in storyboard, **assure module field is also `APButton`**:

<img src="Example/APButton/customClass.png"/>

Add as many dependend views as you like:

<img src="Example/APButton/dependent.png"/>

Button outlet example:

```swift
@IBOutlet private weak var button: APButton!
```

Button action example:

```swift
@IBAction private func onButonTap(_ sender: APButton) {}
```

#### Configuration

<img src="Example/APButton/options.png"/>

You can set overlay color so instead of dim dependend views button will put overlay over self.

Setting `rounded` to `On` will make button corners rounded.

#### Activity

To start activity call `button.startAnimating()`, to finish call `button.stopAnimating()`.

#### State changes

Button animations for taps are automatic.

If you want your dependend labels to change color for disabled state, their color should match APButton title color for state `normal` and their disabled state color will be APButton title color for state `disabled` then.

<img src="Example/APButton/default.png"/>

<img src="Example/APButton/disabled.png"/>

There are many ways and a lot of flexibility of how you can compose your button. See example project for more details.

## Contributions

Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.

## Author

Anton Plebanovich, anton.plebanovich@gmail.com

## License

APButton is available under the MIT license. See the LICENSE file for more info.
