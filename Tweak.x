#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// Global pointer to store the original implementation of the ad completion callback
static void (*Original_AdDidFinish)(id, SEL, id, id);

// Our custom replacement function that intercepts and simulates a valid lifecycle completion
void Swizzled_AdDidFinish(id self, SEL _cmd, id adObject, id error) {
    NSLog(@"[NebulaT] Intercepted ad sequence entry point.");

    // 1. Check if an error occurred naturally, clear it to prevent failure triggers
    if (error != nil) {
        error = nil; 
    }

    // 2. Introduce a micro-delay to simulate normal network communication states
    [NSThread sleepForTimeInterval:0.35];

    // 3. Programmatically invoke the success state or reward callback method
    SEL rewardSelector = sel_registerName("rewardUserWithAmount:");
    id delegate = [self valueForKey:@"delegate"];
    
    if (delegate && [delegate respondsToSelector:rewardSelector]) {
        NSLog(@"[NebulaT] Simulating genuine reward callback signal.");
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [delegate performSelector:rewardSelector withObject:@(1)];
        #pragma clang diagnostic pop
    }

    // 4. Fall back safely to the original method implementation to preserve app stability
    if (Original_AdDidFinish) {
        Original_AdDidFinish(self, _cmd, adObject, error);
    }
}

// The initialization function that executes automatically when the dylib loads into memory
__attribute__((constructor)) static void initializeTweak() {
    NSLog(@"[NebulaT] Initialization sequence triggered.");

    // Target the specific internal class handling the ad framework execution state
    Class targetClass = objc_getClass("GADRewardBasedVideoAd");
    
    if (targetClass != nil) {
        // Resolve the specific selector that handles the completion event loop
        SEL targetSelector = sel_registerName("rewardBasedVideoAd:didFailToLoadWithError:");
        
        Method originalMethod = class_getInstanceMethod(targetClass, targetSelector);
        
        if (originalMethod) {
            // Swap the real method pointer with our custom swizzled version
            Original_AdDidFinish = (void *)method_getImplementation(originalMethod);
            method_setImplementation(originalMethod, (IMP)Swizzled_AdDidFinish);
            NSLog(@"[NebulaT] Dynamic method swizzling successfully established.");
        }
    } else {
        NSLog(@"[NebulaT] Target runtime hooks omitted in this execution cycle.");
    }
}
