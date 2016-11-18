
#import "RCTAMapManager.h"
#import <MAMapKit/MAMapKit.h>

@interface RCTAMap : MAMapView

@property (nonatomic, assign) BOOL hasUserLocationPointAnnotaiton;

@property (nonatomic, copy) RCTBubblingEventBlock onDidMoveByUser;

- (id)initWithManager: (RCTAMapManager*)manager;

@end
