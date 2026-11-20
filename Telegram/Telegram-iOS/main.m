#import <UIKit/UIKit.h>
#import <Intents/Intents.h>
#import <objc/runtime.h>

@interface SiriEntitlementBypass : NSObject
@end

@implementation SiriEntitlementBypass

+ (INSiriAuthorizationStatus)fakeSiriAuthorizationStatus {
    return INSiriAuthorizationStatusDenied;
}

+ (void)fakeRequestSiriAuthorization:(void (^)(INSiriAuthorizationStatus))handler {
    if (handler) {
        handler(INSiriAuthorizationStatusDenied);
    }
}

+ (void)load {
    Class inPrefs = [INPreferences class];
    if (!inPrefs) {
        NSLog(@"[SiriBypass] INPreferences class not found");
        return;
    }

    Method origStatus = class_getClassMethod(inPrefs, @selector(siriAuthorizationStatus));
    Method replStatus = class_getClassMethod(self, @selector(fakeSiriAuthorizationStatus));
    if (origStatus && replStatus) {
        method_setImplementation(origStatus, method_getImplementation(replStatus));
        NSLog(@"[SiriBypass] siriAuthorizationStatus hooked");
    } else {
        NSLog(@"[SiriBypass] siriAuthorizationStatus not found");
    }

    Method origReq = class_getClassMethod(inPrefs, @selector(requestSiriAuthorization:));
    Method replReq = class_getClassMethod(self, @selector(fakeRequestSiriAuthorization:));
    if (origReq && replReq) {
        method_setImplementation(origReq, method_getImplementation(replReq));
        NSLog(@"[SiriBypass] requestSiriAuthorization hooked");
    } else {
        NSLog(@"[SiriBypass] requestSiriAuthorization not found");
    }
}

@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, @"Application", @"AppDelegate");
    }
}
