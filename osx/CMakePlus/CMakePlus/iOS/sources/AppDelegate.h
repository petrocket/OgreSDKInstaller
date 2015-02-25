//
//  AppDelgate.h
//
//  Created by Alex on 5/20/14.
//
//

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#endif

#include <Ogre.h>

@interface AppDelegate : NSObject <UIApplicationDelegate>
{
    id mDisplayLink;
    NSDate *mDate;
}

- (void)renderOneFrame;

@property double lastFrameTime;
@property double startTime;

@end
