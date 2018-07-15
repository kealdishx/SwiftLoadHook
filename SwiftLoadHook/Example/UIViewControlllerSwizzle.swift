//
//  UIViewControlllerSwizzle.swift
//  SwiftLoadHook
//
//  Created by iCeBlink on 2018/7/15.
//  Copyright © 2018年 zakariyyasv. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController: SelfAware {

  static func awake() {
    UIViewController.classInit()
  }

  static func classInit() {
    swizzleMethod
  }

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
}
