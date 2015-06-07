//
//  BMInputBox.swift
//  BMInputBox
//
//  Created by Adam Eri on 10/02/2015.
//  Copyright (c) 2015 blackmirror media. All rights reserved.
//

import UIKit

@objc public enum BMInputBoxStyle: Int {
    case PlainTextInput         // Simple text field
    case NumberInput            // Text field accepting numbers only - numeric keyboard
    case PhoneNumberInput       // Text field accepting numbers only - phone keyboard
    case EmailInput             // Text field accepting email addresses -  email keyboard
    case SecureTextInput        // Secure text field for passwords
    case LoginAndPasswordInput  // Two text fields for user and password entry
    //        case DatePickerInput        // Date picker
    //        case PickerInput            // Value picker
}

public class BMInputBox: UIView {

    // MARK: Initializers

    /// Title of the box
    public var title: NSString?

    /// Message in the box
    public var message: NSString?

    /// Text on submit button
    public var submitButtonText: NSString?

    /// Text on cancel button
    public var cancelButtonText: NSString?

    /// The current style of the box
    @objc public var style: BMInputBoxStyle = .PlainTextInput


    /// Customisation of the NumberInput type

    /// The amount of mandatory decimals in case of NumberInput
    public var numberOfDecimals: Int = 0
    /// If set, the value entered into a NumberInput will be validated against it as a minimum value.
    public var minimumValue: NSNumber!
    /// If set, the value entered into a NumberInput will be validated against it as a maximum value.
    public var maximumValue: NSNumber!

    /**
    String used to notify the user about the value critera (minimum and maximum values).

    @discussion
    There are three cases that could occur:
    - Only minimum validation
    - Only maximum validation
    - Validation in a range (minimum to maximum)

    The property should have the string approproate for your use case. It should also have NSNumber placeholder(s) (%@) within. If not set, the default strings will be used.
    */
    public var validationLabelText: NSString?

    /// UILabel for displaying the validation message
    private var validationLabel: UILabel!


    /// Array holding all elements in the view.
    var elements = NSMutableArray()

    /// Visual effect style
    public var blurEffectStyle: UIBlurEffectStyle?

    /// Visual effects view holding the content
    private var visualEffectView: UIVisualEffectView?


    /**
    Class method creating an instace of the input box with a specific style. See BMInputBoxStyle for available styles. Every style comes with different kind and number of input types.

    :param: style Style of the input box

    :returns: instance of the input box.
    */
    @objc public class func boxWithStyle (style: BMInputBoxStyle) -> BMInputBox {
        let window = UIApplication.sharedApplication().windows.first as! UIWindow

        let boxFrame = CGRectMake(0, 0, min(325, window.frame.size.width - 50), 210)

        var inputBox = BMInputBox(frame: boxFrame)
        inputBox.center = CGPointMake(window.center.x, window.center.y - 30)
        inputBox.style = style
        return inputBox

    }


    // MARK: Showing and hiding the box

    /**
    Shows the input box
    */
    public func show () {

        self.alpha = 0
        self.setupView()

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 1
        })

        let window = UIApplication.sharedApplication().windows.first as! UIWindow
        window.addSubview(self)
        window.bringSubviewToFront(self)

        // Rotation support
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationDidChange", name: UIDeviceOrientationDidChangeNotification, object: nil)

        // Keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
    }

    /**
    Hides the input box
    */
    public func hide () {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 0
            }) { (completed) -> Void in
                self.removeFromSuperview()

                // Rotation support
                UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
                NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)

                // Keyboard
                NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
                NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
        }
    }

    /**
    Method called when creating the box. Sets up the user elements based on the style and the possible custom elements.
    */
    private func setupView () {

        /// Corners
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = true

        /// Blur stuff
        self.visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: self.blurEffectStyle ?? UIBlurEffectStyle.ExtraLight))

        /// Constants
        let padding: CGFloat = 20.0
        let width = self.frame.size.width - padding * 2

        /// Labels
        var titleLabel = UILabel(frame: CGRectMake(padding, padding, width, 20))
        titleLabel.font = UIFont.boldSystemFontOfSize(18)
        titleLabel.text = self.title as? String
        titleLabel.textAlignment = .Center
        titleLabel.textColor = (self.blurEffectStyle == .Dark) ? UIColor.whiteColor() : UIColor.blackColor()
        self.visualEffectView?.contentView.addSubview(titleLabel)

        var messageLabel = UILabel(frame: CGRectMake(padding, padding + titleLabel.frame.size.height + 10, width, 20))
        messageLabel.numberOfLines = 3;
        messageLabel.font = UIFont.systemFontOfSize(14)
        messageLabel.text = self.message as? String
        messageLabel.textAlignment = .Center
        messageLabel.textColor = (self.blurEffectStyle == .Dark) ? UIColor.whiteColor() : UIColor.blackColor()
        messageLabel.sizeToFit()
        self.visualEffectView?.contentView.addSubview(messageLabel)


        /**
        *  Inputs
        */
        switch self.style {
        case .PlainTextInput, .NumberInput, .EmailInput, .SecureTextInput, .PhoneNumberInput:
            self.textInput = UITextField(frame: CGRectMake(padding, messageLabel.frame.origin.y + messageLabel.frame.size.height + padding / 1.5, width, 35))
            self.textInput?.textAlignment = .Center

            // Allow customisation
            if self.customiseInputElement != nil {
                self.textInput = self.customiseInputElement(element: self.textInput!)
            }

            self.elements.addObject(self.textInput!)

        case .LoginAndPasswordInput:

            // TextField

            self.textInput = UITextField(frame: CGRectMake(padding, messageLabel.frame.origin.y + messageLabel.frame.size.height + padding / 1.5, width, 35))
            self.textInput?.textAlignment = .Center

            // Allow customisation
            if self.customiseInputElement != nil {
                self.textInput = self.customiseInputElement(element: self.textInput!)
            }

            self.elements.addObject(self.textInput!)

            // PasswordField
            self.secureInput = UITextField(frame: CGRectMake(padding, self.textInput!.frame.origin.y + self.textInput!.frame.size.height + padding / 2, width, 35))
            self.secureInput?.textAlignment = .Center
            self.secureInput?.secureTextEntry = true

            // Allow customisation
            if self.customiseInputElement != nil {
                self.secureInput = self.customiseInputElement(element: self.secureInput!)
            }

            self.elements.addObject(self.secureInput!)

            var extendedFrame = self.frame
            extendedFrame.size.height += 45
            self.frame = extendedFrame

            //  TODO: Finish
            //        case .DatePickerInput:
            //
            //        case .PickerInput:

        default:
            NSLog("nothing here")
        }

        if self.style == .NumberInput {
            self.textInput?.keyboardType = .NumberPad
            self.textInput?.addTarget(self, action: "textInputDidChange", forControlEvents: .EditingChanged)

            /**
            *  Validation Label
            */

            self.validationLabel = UILabel(frame: CGRectMake(padding, self.textInput!.frame.origin.y + self.textInput!.frame.size.height + 5, width, 20))
            self.validationLabel.numberOfLines = 1;
            self.validationLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)

            let messageString: NSString? = self.validationLabelText

            if (self.minimumValue != nil && self.maximumValue == nil) {
                self.validationLabel.text = NSString(format: messageString ?? "A value greater than %@.", self.minimumValue!) as String
            }
            else if (self.minimumValue == nil && self.maximumValue != nil) {
                self.validationLabel.text = NSString(format: messageString ?? "A value lower than %@.", self.maximumValue!) as String
            }
            else if (self.minimumValue != nil && self.maximumValue != nil) {
                self.validationLabel.text = NSString(format: messageString ?? "A value between %@ and %@.", self.minimumValue!, self.maximumValue!) as String
            }

            self.validationLabel.textAlignment = .Center
            self.validationLabel.textColor = (self.blurEffectStyle == .Dark) ? UIColor.whiteColor() : UIColor(red: 220/255, green: 53/255, blue: 34/255, alpha: 1)
            self.visualEffectView?.contentView.addSubview(self.validationLabel)

            // Extending the frame of the box
            var extendedFrame = self.frame
            extendedFrame.size.height += 15
            self.frame = extendedFrame

        }

        if self.style == .PhoneNumberInput {
            self.textInput?.keyboardType = .PhonePad
        }

        if self.style == .EmailInput {
            self.textInput?.keyboardType = .EmailAddress
        }

        if self.style == .SecureTextInput {
            self.textInput?.secureTextEntry = true
        }

        for element in self.elements {
            let element: UITextField = element as! UITextField
            element.layer.borderColor = UIColor(white: 0, alpha: 0.1).CGColor
            element.layer.borderWidth = 0.5
            element.backgroundColor = (self.blurEffectStyle == .Dark) ? UIColor(white: 1, alpha: 0.07) : UIColor(white: 1, alpha: 0.5)
            self.visualEffectView?.contentView.addSubview(element)
        }



        /**
        *  Setting up buttons
        */

        let buttonHeight: CGFloat = 45.0
        let buttonWidth = self.frame.size.width / 2

        var cancelButton = UIButton(frame: CGRectMake(0, self.frame.size.height - buttonHeight, buttonWidth, buttonHeight))
        let cancelButtonTxt = (self.cancelButtonText ?? "Cancel")
        cancelButton.setTitle(cancelButtonTxt as String, forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: "cancelButtonTapped", forControlEvents: .TouchUpInside)
        cancelButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        cancelButton.setTitleColor((self.blurEffectStyle == .Dark) ? UIColor.whiteColor() : UIColor.blackColor(), forState: .Normal)
        cancelButton.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        cancelButton.backgroundColor = (self.blurEffectStyle == .Dark) ? UIColor(white: 1, alpha: 0.07) : UIColor(white: 1, alpha: 0.2)
        cancelButton.layer.borderColor = UIColor(white: 0, alpha: 0.1).CGColor
        cancelButton.layer.borderWidth = 0.5
        self.visualEffectView?.contentView.addSubview(cancelButton)

        var submitButton = UIButton(frame: CGRectMake(buttonWidth, self.frame.size.height - buttonHeight, buttonWidth, buttonHeight))
        let submitButtonTxt = (self.submitButtonText ?? "OK")
        submitButton.setTitle(submitButtonTxt as String, forState: UIControlState.Normal)
        submitButton.addTarget(self, action: "submitButtonTapped", forControlEvents: .TouchUpInside)
        submitButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        submitButton.setTitleColor((self.blurEffectStyle == .Dark) ? UIColor.whiteColor() : UIColor.blackColor(), forState: .Normal)
        submitButton.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        submitButton.backgroundColor = (self.blurEffectStyle == .Dark) ? UIColor(white: 1, alpha: 0.07) : UIColor(white: 1, alpha: 0.2)
        submitButton.layer.borderColor = UIColor(white: 0, alpha: 0.1).CGColor
        submitButton.layer.borderWidth = 0.5
        self.visualEffectView?.contentView.addSubview(submitButton)


        /**
        Adding the visual effects view.
        */
        self.visualEffectView!.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        self.addSubview(self.visualEffectView!)
    }

    func deviceOrientationDidChange () {
        self.resetFrame(true)
    }

    // MARK: Handling user input and actions

    /// Text input used in styles: PlainTextInput, NumberInput, PhoneNumberInput, EmailInput and as a first input in LoginAndPasswordInput.
    private var textInput: UITextField?

    /// Text input used in SecureTextInput and as a second input in LoginAndPasswordInput.
    private var secureInput: UITextField?

    /// Elemenet used in datePicker style.
    private var datePicker: UIDatePicker?

    /// Elemenet used in picker style.
    var picker: UIPickerView?

    /// Closure to allow customisation of the input element
    public var customiseInputElement: ((element: UITextField) -> UITextField)!

    /// Closure executed when user submits the values.
    public var onSubmit: ((value: AnyObject...) -> Void)!

    /// Closure executed when user cancels submission
    public var onCancel: (() -> Void)!

    func cancelButtonTapped () {
        if self.onCancel != nil {
            self.onCancel()
        }
        self.hide()
    }

    func submitButtonTapped () {

        // Submitting the form if valid
        if self.validateInput() {
            if self.onSubmit != nil {
                let valueToReturn: String? = self.textInput!.text

                if let value2ToReturn = self.secureInput?.text {
                    self.onSubmit(value: valueToReturn!, value2ToReturn)
                }
                else {
                    self.onSubmit(value: valueToReturn!)
                }
            }
            self.hide()
        }

            // Shaking the validation label if not valid
        else {
            self.animateLabel()
        }

    }

    private func validateInput () -> Bool {

        if self.style == .NumberInput && (self.minimumValue != nil || self.maximumValue != nil) {

            if self.textInput?.text == "" {
                return false
            }

            let formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle;

            // BMInputBoxStyleNumberInput is using a dot for decimals independent of the locale
            formatter.decimalSeparator = "."
            let userValue = formatter.numberFromString(self.textInput!.text)!

            // Lower than minimum value
            if self.minimumValue != nil {
                if self.minimumValue.doubleValue > userValue.doubleValue {
                    return false
                }
            }

            // Greater maximum value
            if self.maximumValue != nil {
                if self.maximumValue.doubleValue < userValue.doubleValue {
                    return false
                }
            }

        }

        return true
    }

    private func animateLabel () {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.validationLabel.center.x - 8, self.validationLabel.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.validationLabel.center.x + 8, self.validationLabel.center.y))
        self.validationLabel.layer.addAnimation(animation, forKey: "position")
    }

    func textInputDidChange () {
        var text: NSString = self.textInput!.text as NSString
        text = text.stringByReplacingOccurrencesOfString(".", withString: "")

        let power = pow(10.0, Double(self.numberOfDecimals))
        let number: Double = text.doubleValue / Double(power)
        let formatter = "%." + (NSString(format: "%i", self.numberOfDecimals) as String) + "lf"

        let formattedString = NSString(format: formatter, number)
        self.textInput?.text = formattedString as String
    }

    public override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.endEditing(true)
    }

    // MARK: Keyboard Changes

    func keyboardDidShow (notification: NSNotification) {
        self.resetFrame(true)

        UIView.animateWithDuration(0.2, animations: { () -> Void in
            var frame = self.frame
            frame.origin.y -= self.yCorrection()
            self.frame = frame
        })
    }

    func keyboardDidHide (notification: NSNotification) {
        self.resetFrame(true)
    }

    private func yCorrection () -> CGFloat {

        var yCorrection: CGFloat = 30.0

        if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                yCorrection = 60.0
            }
            else if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                yCorrection = 100.0
            }

            if self.style == .LoginAndPasswordInput {
                yCorrection += 45.0
            }
            
        }
        else {
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                yCorrection = 0.0
            }
        }
        return yCorrection
    }
    
    private func resetFrame (animated: Bool) {
        var topMargin: CGFloat = (self.style == .LoginAndPasswordInput) ? 0.0 : 45.0
        let window = UIApplication.sharedApplication().windows.first as! UIWindow
        
        
        if animated {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.center = CGPointMake(window.center.x, window.center.y - topMargin)
            })
        }
        else {
            self.center = CGPointMake(window.center.x, window.center.y - topMargin)
        }
    }
}
