# SwiftObfuscator
Tool that obfuscates Swift projects

This library is capable of parsing files in file system, recognising all classes, structs and enums and replacing them all over the project with obfuscated name. It does not modify public types.

SwiftObfuscator can remove all comments from source files. Both single line and multi lines.

It can also obfuscate private and fileprivate variable names.

SwiftObfuscator is capable of finding and replacing private methods.

When you perform all the steps you want, just call `overrideFiles()` so all the modifications will be saved in the original file names.

## Sample usage:
```swift
let project = Project(absolutePath: "/Users/jenkins/workspace/SampleApp")
project.excludeFolder("/SampleAppTests/")
project.excludeFile(filename: "Utilities.swift")
project.removeComments()
project.obfuscatePrivateMethods()
project.obfuscatePrivateAttributes()
project.obfuscateObjectTypeNames(untouchableTypeNames: [
    "ResponseDto"
])
project.overrideFiles()
```

## JSON report
You can get json report from obfuscation process by reading `report` property on your Project instance. It returns pretty-printed JSON String.
```
let project = Project(absolutePath: "/Users/jenkins/workspace/SampleApp")
... (here obfuscation steps)
project.overrideFiles()
let jsonReport = project.report
```
