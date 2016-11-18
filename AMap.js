/*
 * A smart AMap Library for react-native apps
 * https://github.com/react-native-component/react-native-smart-amap/
 * Released under the MIT license
 * Copyright (c) 2016 react-native-component <moonsunfall@aliyun.com>
 */

import React, {
    PropTypes,
    Component,
} from 'react'
import {
    View,
    requireNativeComponent,
    Platform,
    NativeModules,
    findNodeHandle,
} from 'react-native'

const AMapManager = Platform.OS == 'ios' ? NativeModules.AMap : NativeModules.AMapModule

export default class AMap extends Component {

    static constants = {
        userTrackingMode: AMapManager.userTrackingMode,
    }

    static defaultProps = {
        //mapType: 0,
        //showTraffic: false,
        //showsUserLocation: true,
    }

    static propTypes = {
        ...View.propTypes,
        options: PropTypes.shape({
            frame: PropTypes.shape({
                width: PropTypes.number.isRequired,
                height: PropTypes.number.isRequired,
            }),
            mapType: PropTypes.number,
            showTraffic: PropTypes.bool,
            showsUserLocation: PropTypes.bool,
            userTrackingMode: PropTypes.number,
            centerCoordinate: PropTypes.shape({
                latitude: PropTypes.number.isRequired,
                longitude: PropTypes.number.isRequired,
            }),
            zoomLevel: PropTypes.number,
        }).isRequired,
        onDidMoveByUser: PropTypes.func,
    }

    constructor(props) {
        super(props)
        this.state = {}
    }

    render() {
        return (
            <NativeAMap
                {...this.props}
            />
        )
    }

    setOptions(options) {
        AMapManager.setOptions(findNodeHandle(this), options)
    }

    searchPoiByCenterCoordinate(params) {
        AMapManager.searchPoiByCenterCoordinate(params) //传null为默认参数配置
    }

    setCenterCoordinate(coordinate) {
        //console.log('findNodeHandle => ')
        //console.log(findNodeHandle)
        AMapManager.setCenterCoordinate(findNodeHandle(this), coordinate)
    }
}

const NativeAMap = requireNativeComponent('RCTAMap', AMap)
