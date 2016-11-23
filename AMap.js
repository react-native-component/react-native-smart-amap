/*
 * A smart AMap Library for react-native apps
 * https://github.com/react-native-component/react-native-smart-amap/
 * Released under the MIT license
 * Copyright (c) 2016 react-native-component <moonsunfall@aliyun.com>
 */

import {
    Platform,
} from 'react-native'

import AndroidAMap from './AMap-android'
import IOSAMap from './AMap-ios'

let AMap

if(Platform.OS == 'ios') {
    AMap = IOSAMap
}
else {
    AMap = AndroidAMap
}

export default AMap
