# react-native-smart-amap
A AMap Library for React Native apps.

[![npm](https://img.shields.io/npm/v/react-native-smart-amap.svg)](https://www.npmjs.com/package/react-native-smart-amap)
[![npm](https://img.shields.io/npm/dm/react-native-smart-amap.svg)](https://www.npmjs.com/package/react-native-smart-amap)
[![npm](https://img.shields.io/npm/dt/react-native-smart-amap.svg)](https://www.npmjs.com/package/react-native-smart-amap)
[![npm](https://img.shields.io/npm/l/react-native-smart-amap.svg)](https://github.com/react-native-component/react-native-smart-amap/blob/master/LICENSE)

react-native 高德地图SDK 插件, 支持ios与android,
关于使用高德地图SDK, 申请应用key等详细信息请点击[这里][1]

Mac下Android Studio中获取SHA1和MD5请点击[这里][3]

## 预览

![react-native-smart-amap-preview-ios][2]

## 安装

```
npm install react-native-smart-amap --save
```

## Notice

这个版本仅支持react-native 0.40及以上, 如果你想使用旧版本，使用`npm install react-native-smart-amap@untilRN0.40 --save`


## 安装 (iOS)

* 将RCTAMap.xcodeproj作为Library拖进你的Xcode里的project中.

* 将RCTAMap目录里Frameworks目录拖进主project目录下, 选择copy items if needed, create groups, 另外add to target不要忘记选择主project.

* 将RCTAMap目录里Frameworks目录里的AMap.bundle拖进主project目录下, 选择copy items if needed, create groups, 另外add to target不要忘记选择主project.

* 点击你的主project, 选择Build Phases -> Link Binary With Libraries, 将RCTAMap.xcodeproj里Product目录下的libRCTAMap.a拖进去.

* 同上位置, 选择Add items, 将系统库libstdc++.6.0.9.tbd加入.

* 同上位置, 选择Add items, 将系统库libc++.tbd加入.

* 同上位置, 选择Add items, 将系统库libz.tbd加入.

* 同上位置, 选择Add items, 将系统库Security.framework加入.

* 同上位置, 选择Add items, 将系统库CoreTelephony.framework加入.

* 同上位置, 选择Add items, 将系统库SystemConfiguration.framework加入.

* 同上位置, 选择Add items, 将系统库JavaScriptCore.framework加入.

* 同上位置, 选择Add items, 将系统库CoreLocation.framework加入.

* 选择Build Settings, 找到Header Search Paths, 确认其中包含$(SRCROOT)/../../../react-native/React, 模式为recursive.

* 同上位置, 找到Framework Search Paths, 加入$(PROJECT_DIR)/Frameworks.

* 点击在Libraries下已拖进来的RCTAMap.xcodeproj, 选择Build Settings, 找到Framework Search Paths, 将$(SRCROOT)/../../../ios/Frameworks替换成$(SRCROOT)/../../../../ios/Frameworks.

* 在`info.plist`中加入`Privacy - Location When In Use Usage Description`属性(ios 10)

* 在`info.plist`中加入`Allow Arbitrary Loads`属性, 并设置值为YES(ios 10)

* 在`AppDelegate.m`中

```

...
#import <AMapFoundationKit/AMapFoundationKit.h> //引入高德地图核心包
...
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

  [AMapServices sharedServices].apiKey = @"请填写您的key"; //设置高德地图SDK服务key
  ...
}
...

```

## 安装 (Android)

* 在`android/settings.gradle`中

```
...
include ':react-native-smart-amap'
project(':react-native-smart-amap').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-smart-amap/android')
```

* 在`android/app/build.gradle`中

```
...
dependencies {
    ...
    // From node_modules
    compile project(':react-native-smart-amap')
}
```

* 在`MainApplication.java`中

```
...
import com.reactnativecomponent.amaplocation.RCTAMapPackage;    //import package
...
/**
 * A list of packages used by the app. If the app uses additional views
 * or modules besides the default ones, add more packages here.
 */
@Override
protected List<ReactPackage> getPackages() {
    return Arrays.<ReactPackage>asList(
        new MainReactPackage(),
        new RCTAMapPackage()  //register Module
    );
}
...

```

* 在`AndroidManifest.xml`中, 加入所需权限

```

...
 <!--*************************高德地图-定位所需要权限*************************-->
    <!-- Normal Permissions 不需要运行时注册 -->
    <!--获取运营商信息，用于支持提供运营商信息相关的接口-->
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <!--用于访问wifi网络信息，wifi信息会用于进行网络定位-->
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <!--这个权限用于获取wifi的获取权限，wifi信息会用来进行网络定位-->
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
    <uses-permission android:name="android.permission.CHANGE_CONFIGURATION" />

    <!-- 请求网络 -->
    <uses-permission android:name="android.permission.INTERNET" />

    <!-- 不是SDK需要的权限，是示例中的后台唤醒定位需要的权限 -->
    <!--<uses-permission android:name="android.permission.WAKE_LOCK" />-->

    <!-- 需要运行时注册的权限 -->
    <!--用于进行网络定位-->
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <!--用于访问GPS定位-->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <!--用于提高GPS定位速度-->
    <uses-permission android:name="android.permission.ACCESS_LOCATION_EXTRA_COMMANDS" />
    <!--写入扩展存储，向扩展卡写入数据，用于写入缓存定位数据-->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <!--读取缓存数据-->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

    <!--用于读取手机当前的状态-->
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />

    <!-- 更改设置 -->
    <uses-permission android:name="android.permission.WRITE_SETTINGS" />
<!--*************************高德地图-定位所需要权限*************************-->
...

```

* 在`AndroidManifest.xml`中, application标签内加入

```

...
    <!--高德地图SDK key设置-->
    <meta-data
        android:name="com.amap.api.v2.apikey"
        android:value="请填写您的key"/>
    <!--高德地图APS服务设置-->
    <service android:name="com.amap.api.location.APSService" >
    </service>
...

```

## 完整示例

点击这里 [ReactNativeComponentDemos][0]

## 使用简介

Install the package from npm with `npm install react-native-smart-amap --save`.
Then, require it from your app's JavaScript files with `import Barcode from 'react-native-smart-amap'`.

```js
import React, {
    Component,
} from 'react'
import {
    StyleSheet,
    View,
    Text,
    Image,
    NativeAppEventEmitter,
    TouchableHighlight,
    ListView,
    Dimensions,
    Alert,
    Platform,
} from 'react-native'

import AMapLocation from 'react-native-smart-amap-location'
import AMap from 'react-native-smart-amap'
import Button from 'react-native-smart-button'
import AppEventListenerEnhance from 'react-native-smart-app-event-listener-enhance'
import PullToRefreshListView from 'react-native-smart-pull-to-refresh-listview'
import TimerEnhance from 'react-native-smart-timer-enhance'
import AMapALoneNearByList from './amp-alone-nearby-list'
import ListViewActivityIndicator from './ListViewActivityIndicator'

const {width: deviceWidth, height: deviceHeight} = Dimensions.get('window')

class AMapDemo extends Component {

    constructor(props) {
        super(props);

        this._amap = null
        this._page = 0
        this._coordinate = this.props.navigator.navigationContext._currentRoute.coordinate
        console.log(`this._coordinate -> `)
        console.log(this._coordinate)
        this._keywords = '商务住宅|学校'
        this._onDidMoveByUserTimer = null
    }

    componentDidMount() {
        this.addAppEventListener(
            NativeAppEventEmitter.addListener('amap.location.onLocationResult', this._onLocationResult),
            NativeAppEventEmitter.addListener('amap.onPOISearchDone', this._onPOISearchDone)
            //NativeAppEventEmitter.addListener('amap.onPOISearchFailed', this._onPOISearchFailed)
        )
    }

    render () {
        //console.log(`amap-alone render...`)
        return (
                <View style={{marginTop: (Platform.OS == 'ios' ? 20 + 44 : 56), flex: 1, }}>
                    <View style={{position: 'relative', height: (deviceHeight - (Platform.OS == 'ios' ? 64 : 56)) - 50 * 5,}}>
                        <AMap
                        ref={ component => this._amap = component }
                        style={{flex: 1, }}
                        options={{
                            frame: {
                                width: deviceWidth,
                                height: (deviceHeight - 64) - 50 * 5
                            },
                            showsUserLocation: false,
                            userTrackingMode: Platform.OS == 'ios' ? AMap.constants.userTrackingMode.none : null,
                            centerCoordinate: {
                                latitude: this._coordinate.latitude,
                                longitude: this._coordinate.longitude,
                            },
                            zoomLevel: 18.1,
                            centerMarker: Platform.OS == 'ios' ? 'icon_location' : 'poi_marker',
                        }}
                        onLayout={this._onLayout}
                        onDidMoveByUser={this._onDidMoveByUser}
                        />
                        <Button
                            touchableType={Button.constants.touchableTypes.highlight}
                            underlayColor={'#ccc'}
                            style={{padding: 5, position: 'absolute', left: 10, bottom: 20, backgroundColor: '#fff', justifyContent: 'center', borderRadius: 3, borderWidth: StyleSheet.hairlineWidth, borderColor: '#ffffff', justifyContent: 'center', }}
                            onPress={ () => {
                                AMapLocation.init(null)
                                AMapLocation.getLocation()
                                //this._activityIndicator.setState({ visible: true,})
                            }}>
                            <Image source={{uri: Platform.OS == 'ios' ? 'gpsStat1' : 'gps_stat1'}} style={{width: 28, height: 28,}}/>
                        </Button>
                   </View>
                    <View style={{flex: 1, position: 'relative',}}>
                        <AMapALoneNearByList
                            ref={ (component) => this._amapALoneNearByList = component }
                            onRefresh={this._onRefresh}
                            onLoadMore={this._onLoadMore}
                        />
                        <ListViewActivityIndicator
                            ref={ (component) => this._activityIndicator = component }
                            style={{marginRight: 10, position:'absolute', left: (deviceWidth - 20) / 2, top: (50 * 5 - 20) / 2, }}
                            color={'#a9a9a9'}/>
                    </View>
                </View>
        )
    }

    _onDidMoveByUser = (e) => {
        //console.log(`_onDidMoveByUser....`)
        if(this._onDidMoveByUserTimer) {
            this.clearTimeout(this._onDidMoveByUserTimer)
            this._onDidMoveByUserTimer = null
        }
        let { longitude, latitude, } = e.nativeEvent.data.centerCoordinate
        this._onDidMoveByUserTimer = this.setTimeout( ()=> {
            let {refresh_none, refresh_idle, load_more_none, load_more_idle, loaded_all,} = PullToRefreshListView.constants.viewState
            if((this._amapALoneNearByList._pullToRefreshListView._refreshState == refresh_none || this._amapALoneNearByList._pullToRefreshListView._refreshState == refresh_idle)
                && (this._amapALoneNearByList._pullToRefreshListView._loadMoreState == load_more_none
                || this._amapALoneNearByList._pullToRefreshListView._loadMoreState == load_more_idle
                || this._amapALoneNearByList._pullToRefreshListView._loadMoreState == loaded_all)) {
                console.log(`beginRefresh(true)....`)
                this._coordinate = {
                    longitude,
                    latitude,
                }
                this._activityIndicator.setState({ visible: true,})
                this._amapALoneNearByList._pullToRefreshListView._scrollView.scrollTo({ y: 0, animated: false, })
                this._amapALoneNearByList._pullToRefreshListView.beginRefresh(true)
                //this._amapALoneNearByList._pullToRefreshListView.beginRefresh()
                this._beginRefresh = true
            }
        }, 300)
    }

    _onLocationResult = (result) => {
        if(result.error) {
            console.log(`map-错误代码: ${result.error.code}, map-错误信息: ${result.error.localizedDescription}`)
        }
        else {
            if(result.formattedAddress) {
                console.log(`map-格式化地址 = ${result.formattedAddress}`)
            }
            else {
                console.log(`map-纬度 = ${result.coordinate.latitude}, map-经度 = ${result.coordinate.longitude}`)
                this._coordinate = {
                    latitude: result.coordinate.latitude,
                    longitude: result.coordinate.longitude,
                }
                this._amap.setOptions({
                    zoomLevel: 18.1,
                })
                this._amap.setCenterCoordinate(this._coordinate)
            }
        }
    }

    //_onPOISearchFailed = (e) => {
    //    //console.log(`_onPOISearchFailed...`)
    //    //console.log(e)
    //    //console.log(e.error)
    //    this._page--;
    //}

    _onPOISearchDone = (result) => {
        console.log(`_onPOISearchDone...`)

        if(Platform.OS == 'ios') {
            this._endSearch(result)
        }
        else {
            this.setTimeout( () => {
                this._endSearch(result)
            }, 255)
        }
    }

    _endSearch = (result) => {
        let { searchResultList, error } = result

        console.log(result.error)

        if(error) {
            if(this._page == 1) {
                this._page--
                this._amapALoneNearByList._pullToRefreshListView.endRefresh(this._beginRefresh)
                //this._amapALoneNearByList._pullToRefreshListView.endRefresh()
                this._beginRefresh = false
                this._activityIndicator.setState({ visible: false,})
            }
            else {
                this._amapALoneNearByList._pullToRefreshListView.endLoadMore(false)
            }
            return
        }

        console.log(`this._page = ${this._page}`)

        //onRefresh
        if(this._page == 1) {
            this._amapALoneNearByList.setState({
                dataList: searchResultList,
                dataSource: this._amapALoneNearByList._dataSource.cloneWithRows(searchResultList),
            })
            this._amapALoneNearByList._pullToRefreshListView.endRefresh(this._beginRefresh)
            //this._amapALoneNearByList._pullToRefreshListView.endRefresh()
            this._beginRefresh = false
            this._activityIndicator.setState({ visible: false,})
        }
        //onLoadMore
        else {
            let newDataList = this._amapALoneNearByList.state.dataList.concat(searchResultList)
            this._amapALoneNearByList.setState({
                dataList: newDataList,
                dataSource: this._amapALoneNearByList._dataSource.cloneWithRows(newDataList),
            })
            let loadedAll
            if(searchResultList.length == 100) {
                loadedAll = true
                this._amapALoneNearByList._pullToRefreshListView.endLoadMore(loadedAll)
            }
            else {
                loadedAll = false
                this._amapALoneNearByList._pullToRefreshListView.endLoadMore(loadedAll)
            }
        }
    }

    _searchNearBy = (searchParams)=> {
        this._amap.searchPoiByCenterCoordinate(searchParams)
    }

    _onRefresh = () => {
        console.log(`outer _onRefresh...`)
        this._searchNearBy({
            page: (this._page = 1),
            coordinate: this._coordinate,
            keywords: this._keywords,
        })
    }

    _onLoadMore = () => {
        console.log(`outer _onLoadMore...`)
        this._searchNearBy({
            page: ++this._page,
            coordinate: this._coordinate,
            keywords: this._keywords,
        })
    }

}

export default TimerEnhance(AppEventListenerEnhance(AMapDemo))
```

## 属性

Prop                        | Type   | Optional | Default   | Description
--------------------------- | ------ | -------- | --------- | -----------
options                     | object | No       |           | 地图参数对象
options.frame               | object | No       |           | ios设置地图宽(width), 高(height), 类型是number
options.showTraffic         | bool   | Yes      |           | ios设置是否显示路况, 默认不显示
options.showsUserLocation   | bool   | Yes      |           | ios设置是否显示用户位置，默认显示
options.userTrackingMode    | bool   | Yes      |           | ios设置追踪用户位置更新的模式，默认不追踪
options.zoomLevel           | number | Yes      |           | 指定缩放级别, 默认为最大级别
options.centerCoordinate    | object | Yes      |           | 根据经度(latitude)纬度(longitude)指定地图的中心点, 类型是number
options.centerMarker        | string | Yes      |           | 设置中心点自定义图标的项目资源名称, 如为空则不显示中心点图标

## 方法

* setOptions
  * 描述: 更改地图参数
  * 参数: reactTag 类型: number, 地图的native view id, 根据这个id可以获取到地图的实例
  * 参数: options  类型: object, 地图参数, 数据结构同上Props中的options

* setCenterCoordinate
  * 描述: 根据经纬度在地图中心位置显示
  * 参数: reactTag 类型: number, 地图的native view id, 根据这个id可以获取到地图的实例
  * 参数: coordinate  类型: object, 经纬度坐标参数, 数据结构同上Props中的options.centerCoordinate

* searchPoiByCenterCoordinate
  * 描述: 根据经纬度坐标来搜索周边的POI
  * 参数: params  类型: object, 搜索参数, 数据结构如下:
        * types 类型: string 表示搜索类型，多个类型用“|”分割 可选值:文本分类、分类代码
        * sortrule 类型: number 表示排序规则, 0-距离排序；1-综合排序, 默认1
        * offset 类型: number 表示每页记录数, 范围1-50, 默认20
        * page 类型: number 表示当前页数, 范围1-100, 默认1
        * keywords 类型: string 表示查询关键字，多个关键字用“|”分割
        * coordinate 类型: object 表示中心点经纬度, 数据结构同上Props中的options.centerCoordinate
        * radius 类型: int 表示辐射半径, 默认3000米

## 事件监听

* 地图事件: onDidMoveByUser
    * 描述: 监听用户动作, 返回当前地图中心点的经纬度信息

* 全局事件: amap.onPOISearchDone
    * 描述: 监听POI搜索回调, 返回周边的POI信息

[0]: https://github.com/cyqresig/ReactNativeComponentDemos
[1]: http://lbs.amap.com/api/
[2]: http://cyqresig.github.io/img/react-native-smart-amap-preview-ios-v1.0.0.gif
[3]: http://blog.csdn.net/jackymvc/article/details/50222503