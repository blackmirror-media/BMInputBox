# BMInputBox

BMInputBox is an iOS drop-in class that displays input boxes for the user to input different kinds of data, for instance username and password, email address, numbers, plain text. BMInputBox is meant as a replacement for the limited UIAlertView input options.

![alt tag](http://blackmirror.media/github/BMInputBoxPlainText.png)
![alt tag](http://blackmirror.media/github/BMInputBoxLogin.png)
![alt tag](http://blackmirror.media/github/BMInputBoxLoginFilled.png)

## Requirements

Build in Swift for iOS 8.1+.

## Adding BMInputBox To Your Project

### Cocoapods

CocoaPods is the recommended way to add BMInputBox to your project. As soon as they solve the problems with Swift pods...

**Until that time, simply add the `BMInputBox.swift` file to your project.**

## Usage

#### Creating an input box

```Swift
var inputBox = BMInputBox.boxWithStyle(.NumberInput)
inputBox.show()
```

Available styles:
* `.PlainTextInput` - Simple text field
* `.NumberInput` - Text field accepting numbers only - numeric keyboard
* `.PhoneNumberInput` - Text field accepting numbers only - phone keyboard
* `.EmailInput` - Text field accepting email addresses -  email keyboard
* `.SecureTextInput` - Secure text field for passwords
* `.LoginAndPasswordInput` - Two text fields for user and password entry

#### Customising the box

Changing the blur effect (ExtraLight, Light, Dark)

```Swift
inputBox.blurEffectStyle = .Light
```

Title and message

```Swift
inputBox.title = "This is the title"
inputBox.message = "This is a longer messages that can be wrapped into multiple lines but maximum three."
```

Mandatory decimals for the .NumberInput type

```Swift
inputBox.numberOfDecimals = 2
```

Doing whatever you need with the textField in the box

```Swift
inputBox.customiseInputElement = {(element: UITextField) in
  element.placeholder = "Custom placeholder"
  if element.secureTextEntry == true {
    element.placeholder = "Secure placeholder"
  }
  return element
}
```

### Closures for submission and cancellation

```Swift
inputBox.onSubmit = {(value: AnyObject...) in
  for text in value {
    if text is String {
      NSLog("%@", text as String)
    }
    else if text is NSDate {
      NSLog("%@", text as NSDate)
    }
    else if text is Int {
      NSLog("%i", text as Int)
    }
  }
}
```
```Swift
inputBox.onCancel = {
  NSLog("Cancelled")
}
```
