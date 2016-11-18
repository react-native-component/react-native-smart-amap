
#import "RCTAMap.h"

@interface RCTAMap ()

@property (nonatomic, weak) RCTAMapManager *manager;

@end

@implementation RCTAMap

- (id)initWithManager:(RCTAMapManager*)manager
{
    
    if ((self = [super init])) {
        self.manager = manager;
    }
    return self;
    
}

@end
