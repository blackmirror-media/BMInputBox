//
//  BMInputBox.swift
//  BMInputBox
//
//  Created by Adam Eri on 10/02/2015.
//  Copyright (c) 2015 blackmirror media. All rights reserved.
//

import UIKit

class BMInputBox: UIView {

    enum BMInputBoxStyle {
        case PlainTextInput         // Simple text field
        case NumberInput            // Text field accepting numbers only - numeric keyboard
        case PhoneNumberInput       // Text field accepting numbers only - phone keyboard
        case EmailInput             // Text field accepting email addresses -  email keyboard
        case SecureTextInput        // Secure text field for passwords
        case LoginAndPasswordInput  // Two text fields for user and password entry
        case DatePickerInput        // Date picker
        case PickerInput            // Value picker
    }


    // MARK: Initializers

    /// Title of the box
    var title: NSString?

    /// Message in the box
    var message: NSString?

    /// Text on submit button
    var submitButtonText: NSString?

    /// Text on cancel button
    var cancelButtonText: NSString?

    /// The current style of the box
    var style: BMInputBoxStyle = .PlainTextInput

    /// Array holding all elements in the view.
    var elements = NSMutableArray()


    /**
    Class method creating an instace of the input box with a specific style. See BMInputBoxStyle for available styles. Every style comes with different kind and number of input types.

    :param: style Style of the input box

    :returns: instance of the input box.
    */
    class func boxWithStyle (style: BMInputBoxStyle) -> BMInputBox {
        let window = UIApplication.sharedApplication().windows.first as UIWindow
        var inputBox = BMInputBox(frame: window.frame)
        inputBox.style = style
        return inputBox
    }


    // MARK: Showing and hiding the box

    /**
    Shows the input box
    */
    func show () {

        self.setupView()

        // TODO: add animation
        let window = UIApplication.sharedApplication().windows.first as UIWindow
        window.addSubview(self)
        window.bringSubviewToFront(self)
    }

    /**
    Hides the input box
    */
    func hide () {
        // TODO: add animation
        self.removeFromSuperview()
    }


    // MARK: Handling user input and actions

    /// Text input used in styles: PlainTextInput, NumberInput, PhoneNumberInput, EmailInput and as a first input in LoginAndPasswordInput.
    var textInput: UITextField?

    /// Text input used in SecureTextInput and as a second input in LoginAndPasswordInput.
    var secureInput: UITextField?

    /// Elemenet used in datePicker style.
    var datePicker: UIDatePicker?

    /// Elemenet used in picker style.
    var picker: UIPickerView?

    /// Closure to allow customisation of the input element
    var customiseInputElement: ((element: UITextField) -> UITextField)!

    /// Closure executed when user submits the values.
    var onSubmit: ((inputs: NSArray) -> Void)!


    /// Closure executed when user cancels submission
    var onCancel: (() -> Void)!


    // MARK: Priate methods for creating the box based on style

    /**
    Method called when creating the box. Sets up the user elements based on the style and the possible custom elements.
    */
    private func setupView () {

        let padding: CGFloat = 15.0
        let width = self.frame.size.width - padding * 2

        var titleLabel = UILabel(frame: CGRectMake(padding, padding, width, 20))
        titleLabel.font = UIFont.systemFontOfSize(18)
        titleLabel.text = self.title?
        titleLabel.textAlignment = .Center
        self.addSubview(titleLabel)


        var messageLabel = UILabel(frame: CGRectMake(padding, padding + titleLabel.frame.size.height + 10,width, 20))
        messageLabel.numberOfLines = 4;
        messageLabel.font = UIFont.systemFontOfSize(14)
        messageLabel.text = self.message?
        messageLabel.sizeToFit()
        self.addSubview(messageLabel)

        switch self.style {
        case .PlainTextInput:
            self.textInput = UITextField(frame: CGRectMake(padding, messageLabel.frame.origin.y + messageLabel.frame.size.height + padding, width, 20))
            self.textInput?.textAlignment = .Center

            // Allow customisation
            if self.customiseInputElement != nil {
                self.textInput = self.customiseInputElement(element: self.textInput!)
            }

            self.elements.addObject(self.textInput!)


//        case .NumberInput:
//
//        case .PhoneNumberInput:
//
//        case .EmailInput:
//
//        case .SecureTextInput:
//
//        case .LoginAndPasswordInput:
//
//        case .DatePickerInput:
//
//        case .PickerInput:
        default:
            NSLog("")
        }

        for element in self.elements {
            self.addSubview(element as UITextField)
        }


        /**
        *  Setting up buttons
        */

        let buttonHeight: CGFloat = 45.0
        let buttonWidth = self.frame.size.width / 2

        var cancelButton = UIButton(frame: CGRectMake(0, self.frame.size.height - buttonHeight, buttonWidth, buttonHeight))
        cancelButton.setTitle(self.cancelButtonText? ?? "Cancel", forState: .Normal)
        cancelButton.addTarget(self, action: "cancelButtonTapped", forControlEvents: .TouchUpInside)
        cancelButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        cancelButton.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        self.addSubview(cancelButton)

        var submitButton = UIButton(frame: CGRectMake(buttonWidth, self.frame.size.height - buttonHeight, buttonWidth, buttonHeight))
        submitButton.setTitle(self.submitButtonText? ?? "OK", forState: .Normal)
        submitButton.addTarget(self, action: "submitButtonTapped", forControlEvents: .TouchUpInside)
        submitButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        submitButton.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        self.addSubview(submitButton)
    }

    internal func cancelButtonTapped () {
        if self.onCancel != nil {
            self.onCancel()
        }
    }

    internal func submitButtonTapped () {
        if self.onSubmit != nil {
            self.onSubmit(inputs: self.elements)
        }
    }
}
