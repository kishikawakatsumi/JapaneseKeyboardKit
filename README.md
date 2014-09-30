JapaneseKeyboardKit
===================

Sample implementation for iOS Custom Keyboard Extension with Mozc (Google Japanese Input)

See also https://github.com/kishikawakatsumi/Mozc-for-iOS

<img src="https://raw.githubusercontent.com/kishikawakatsumi/JapaneseKeyboardKit/master/ScreenShots/ss_01.png" width="225px" style="width: 225px;" />&nbsp;
<img src="https://raw.githubusercontent.com/kishikawakatsumi/JapaneseKeyboardKit/master/ScreenShots/ss_02.png" width="400px" style="width: 400px;" />

### Usage

#### Getting the code

```
$ git clone git@github.com:kishikawakatsumi/JapaneseKeyboardKit.git --recursive
$ cd JapaneseKeyboardKit
```

#### Build Mozc (Japanese Input Method)

##### Configure

```
$ cd Mozc-for-iOS/src
$ python build_mozc.py gyp
```

##### Compilation

```
$ python build_mozc_ios.py
```

#### Run Sample Project

```
$ cd ../..
$ open JapaneseKeyboardKit.xcodeproj
```

### Limitation

Mozc works on a device only, does not work on the simulator.
