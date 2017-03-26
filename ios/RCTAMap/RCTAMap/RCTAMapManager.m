

//#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
//#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width

#import "RCTAMapManager.h"
#import "RCTAMap.h"
#import <React/RCTUIManager.h>
#import <React/RCTBridge.h>

#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface RCTAMapManager ()<MAMapViewDelegate, AMapSearchDelegate>

@property (nonatomic, strong) AMapSearchAPI *search;

@end

@implementation RCTAMapManager

RCT_EXPORT_MODULE(RCTAMap)

- (UIView *)view
{
//    RCTAMap *mapView = [[RCTAMap alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    RCTAMap *mapView = [[RCTAMap alloc] initWithManager:self];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mapView.delegate = self;
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    return mapView;
}

RCT_EXPORT_VIEW_PROPERTY(onDidMoveByUser, RCTBubblingEventBlock)

RCT_CUSTOM_VIEW_PROPERTY(options, NSDictionary, RCTAMap) {
    NSDictionary *options = [RCTConvert NSDictionary:json];
    [self setMapViewOptions:view :options];
}

-(void)setMapViewOptions:(RCTAMap *)view :(nonnull NSDictionary *)options
{
    NSArray *keys = [options allKeys];
    
    //地图宽高设置
    if([keys containsObject:@"frame"]) {
        NSDictionary *frame = [options objectForKey:@"frame"];
        CGFloat width = [[frame objectForKey:@"width"] floatValue];
        CGFloat height = [[frame objectForKey:@"height"] floatValue];
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, width, height);
    }
//    //地图类型，0为标准，1为卫星，默认为标准
//    if([keys containsObject:@"mapType"]) {
//        int mapType = [[options objectForKey:@"mapType"] intValue];
//        view.mapType = mapType;
//    }
    //是否显示路况，默认不显示
    if([keys containsObject:@"showTraffic"]) {
        BOOL showTraffic = [[options objectForKey:@"showTraffic"] boolValue];
        view.showTraffic = showTraffic;
    }
    //是否显示用户位置，默认显示
    if([keys containsObject:@"showsUserLocation"]) {
        BOOL showsUserLocation = [[options objectForKey:@"showsUserLocation"] boolValue];
        view.showsUserLocation = showsUserLocation;
    }
    //设置追踪用户位置更新的模式，默认不追踪
    if([keys containsObject:@"userTrackingMode"]) {
        int userTrackingMode = [[options objectForKey:@"userTrackingMode"] intValue];
        [view setUserTrackingMode:userTrackingMode animated:YES];
    }
    
    //指定缩放级别
    if([keys containsObject:@"zoomLevel"]) {
        double zoomLevel = [[options objectForKey:@"zoomLevel"] doubleValue];
        [view setZoomLevel:zoomLevel animated:NO];
    }
    
    //根据经纬度指定地图的中心点，并根据情况创建定位标记
    if([keys containsObject:@"centerCoordinate"]) {
        NSDictionary *centerCoordinate = [options objectForKey:@"centerCoordinate"];
        CGFloat latitude = [[centerCoordinate objectForKey:@"latitude"] floatValue];
        CGFloat longitude = [[centerCoordinate objectForKey:@"longitude"] floatValue];
        
//        NSLog(@"latitude = %f, longitude = %f, ", latitude, longitude);
        
        //view.centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
        [view setCenterCoordinate:CLLocationCoordinate2DMake(latitude, longitude) animated:YES];
        //    [view setZoomLevel:15 animated:true];
        
        if(!view.hasUserLocationPointAnnotaiton) {
//            NSLog(@"draw userLocation annoation...");
            
            view.hasUserLocationPointAnnotaiton = YES;
            MAPointAnnotation *pointAnnotaiton = [[MAPointAnnotation alloc] init];
            [pointAnnotaiton setCoordinate:view.centerCoordinate];
            pointAnnotaiton.lockedToScreen = YES;
            CGPoint screenPoint = [view convertCoordinate:view.centerCoordinate toPointToView:view];
            
            if([keys containsObject:@"centerMarker"]) {
                view.centerMarker = [options objectForKey:@"centerMarker"];
                
                UIImage *image = [UIImage imageNamed:view.centerMarker];
                
                //NSLog(@"screenPoint.x = %f, screenPoint.y = %f", screenPoint.x, screenPoint.y);
                
                pointAnnotaiton.lockedScreenPoint = CGPointMake(screenPoint.x, screenPoint.y - image.size.height / 2);
                
                //screenPoint.x = 183.129769, screenPoint.y = 126.198228
                
                [view addAnnotation:pointAnnotaiton];
            }
        }
    }
}

RCT_EXPORT_METHOD(setOptions:(nonnull NSNumber *)reactTag :(nonnull NSDictionary *)options)
{
    dispatch_async(self.bridge.uiManager.methodQueue,^{
        [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
            id view = viewRegistry[reactTag];
            RCTAMap *mapView = (RCTAMap *)view;
            [self setMapViewOptions:mapView :options];
        }];
    });

    
    
}




////地图宽高设置
//RCT_CUSTOM_VIEW_PROPERTY(frame, NSDictionary, RCTAMap) {
//    NSDictionary *frame = [RCTConvert NSDictionary:json];
//    CGFloat width = [[frame objectForKey:@"width"] floatValue];
//    CGFloat height = [[frame objectForKey:@"height"] floatValue];
//    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, width, height);
//}
//
////地图类型，0为标准，1为卫星，默认为标准
//RCT_CUSTOM_VIEW_PROPERTY(mapType, NSNumber, RCTAMap) {
//    NSNumber *mapType = [RCTConvert NSNumber:json];
//    view.mapType = [mapType intValue];
//}
//
////是否显示路况，默认不显示
//RCT_CUSTOM_VIEW_PROPERTY(showTraffic, BOOL, RCTAMap) {
//    BOOL showTraffic = [RCTConvert BOOL:json];
//    view.showTraffic = showTraffic;
//}
//
//
////是否显示用户位置，默认显示
//RCT_CUSTOM_VIEW_PROPERTY(showsUserLocation, BOOL, RCTAMap) {
//    BOOL showsUserLocation = [RCTConvert BOOL:json];
////    view.showsUserLocation = showsUserLocation;
//}
//
////设置追踪用户位置更新的模式
//RCT_CUSTOM_VIEW_PROPERTY(userTrackingMode, BOOL, RCTAMap) {
//    int userTrackingMode = [RCTConvert int:json];
//    NSLog(@"userTrackingMode = %d", userTrackingMode);
//    [view setUserTrackingMode:userTrackingMode animated:true];
//}
//
////根据经纬度指定地图的中心点
//RCT_CUSTOM_VIEW_PROPERTY(centerCoordinate, NSDictionary, RCTAMap) {
//    NSDictionary *centerCoordinate = [RCTConvert NSDictionary:json];
//    NSString *latitude = [centerCoordinate objectForKey:@"latitude"];
//    NSString *longitude = [centerCoordinate objectForKey:@"longitude"];
//    //    NSLog(@"latitude = %@, longitude = %@", latitude, longitude);
//    [view setCenterCoordinate:CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]) animated:YES];
////    [view setZoomLevel:15 animated:true];
//
//    if(!view.hasUserLocationPointAnnotaiton) {
//        NSLog(@"draw userLocation annoation...");
//        
//        view.hasUserLocationPointAnnotaiton = YES;
//        MAPointAnnotation *pointAnnotaiton = [[MAPointAnnotation alloc] init];
//        [pointAnnotaiton setCoordinate:view.centerCoordinate];
//        pointAnnotaiton.lockedToScreen = YES;
//        CGPoint screenPoint = [view convertCoordinate:view.centerCoordinate toPointToView:view];
//        
//        UIImage *image = [UIImage imageNamed:@"icon_location.png"];
//        
//        NSLog(@"screenPoint.x = %f, screenPoint.y = %f", screenPoint.x, screenPoint.y);
//        
//        pointAnnotaiton.lockedScreenPoint = CGPointMake(screenPoint.x, screenPoint.y - image.size.height / 2);
//        
//        //screenPoint.x = 183.129769, screenPoint.y = 126.198228
//        
//        [view addAnnotation:pointAnnotaiton];
//    }
//}
//
////指定缩放级别
//RCT_CUSTOM_VIEW_PROPERTY(zoomLevel, int, RCTAMap) {
//    int zoomLevel = [RCTConvert int:json];
//    [view setZoomLevel:zoomLevel animated:true];
//}


//定位当前用户位置，并自动显示在地图中心
RCT_EXPORT_METHOD(setCenterCoordinate:(nonnull NSNumber *)reactTag centerCoordinate:(nonnull NSDictionary *)coordinate)
{
    dispatch_async(self.bridge.uiManager.methodQueue,^{
        [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
            id view = viewRegistry[reactTag];
            RCTAMap *mapView = (RCTAMap *)view;
            CGFloat latitude = [[coordinate objectForKey:@"latitude"] floatValue];
            CGFloat longitude = [[coordinate objectForKey:@"longitude"] floatValue];
            [mapView setCenterCoordinate:CLLocationCoordinate2DMake(latitude, longitude) animated:YES];
        }];
    });

}

//RCT_EXPORT_METHOD(onDestroyBDMap:(nonnull NSNumber *)reactTag){
//    dispatch_async(self.bridge.uiManager.methodQueue,^{
//        [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
//            for(int i=0;i<self.tempArray.count;i++){
//                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(waveFun:) object:[self.tempArray objectAtIndex:i]];
//            }
//            id view = viewRegistry[reactTag];
//            self.geoSearcher.delegate = nil;
//            self.sugestionSearch.delegate = self;
//            BMKMapView *bk = (BMKMapView *)view;
//            [bk removeOverlays:bk.overlays];
//            [bk removeAnnotations:bk.annotations];
//            bk.delegate = nil;
//            bk = nil;
//        }];
//    });
//}

/* 根据中心点坐标来搜周边的POI. */
RCT_EXPORT_METHOD(searchPoiByCenterCoordinate:(NSDictionary *)params)
{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    
    if(params != nil) {
        NSArray *keys = [params allKeys];
        
//        NSLog(@"searchPoiByCenterCoordinate...");
        
        if([keys containsObject:@"types"]) {
            NSString *types = [params objectForKey:@"types"];
            request.types = types;
        }
        if([keys containsObject:@"sortrule"]) {
            int sortrule = [[params objectForKey:@"sortrule"] intValue];
            request.sortrule = sortrule;
        }
        if([keys containsObject:@"offset"]) {
            int offset = [[params objectForKey:@"offset"] intValue];
            request.offset = offset;
        }
        if([keys containsObject:@"page"]) {
            int page = [[params objectForKey:@"page"] intValue];
            request.page = page;
        }
        if([keys containsObject:@"requireExtension"]) {
            BOOL requireExtension = [[params objectForKey:@"requireExtension"] boolValue];
            request.requireExtension = requireExtension;
        }
        if([keys containsObject:@"requireSubPOIs"]) {
            BOOL requireSubPOIs = [[params objectForKey:@"requireSubPOIs"] boolValue];
            request.requireSubPOIs = requireSubPOIs;
        }
        

        if([keys containsObject:@"keywords"]) {
            NSString *keywords = [params objectForKey:@"keywords"];
            request.keywords = keywords;
        }
        if([keys containsObject:@"coordinate"]) {
            NSDictionary *coordinate = [params objectForKey:@"coordinate"];
            double latitude = [[coordinate objectForKey:@"latitude"] doubleValue];
            double longitude = [[coordinate objectForKey:@"longitude"] doubleValue];
            request.location = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
        }
//        if([keys containsObject:@"latitude"] && [keys containsObject:@"longitude"]) {
//            double latitude = [[params objectForKey:@"latitude"] doubleValue];
//            double longitude = [[params objectForKey:@"longitude"] doubleValue];
//            request.location = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
//        }
        if([keys containsObject:@"radius"]) {
            int *radius = [[params objectForKey:@"radius"] intValue];
            request.radius = radius;
        }
        
    }
    
    [self.search AMapPOIAroundSearch:request];
}

- (NSDictionary *)constantsToExport
{
    return @{
             @"userTrackingMode": @{
                     @"none": @(MAUserTrackingModeNone),
                     @"follow": @(MAUserTrackingModeFollow),
                     @"followWithHeading": @(MAUserTrackingModeFollowWithHeading)
                     }
             };
}


#pragma mark - Map Delegate

///*!
// @brief 地图区域即将改变时会调用此接口
// @param mapview 地图View
// @param animated 是否动画
// */
//- (void)mapView:(RCTAMap *)mapView regionWillChangeAnimated:(BOOL)animated {
//    
//}
//
///*!
// @brief 地图区域改变完成后会调用此接口
// @param mapview 地图View
// @param animated 是否动画
// */
//- (void)mapView:(RCTAMap *)mapView regionDidChangeAnimated:(BOOL)animated {
//    
//}
//
///**
// *  地图将要发生移动时调用此接口
// *
// *  @param mapView       地图view
// *  @param wasUserAction 标识是否是用户动作
// */
//- (void)mapView:(RCTAMap *)mapView mapWillMoveByUser:(BOOL)wasUserAction {
//    
//}
//
/**
 *  地图移动结束后调用此接口
 *
 *  @param mapView       地图view
 *  @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(RCTAMap *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    if(mapView.onDidMoveByUser) {
        mapView.onDidMoveByUser(@{
                                  @"data": @{
                                          @"centerCoordinate": @{
                                                  @"latitude": @(mapView.centerCoordinate.latitude),
                                                  @"longitude": @(mapView.centerCoordinate.longitude),
                                                  }
                                          },
                                  });
    }
}
//
///**
// *  地图将要发生缩放时调用此接口
// *
// *  @param mapView       地图view
// *  @param wasUserAction 标识是否是用户动作
// */
//- (void)mapView:(RCTAMap *)mapView mapWillZoomByUser:(BOOL)wasUserAction {
//    
//}
//
///**
// *  地图缩放结束后调用此接口
// *
// *  @param mapView       地图view
// *  @param wasUserAction 标识是否是用户动作
// */
//- (void)mapView:(RCTAMap *)mapView mapDidZoomByUser:(BOOL)wasUserAction {
//    
//}
//
///**
// *  单击地图底图调用此接口
// *
// *  @param mapView    地图View
// *  @param coordinate 点击位置经纬度
// */
//- (void)mapView:(RCTAMap *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
//    
//}
//
///**
// *  长按地图底图调用此接口
// *
// *  @param mapView    地图View
// *  @param coordinate 长按位置经纬度
// */
//- (void)mapView:(RCTAMap *)mapView didLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate {
//    
//}

/*!
 @brief 根据anntation生成对应的View
 @param mapView 地图View
 @param annotation 指定的标注
 @return 生成的标注View
 */
- (MAAnnotationView*)mapView:(RCTAMap *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
//        NSLog(@"viewForAnnotation...");
        
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout   = NO;
        annotationView.animatesDrop     = NO;
        annotationView.draggable        = NO;
        annotationView.image            = [UIImage imageNamed:mapView.centerMarker];
        
        return annotationView;
    }
    
    return nil;
}

/*!
 @brief 当mapView新添加annotation views时调用此接口
 @param mapView 地图View
 @param views 新添加的annotation views
 */
- (void)mapView:(RCTAMap *)mapView didAddAnnotationViews:(NSArray *)views {
    
//    MAAnnotationView *view = views[0];
//    // 放到该方法中用以保证userlocation的annotationView已经添加到地图上了。
//    if ([view.annotation isKindOfClass:[MAUserLocation class]])
//    {
//        MAUserLocationRepresentation *pre = [[MAUserLocationRepresentation alloc] init];
////        pre.fillColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:0.3];
////        pre.strokeColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.9 alpha:1.0];
////        pre.image = [UIImage imageNamed:@"userPosition"];
//        pre.lineWidth = 3;
//        //        pre.lineDashPattern = @[@6, @3];
//        pre.showsAccuracyRing = NO;
//        
//        
//        [mapView updateUserLocationRepresentation:pre];
//        
//        view.calloutOffset = CGPointMake(0, 0);
//        view.canShowCallout = NO;
//    }  

}

///*!
// @brief 当选中一个annotation views时调用此接口
// @param mapView 地图View
// @param views 选中的annotation views
// */
//- (void)mapView:(RCTAMap *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
//    
//}
//
///*!
// @brief 当取消选中一个annotation views时调用此接口
// @param mapView 地图View
// @param views 取消选中的annotation views
// */
//- (void)mapView:(RCTAMap *)mapView didDeselectAnnotationView:(MAAnnotationView *)view {
//    
//}
//
///*!
// @brief 标注view的accessory view(必须继承自UIControl)被点击时调用此接口
// @param mapView 地图View
// @param annotationView callout所属的标注view
// @param control 对应的control
// */
//- (void)mapView:(RCTAMap *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
//    
//}
//
///**
// *  标注view的calloutview整体点击时调用此接口
// *
// *  @param mapView 地图的view
// *  @param view calloutView所属的annotationView
// */
//- (void)mapView:(RCTAMap *)mapView didAnnotationViewCalloutTapped:(MAAnnotationView *)view {
//    
//}
//
///*!
// @brief 在地图View将要启动定位时调用此接口
// @param mapView 地图View
// */
//- (void)mapViewWillStartLocatingUser:(RCTAMap *)mapView {
//    
//}
//
///*!
// @brief 在地图View停止定位后调用此接口
// @param mapView 地图View
// */
//- (void)mapViewDidStopLocatingUser:(RCTAMap *)mapView {
//    
//}

/*!
 @brief 位置或者设备方向更新后调用此接口
 @param mapView 地图View
 @param userLocation 用户定位信息(包括位置与设备方向等数据)
 @param updatingLocation 标示是否是location数据更新, YES:location数据更新 NO:heading数据更新
 */
- (void)mapView:(RCTAMap *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if(!mapView.hasUserLocationPointAnnotaiton && userLocation.location) {
//        NSLog(@"draw userLocation annoation...");
        mapView.hasUserLocationPointAnnotaiton = YES;
        MAPointAnnotation *pointAnnotaiton = [[MAPointAnnotation alloc] init];
        [pointAnnotaiton setCoordinate:userLocation.location.coordinate];
        pointAnnotaiton.lockedToScreen = YES;
        CGPoint screenPoint = [mapView convertCoordinate:userLocation.location.coordinate toPointToView:mapView];
        
        UIImage *image = [UIImage imageNamed:mapView.centerMarker];
        
//        NSLog(@"screenPoint.x = %f, screenPoint.y = %f", screenPoint.x, screenPoint.y);
        
        CGFloat x = mapView.frame.origin.x;
        CGFloat y = mapView.frame.origin.y;
        CGFloat width = mapView.frame.size.width;
        CGFloat height = mapView.frame.size.height;
//        NSLog(@"x=%f,y=%f,width=%f,height=%f", x, y, width, height);
        
        pointAnnotaiton.lockedScreenPoint = CGPointMake(x + width / 2, y + height / 2 - image.size.height / 2);
        
        //screenPoint.x = 183.129769, screenPoint.y = 126.198228
        
        [mapView addAnnotation:pointAnnotaiton];
        
//        NSLog(@"searchPoiByCenterCoordinate...");
//        NSDictionary *searchParams = @{
//                                       @"keywords": @"商务住宅|学校",
//                                       @"latitude": @(userLocation.location.coordinate.latitude),
//                                       @"longitude": @(userLocation.location.coordinate.longitude)
//                                       };
//        [self searchPoiByCenterCoordinate:searchParams];
    }
}

///*!
// @brief 定位失败后调用此接口
// @param mapView 地图View
// @param error 错误号，参考CLError.h中定义的错误号
// */
//- (void)mapView:(RCTAMap *)mapView didFailToLocateUserWithError:(NSError *)error {
//    
//}
//
///*!
// @brief 当userTrackingMode改变时调用此接口
// @param mapView 地图View
// @param mode 改变后的mode
// @param animated 动画
// */
//- (void)mapView:(RCTAMap *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated {
//    
//}
//
///*!
// @brief 拖动annotation view时view的状态变化，ios3.2以后支持
// @param mapView 地图View
// @param view annotation view
// @param newState 新状态
// @param oldState 旧状态
// */
//- (void)mapView:(RCTAMap *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState fromOldState:(MAAnnotationViewDragState)oldState {
//    
//}
//
///*!
// @brief 根据overlay生成对应的Renderer
// @param mapView 地图View
// @param overlay 指定的overlay
// @return 生成的覆盖物Renderer
// */
//- (MAOverlayRenderer *)mapView:(RCTAMap *)mapView rendererForOverlay:(id <MAOverlay>)overlay {
//    return nil;
//}
//
///*!
// @brief 当mapView新添加overlay renderer时调用此接口
// @param mapView 地图View
// @param renderers 新添加的overlay renderers
// */
//- (void)mapView:(RCTAMap *)mapView didAddOverlayRenderers:(NSArray *)renderers {
//    
//}

#pragma mark - AMapSearchDelegate
/* 搜索失败回调. */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
//    NSLog(@"Error: %@", error);
    NSDictionary *result;
    result = @{
               @"error": @{
                            @"code": @(error.code),
                            @"localizedDescription": error.localizedDescription
                          }
               };
//    [self.bridge.eventDispatcher sendAppEventWithName:@"amap.onPOISearchFailed"
//                                                 body:result];
    [self.bridge.eventDispatcher sendAppEventWithName:@"amap.onPOISearchDone"
                                                 body:result];
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
//    NSLog(@"ios onPOISearchDone...");
    
    NSDictionary *result;
    NSMutableArray *resultList;
    resultList = [NSMutableArray arrayWithCapacity:response.pois.count];
    if (response.pois.count > 0)
    {
        [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
            
            [resultList addObject:@{
                                    @"uid": obj.uid,
                                    @"name": obj.name,
                                    @"type": obj.type,
                                    @"typecode": obj.typecode,
                                    @"latitude": @(obj.location.latitude),
                                    @"longitude": @(obj.location.longitude),
                                    @"address": obj.address,
                                    @"tel": obj.tel,
                                    @"distance": @(obj.distance)
                                    }];
            
        }];
    }
    result = @{
                 @"searchResultList": resultList
                 };
    [self.bridge.eventDispatcher sendAppEventWithName:@"amap.onPOISearchDone"
                                                 body:result];
}


@end
