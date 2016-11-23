package com.reactnativecomponent.amap;


import com.amap.api.maps2d.model.LatLng;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.Map;

public class RCTAMapManager extends ViewGroupManager<RCTAMapView> {
//    public static final LatLng SHANGHAI = new LatLng(31.238068, 121.501654);// 上海市经纬度
    @Override
    public String getName() {
        return "RCTAMapView";
    }


    @Override
    protected RCTAMapView createViewInstance(ThemedReactContext reactContext) {
        RCTAMapView mapView = new RCTAMapView(reactContext);
        return mapView;
    }

    @ReactProp(name = "options")
    public void setOptions(RCTAMapView view, final ReadableMap Map) {
        if(Map.hasKey("centerCoordinate")) {
            ReadableMap centerCoordinateMap = Map.getMap("centerCoordinate");
            view.setLatLng(new LatLng(centerCoordinateMap.getDouble("latitude"), centerCoordinateMap.getDouble("longitude")));
        }
        if(Map.hasKey("zoomLevel")) {
            double zoomLevel = Map.getDouble("zoomLevel");
            view.setZoomLevel(zoomLevel);
        }
        if(Map.hasKey("centerMarker")) {
            String centerMarker = Map.getString("centerMarker");
            view.setCenterMarker(centerMarker);
        }
    }

    @Override
    protected void addEventEmitters(
            final ThemedReactContext reactContext,
            final RCTAMapView view) {
    }

    @Override
    public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.<String, Object>builder()
                .put("onDidMoveByUser", MapBuilder.of("registrationName", "onDidMoveByUser"))//registrationName 后的名字,RN中方法也要是这个名字否则不执行
                .build();
    }

}
