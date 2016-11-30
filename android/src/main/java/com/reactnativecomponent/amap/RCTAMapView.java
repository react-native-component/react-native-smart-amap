package com.reactnativecomponent.amap;

import android.animation.ObjectAnimator;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Parcelable;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.amap.api.maps2d.AMap;
import com.amap.api.maps2d.CameraUpdate;
import com.amap.api.maps2d.CameraUpdateFactory;
import com.amap.api.maps2d.LocationSource;
import com.amap.api.maps2d.MapView;
import com.amap.api.maps2d.UiSettings;
import com.amap.api.maps2d.model.BitmapDescriptor;
import com.amap.api.maps2d.model.BitmapDescriptorFactory;
import com.amap.api.maps2d.model.CameraPosition;
import com.amap.api.maps2d.model.Circle;
import com.amap.api.maps2d.model.CircleOptions;
import com.amap.api.maps2d.model.LatLng;
import com.amap.api.maps2d.model.Marker;
import com.amap.api.maps2d.model.MarkerOptions;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.reactnativecomponent.amap.util.SensorEventHelper;

import static com.amap.api.maps2d.AMapOptions.LOGO_POSITION_BOTTOM_RIGHT;
import static com.amap.api.maps2d.AMapOptions.ZOOM_POSITION_RIGHT_CENTER;




public class RCTAMapView extends FrameLayout implements LocationSource, AMapLocationListener, AMap.OnCameraChangeListener {
    private String centerMarker = "";
    private String locationMarker = "";
    private static int SCROLL_BY_PX = 1;
    private MapView MAPVIEW;
    private LatLng latLng;
    private LocationSource.OnLocationChangedListener mListener;
    private AMapLocationClient mlocationClient;
    private AMapLocationClientOption mLocationOption;
    private SensorEventHelper mSensorHelper;
    private static final int STROKE_COLOR = Color.argb(180, 3, 145, 255);
    private static final int FILL_COLOR = Color.argb(10, 0, 0, 180);
    private AMap AMAP;
    private Marker mLocMarker;
    private Circle mCircle;
    private LatLng location;//定位标记
    private int PAGESIZE = 10;//每页显示数量
    private boolean isFirstMove = true;
    private UiSettings mapUiSettings;

    private MarkerOptions markerOption;
    private float RADIUS = 10;//定位圆圈
    private double zoomLevel = 18;
    private int HEIGHT, WIDTH, viewWidth, viewHeight;
    private ThemedReactContext CONTEXT;
    private ViewGroup.LayoutParams PARAM;
    private boolean hasLocationMarker = false;
    private boolean zoomControls = false;
    private boolean zoomGestures = true;
    private boolean scaleControls = false;
    private boolean compassEnable = false;
    private boolean onceLocation = true;
    private ImageView CenterView;

    private long startTime;

    public void setLatLng(LatLng latLng) {
        this.latLng = latLng;
    }

    public void setCenterMarker(String centerMarker) {
        this.centerMarker = centerMarker;
    }

    public void setLocationMarker(String locationMarker) {
        this.locationMarker = locationMarker;
    }

    public void setZoomLevel(double zoomLevel) {
        this.zoomLevel = zoomLevel;
    }

    public RCTAMapView(ThemedReactContext context) {
        super(context);
        this.CONTEXT = context;
        CenterView = new ImageView(context);
        Resources resources = context.getCurrentActivity().getResources();
        DisplayMetrics dm = resources.getDisplayMetrics();

        PARAM = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        /**
         * 处理中心点控件位置
         */
        if(centerMarker !=null && centerMarker != "") {
            HEIGHT = getHeight();
            WIDTH = getWidth();
            LayoutParams params = (LayoutParams) CenterView.getLayoutParams();

            viewWidth = CenterView.getMeasuredWidth();
            viewHeight = CenterView.getMeasuredHeight();

            params.setMargins(WIDTH / 2 - viewWidth / 2, HEIGHT / 2 - viewHeight, 0, 0);
            CenterView.setLayoutParams(params);
        }

        super.onLayout(changed, left, top, right, bottom);

    }

    /**
     * Activity onResume后调用view的onAttachedToWindow
     */
    @Override
    protected void onAttachedToWindow() {
        init();
        super.onAttachedToWindow();
    }

    /**
     * 初始化控件,定位位置
     */
    private void init() {
        mSensorHelper = new SensorEventHelper(CONTEXT);
        if (mSensorHelper != null) {
            mSensorHelper.registerSensorListener();
        }
        MAPVIEW = new MapView(CONTEXT);
        MAPVIEW.setLayoutParams(PARAM);
        this.addView(MAPVIEW);
        MAPVIEW.onCreate(CONTEXT.getCurrentActivity().getIntent().getExtras());

        if(centerMarker !=null && centerMarker != "") {
            CenterView.setLayoutParams(new ViewGroup.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
            CenterView.setImageResource(getImageId(centerMarker));
            this.addView(CenterView, 1);
        }

        setMapOptions();

    }


    /**
     * 设置一些amap的属性
     */
    private void setMapOptions() {

        AMAP = MAPVIEW.getMap();
        AMAP.setMapType(AMap.MAP_TYPE_NORMAL);// 矢量地图模式

        mapUiSettings = AMAP.getUiSettings();//实例化UiSettings类
        mapUiSettings.setZoomControlsEnabled(zoomControls);//显示缩放按钮
        mapUiSettings.setZoomPosition(ZOOM_POSITION_RIGHT_CENTER);//缩放按钮  右边界中部：ZOOM_POSITION_RIGHT_CENTER 右下：ZOOM_POSITION_RIGHT_BUTTOM。
        mapUiSettings.setLogoPosition(LOGO_POSITION_BOTTOM_RIGHT);//Logo的位置 左下：LOGO_POSITION_BOTTOM_LEFT 底部居中：LOGO_POSITION_BOTTOM_CENTER 右下：LOGO_POSITION_BOTTOM_RIGHT
        mapUiSettings.setCompassEnabled(compassEnable);//指南针
        mapUiSettings.setZoomGesturesEnabled(zoomGestures);//手势缩放
        mapUiSettings.setScaleControlsEnabled(scaleControls);//比例尺

        changeCamera(
                CameraUpdateFactory.newCameraPosition(new CameraPosition(
                        latLng, (float) zoomLevel, 30, 0)));

        hasLocationMarker = true;
        addLocationMarker(latLng, RADIUS, mLocMarker);

        AMAP.setLocationSource(this);// 设置定位监听
        AMAP.setOnCameraChangeListener(this);// 对amap添加移动地图事件监听器
        mapUiSettings.setMyLocationButtonEnabled(false);// 设置默认定位按钮是否显示
        AMAP.setMyLocationEnabled(true);// 设置为true表示显示定位层并可触发定位，false表示隐藏定位层并不可触发定位，默认是false


    }

    /**
     * 中心点添加定位标记
     *
     * @param latLng
     * @param RADIUS
     * @param mLocMarker
     */
    private void addLocationMarker(LatLng latLng, float RADIUS, Marker mLocMarker) {
//        addCircle(latLng, RADIUS);//添加定位精度圆
//        addMarker(latLng);//添加定位图标
//        mSensorHelper.setCurrentMarker(mLocMarker);//定位图标旋转
    }

    /**
     * 调用函数moveCamera来改变可视区域
     */
    private void changeCamera(CameraUpdate update) {

        AMAP.moveCamera(update);

    }

    /**
     * 获得图片资源ID
     *
     * @return
     */
    private int getImageId(String fileName) {
        int drawableId = CONTEXT.getCurrentActivity().getResources().getIdentifier(fileName, "drawable", CONTEXT.getCurrentActivity().getClass().getPackage().getName());
        if (drawableId == 0) {
            drawableId = CONTEXT.getCurrentActivity().getResources().getIdentifier("splash", "drawable", CONTEXT.getCurrentActivity().getPackageName());
        }

        return drawableId;
    }

    /**
     * 根据动画调用函数animateCamera来改变可视区域
     */
    private void animateCamera(CameraUpdate update, AMap.CancelableCallback callback) {

        AMAP.animateCamera(update, 1000, callback);

    }

    @Override
    protected Parcelable onSaveInstanceState() {
        if (CONTEXT.getCurrentActivity().getIntent() != null && CONTEXT.getCurrentActivity().getIntent().getExtras() != null) {
            MAPVIEW.onSaveInstanceState(CONTEXT.getCurrentActivity().getIntent().getExtras());
        }
        return super.onSaveInstanceState();
    }

    @Override
    protected void onDetachedFromWindow() {
        this.removeView(MAPVIEW);
        MAPVIEW.onDestroy();
        super.onDetachedFromWindow();
    }

    /**
     * 对应onResume、对应onPause
     *
     * @param hasWindowFocus
     */
    @Override
    public void onWindowFocusChanged(boolean hasWindowFocus) {

        super.onWindowFocusChanged(hasWindowFocus);

        if (hasWindowFocus) {
//            对应onResume
            MAPVIEW.onResume();
        } else {
            //对应onPause
            MAPVIEW.onPause();

        }

    }

    @Override
    public void onLocationChanged(AMapLocation amapLocation) {

//        if (!isFirstMove) {
//            isFirstMove = true;
//        }
//
//        if (mListener != null && amapLocation != null) {
//            if (amapLocation != null
//                    && amapLocation.getErrorCode() == 0) {
//
//                location = new LatLng(amapLocation.getLatitude(), amapLocation.getLongitude());
////                Log.i("TEST", "getLatitude:"+amapLocation.getLatitude()+"getLongitude:"+amapLocation.getLongitude());
//                DEFAULTCITY = amapLocation.getCity();
//                if (!hasLocationMarker) {
//                    hasLocationMarker = true;
//                    addLocationMarker(location, RADIUS, mLocMarker);
////                    首次定位到点location
////                    AMAP.moveCamera(CameraUpdateFactory.newLatLngZoom(location, zoomLevel));
//                } else {
//                    mCircle.setCenter(location);
//                    mCircle.setRadius(RADIUS);
//                    mLocMarker.setPosition(location);
//                }
//                //移动镜头定位到点location
//                /*AMAP.moveCamera(CameraUpdateFactory.newLatLngZoom(location, zoomLevel));*/
//
//                changeCamera(
//                        CameraUpdateFactory.newCameraPosition(new CameraPosition(
//                                location, zoomLevel, 30, 0)));
//              /*  animateCamera(CameraUpdateFactory.newCameraPosition(new CameraPosition(
//                        location, zoomLevel, 30, 0)),null);*/
//                changeCamera(CameraUpdateFactory.scrollBy(0, -SCROLL_BY_PX));
//            } else {
//                String errText = "定位失败," + amapLocation.getErrorCode() + ": " + amapLocation.getErrorInfo();
//                Log.i("TEST", errText);
//
//            }
//        }
//        long endTime2 = System.currentTimeMillis();
//        Log.i("Test", "onLocationChangedFINISH:" + (endTime2 - startTime + ",getLatitude=" + amapLocation.getLatitude() + "getLongitude=" + amapLocation.getLongitude()));
    }

    /**
     * 获得当前控件中心点坐标
     */
    public LatLng getCenterLocation() {
        LatLng latlng = AMAP.getCameraPosition().target;
//    addMarkersToMap(latlng);
        return latlng;
    }

    /**
     * 获得当前控件中心点坐标
     */
    public void setCenterLocation(double latitude, double longitude) {
        LatLng latlng = new LatLng(latitude, longitude);
        AMAP.moveCamera(CameraUpdateFactory.newLatLngZoom(latlng, (float)zoomLevel));
//    addMarkersToMap(latlng);
    }

    /**
     * 在地图上添加marker
     */
    private void addMarkersToMap(LatLng latlng) {

        markerOption = new MarkerOptions().icon(BitmapDescriptorFactory
                .defaultMarker(BitmapDescriptorFactory.HUE_AZURE))
                .position(latlng)
                .draggable(true);
        AMAP.addMarker(markerOption);
    }


    /**
     * 定位到设备定位位置
     */
    public void startLocation() {
        startTime = System.currentTimeMillis();
        Log.i("Test", "startTime:" + startTime);
        if (mlocationClient == null) {
            Log.i("Test", "mlocationClient = null");
            mlocationClient = new AMapLocationClient(CONTEXT);
            mLocationOption = new AMapLocationClientOption();
            //设置定位监听
            mlocationClient.setLocationListener(this);
            //设置为高精度定位模式
            mLocationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.Hight_Accuracy);
            mLocationOption.setOnceLocation(onceLocation);
//            mLocationOption.setOnceLocationLatest(true);
            mLocationOption.setLocationCacheEnable(true);//定位缓存策略
//            mLocationOption.setInterval(10);
//            mLocationOption.setInterval(3*60*1000);
            //设置定位参数
            mlocationClient.setLocationOption(mLocationOption);

            // 此方法为每隔固定时间会发起一次定位请求，为了减少电量消耗或网络流量消耗，
            // 注意设置合适的定位时间的间隔（最小间隔支持为2000ms），并且在合适时间调用stopLocation()方法来取消定位请求
            // 在定位结束后，在合适的生命周期调用onDestroy()方法
            // 在单次定位情况下，定位无论成功与否，都无需调用stopLocation()方法移除请求，定位sdk内部会移除

        }
        mlocationClient.startLocation();
    }

    private void addCircle(LatLng latlng, float RADIUS) {
        CircleOptions options = new CircleOptions();
        options.strokeWidth(1f);
        options.fillColor(FILL_COLOR);
        options.strokeColor(STROKE_COLOR);
        options.center(latlng);
        options.radius(RADIUS);
        mCircle = AMAP.addCircle(options);

/*        ObjectAnimator radiusAnim = ObjectAnimator.ofFloat(mCircle, "radius", radius,0.0f,radius);
        radiusAnim.setDuration(1000);
        radiusAnim.setRepeatCount(ValueAnimator.INFINITE);//无限循环
//        translationYAnim.setRepeatMode(ValueAnimator.INFINITE);
        radiusAnim.start();*/

    }

    private void addMarker(LatLng latlng) {
        if (mLocMarker != null) {
            return;
        }
//        Bitmap bMap = BitmapFactory.decodeResource(this.getResources(),
//                R.drawable.navi_map_gps_locked);
        Bitmap bMap = BitmapFactory.decodeResource(this.getResources(),
                getImageId(locationMarker));
        BitmapDescriptor des = BitmapDescriptorFactory.fromBitmap(bMap);

//		BitmapDescriptor des = BitmapDescriptorFactory.fromResource(R.drawable.navi_map_gps_locked);
        MarkerOptions options = new MarkerOptions();
        options.icon(des);
        options.anchor(0.5f, 0.5f);
        options.position(latlng);
        // 将Marker设置为贴地显示，可以双指下拉看效果

        mLocMarker = AMAP.addMarker(options);
    }


    @Override
    public void activate(OnLocationChangedListener listener) {
        mListener = listener;
//        startLocation();
    }

    @Override
    public void deactivate() {
        mListener = null;
        if (mlocationClient != null) {
            mlocationClient.stopLocation();
            mlocationClient.onDestroy();
        }
        mlocationClient = null;
    }

    @Override
    public void onCameraChange(CameraPosition cameraPosition) {


    }

    /**
     * 控制中心点动画 获取中心点坐标 查询周边
     *
     * @param cameraPosition
     */
    @Override
    public void onCameraChangeFinish(CameraPosition cameraPosition) {
        /**
         * 中心点动画开始
         */
        ObjectAnimator translationYAnim = ObjectAnimator.ofFloat(CenterView, "translationY", 0.0f, -viewHeight / 2, 0.0f);
        translationYAnim.setDuration(600);
//        translationYAnim.setRepeatCount(ValueAnimator.RESTART);//重复一次
//        translationYAnim.setRepeatMode(ValueAnimator.INFINITE);
        translationYAnim.start();
        /**
         * 中心点动画结束
         */


        if (!isFirstMove) {
            return;
        }
        LatLng latlng = AMAP.getCameraPosition().target;//获取屏幕中心点

        WritableMap eventMap = Arguments.createMap();
        WritableMap dataMap = Arguments.createMap();
        WritableMap centerCoordinateMap = Arguments.createMap();
        centerCoordinateMap.putDouble("latitude", latlng.latitude);
        centerCoordinateMap.putDouble("longitude", latlng.longitude);
        dataMap.putMap("centerCoordinate", centerCoordinateMap);
        eventMap.putMap("data", dataMap);
        ReactContext reactContext = (ReactContext) getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                getId(),
                "onDidMoveByUser",
                eventMap);

    }
}
