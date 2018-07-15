//
//  ViewController.swift
//  SwiftLoadHook
//
//  Created by iCeBlink on 2018/7/15.
//  Copyright © 2018年 zakariyyasv. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("viewWillAppear")
  }

}

