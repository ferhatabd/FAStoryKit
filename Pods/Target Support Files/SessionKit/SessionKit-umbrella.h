#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SessionKit.h"

FOUNDATION_EXPORT double SessionKitVersionNumber;
FOUNDATION_EXPORT const unsigned char SessionKitVersionString[];

