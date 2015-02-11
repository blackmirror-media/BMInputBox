//
//  ViewController.swift
//  BMInputBox
//
//  Created by Adam Eri on 10/02/2015.
//  Copyright (c) 2015 blackmirror media. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let inputBox = BMInputBox.boxWithStyle(.PlainTextInput)
        inputBox.blurEffectStyle = .ExtraLight

        inputBox.title = "This is the title"
        inputBox.message = "This is a longer messages that can be wrapped into multiple lines but maximum three."

        inputBox.customiseInputElement = {(element: UITextField) in
            element.placeholder = "This is my custom placeholder"
            return element
        }

        inputBox.onSubmit = {(elements: NSArray) in
            NSLog("%@", elements)
        }

        inputBox.show()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

