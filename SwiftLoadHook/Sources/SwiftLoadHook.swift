//
//  SwiftLoadHook.swift
//  SwiftLoadHook
//
//  Created by iCeBlink on 2018/7/15.
//  Copyright © 2018年 zakariyyasv. All rights reserved.
//

import Foundation
import UIKit

protocol SelfAware: class {
  static func awake()
}

struct CustomHook {

  static func harmlessFunction() {

    // Get all class list through runtime
    let typeCount = Int(objc_getClassList(nil, 0))
    let types = UnsafeMutablePointer<AnyClass>.allocate(capacity: typeCount)
    let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
    objc_getClassList(autoreleasingTypes, Int32(typeCount))

    for index in 0 ..< typeCount {
      (types[index] as? SelfAware.Type)?.awake()
    }

    types.deallocate()
  }
}


extension UIApplication {

  private static let runOnce: Void = {
    CustomHook.harmlessFunction()
  }()

  override open var next: UIResponder? {
    // Called before applicationDidFinishLaunching
    UIApplication.runOnce
    return super.next
  }

}
