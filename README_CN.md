# SwiftLoadHook

# 目的

此库以 hack 的方式来实现类似 `Load()` 或 `Initialize()` 方法的功能。

# 由来

当你将一个项目迁移到 swift 3.1 版本后， Xcode 会报如下的警告：

> Objective-C 中的类方法 `Initialize` 也就是 swift 中的 `Initialize()` 方法，不保证在 swift 下一定会触发，并且在未来的版本中不被允许。

# 要求

- iOS 8.0+
- swift 3.0+

# 用法

首先，将 `Sources` 目录下的所有文件添加到你的项目中。

然后，你的目标类必须要遵守 `SelfAware` 协议，并且实现 `SelfAware` 协议中的方法。

最后，在 `SelfAware` 协议中的 `awake()` 中实现你想要的功能逻辑。

# 例子

这个例子是用来帮助你去理解如何使用它，你在 `Example` 目录下可以找到这部分代码。在这个例子中，我想实现的逻辑是交换 `UIViewController` 中 `viewWillAppear` 方法的实现。

首先，`UIViewController` 需要遵守 `SelfAware` 协议并且实现该协议的相关方法。


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

然后，我需要去实现 `swizzleMethod` 方法。在执行方法交换的时候，我们应当使用 `dispatch_once` 。然而，从 swift 3.x 起，我们在 API 中已无法找到 `dispatch_once` 相关 API。那我们如何去解决呢？我们知道，swift 中的静态不可变变量底层实现上实际上就是和 `dispatch_once` 类似，所以，我们可以用静态不可变变量去实现。

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

# 感谢

@JORDAN SMITH

# 引用

[Handling the Deprecation of initialize()](http://jordansmith.io/handling-the-deprecation-of-initialize/)

# 协议

SwiftLoadHook 遵守 MIT 协议。查看 LICENSE 获取更多细节。
