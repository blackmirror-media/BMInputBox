# BMInputBox

[BMInputBox](http://blackmirror-media.github.io/BMInputBox/) is an iOS drop-in class wrote in Swift that displays input boxes for the user to input different kinds of data, for instance username and password, email address, numbers, plain text. BMInputBox is meant as a replacement for the limited UIAlertView input options.

![alt tag](http://blackmirror.media/github/BMInputBoxPlainText.png)
![alt tag](http://blackmirror.media/github/BMInputBoxLogin.png)
![alt tag](http://blackmirror.media/github/BMInputBoxLoginFilled.png)

## Requirements

Built in Swift 1.2 for iOS 8.0+. All devices supported. BMInputBox can be used in both Swift and in ObjectiveC projects.

## Adding BMInputBox To Your Project

### Cocoapods

CocoaPods is the recommended way to add BMInputBox to your project. As BMInputBox is written in Swift, you need to add the `use_frameworks!` option to your podfile.

```
pod 'BMInputBox'
```

## Usage

Import the module to your project.

```Swift
@import BMInputBox
```

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

Changing the blur effect (UIBlurEffectStyle: .ExtraLight, .Light, .Dark).

```Swift
inputBox.blurEffectStyle = .Light
```

Title and message.

```Swift
inputBox.title = "This is the title"
inputBox.message = "This is a longer messages that can be wrapped into multiple lines but maximum three."
```

Mandatory decimals for the .NumberInput type. Default is 0. If set, the user input will be convertd to Double with 2 decimals. For instance "1" becomes "0.01" and "1234" becomes "12.34".

```Swift
inputBox.numberOfDecimals = 2
```

Setting minimum and maximum values for the .NumberInput type. Shows a message to the user below the textField. The entered value is validated against these values.

Setting a minimum value:

```Swift
inputBox.minimumValue = 10
inputBox.validationLabelText = "A number greater %@."
```

Setting minimum and maximum values:

```Swift
inputBox.minimumValue = 10
inputBox.maximumValue = 30
inputBox.validationLabelText = "A number between %@ and %@."
```

Doing whatever you need with the textField in the box.

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

## Credits

Adam Eri<br/>
[blackmirror media](http://blackmirror.media)

