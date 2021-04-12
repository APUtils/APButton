# Change Log
All notable changes to this project will be documented in this file.
`APButton` adheres to [Semantic Versioning](http://semver.org/).


## [6.0.1](https://github.com/APUtils/APButton/releases/tag/6.0.1)
Released on 04/12/2021.

#### Added
- SPM support

#### Fixed
- tvOS build


## [6.0.0](https://github.com/APUtils/APButton/releases/tag/6.0.0)
Released on 04/12/2021.

#### Fixed
- Warnings

#### Changed
- Activity indicator defaults to `.medium` style on iOS > 13.0 and can be configured through `activityIndicator` public property.
- Min iOS version `9.0`


## [5.0.1](https://github.com/APUtils/APButton/releases/tag/5.0.1)
Released on 12/30/2018.

#### Fixed
- System button title set


## [5.0.0](https://github.com/APUtils/APButton/releases/tag/5.0.0)
Released on 12/30/2018.

#### Added
- Swift 4.2 support
- .progress and .progressColor properties to show loading progress
- Init with action closure
- Make isAnimating public
- Carefull start and stop animating
- Configure depended views isHidden together with main button
- .increaseLoadingCounter() and .decreaseLoadingCounter(nullify:)

#### Fixed
- iOS 11 title not animating on click fix
- Title alpha fix
- Complex animations fix
- Alpha comparison check fix
- Prevent crash on progress change from background


## [4.0.3](https://github.com/APUtils/APButton/releases/tag/4.0.3)
Released on 10/04/2017.

#### Fixed
- Start and stop should be executed only in main thread fix


## [4.0.2](https://github.com/APUtils/APButton/releases/tag/4.0.2)
Released on 09/28/2017.

#### Fixed
- Immediate -stopAnimating() fix


## [4.0.1](https://github.com/APUtils/APButton/releases/tag/4.0.1)
Released on 09/21/2017.

#### Fixed
- .swift_verion 4.0


## [4.0.0](https://github.com/APUtils/APButton/releases/tag/4.0.0)
Released on 09/21/2017.

Swift 4 migration


## [3.1.2](https://github.com/APUtils/APButton/releases/tag/3.1.2)
Released on 08/07/2017.

#### Fixed
- System button activity animation fix


## [3.1.1](https://github.com/APUtils/APButton/releases/tag/3.1.1)
Released on 08/07/2017.

#### Added
- Carthage support

#### Fixed
- Test project fix


## [3.1.0](https://github.com/APUtils/APButton/releases/tag/3.1.0)
Released on 08/07/2017.

#### Added
- Highlighted for border
- Disabled for border

#### Fixed
- Possible leak fix


## [3.0.1](https://github.com/APUtils/APButton/releases/tag/3.0.1)
Released on 08/03/2017.

#### Fixed
- Activity animation fix


## [3.0.0](https://github.com/APUtils/APButton/releases/tag/3.0.0)
Released on 08/02/2017.

#### Added
- Disabled and enabled states for dependent views
- Higher precision animation with system button


## [2.0.0](https://github.com/APUtils/APButton/releases/tag/2.0.0)
Released on 08/01/2017.

#### Changed
- Overlay color option instead of bool.

#### Improved
- Button highlight alpha.

#### Fixed
- Button blink on initial load.


## [1.0.0](https://github.com/APUtils/APButton/releases/tag/1.0.0)
Released on 07/11/2017.

#### Added
- Initial release of APButton.
  - Added by [Anton Plebanovich](https://github.com/anton-plebanovich).
