# SwiftLoadHook [中文介绍](https://github.com/ZakariyyaSv/SwiftLoadHook/blob/master/README_CN.md)

# Purpose

This lib uses a hack way to achieve similar functions as `Load()` or `initialize()`. 

# Reason

Upon migrating a project to Swift 3.1, Xcode raises a warning:

> Method ‘initialize()’ defines Objective-C class method ‘initialize’, which is not guaranteed to be invoked by Swift and will be disallowed in future versions.

# Requirements

- iOS 8.0+
- swift 3.0+

# Usage

First, drop files under `Sources` folder to your project.

Then, your target class should conforms to `SelfAware` protocol, and implements the functions in `SelfAware` protocol.

Finally, write the code you want in `awake` function just like that in `Load()` or `Initialize()`.

# Example

This example is used to help you understand how to use, you can find the code in the files under `Example` folder. In this example, I want to swizzle the IMP of function `viewWillAppear()` in `UIViewController`.

First, `UIViewController` should conform to `SelfAware` protocol and implement functions of the protocol.

```swift
extension UIViewController: SelfAware {

  static func awake() {
    UIViewController.classInit()
  }

  static func classInit() {
    swizzleMethod
  }
}
```

Then, I should implement `swizzleMethod` function. while swizzling methods, we should use `dispatch_once` in `Load()` or `Initialize()` function. However, since swift 3.x, we cannot find `dispatch_once` in API. How can we handle this? We can use `static let instance` to handle with it.

```swift
@objc func swizzled_viewWillAppear(_ animated: Bool) {
    swizzled_viewWillAppear(animated)
    print("swizzled_viewWillAppear")
  }

  private static let swizzleMethod: Void = {
    let originalSelector = #selector(viewWillAppear(_:))
    let swizzledSelector = #selector(swizzled_viewWillAppear(_:))
    swizzlingForClass(UIViewController.self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
  }()

  private static func swizzlingForClass(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {

    let originalMethod = class_getInstanceMethod(forClass, originalSelector)
    let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)

    guard (originalMethod != nil && swizzledMethod != nil) else {
      return
    }

    if class_addMethod(forClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!)) {
      class_replaceMethod(forClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
    } else {
      method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
  }
```




# Thanks

@JORDAN SMITH

# Reference

[Handling the Deprecation of initialize()](http://jordansmith.io/handling-the-deprecation-of-initialize/)

# License

SwiftLoadHook is released under the MIT license. See LICENSE for details.
