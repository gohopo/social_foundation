#import "SocialFoundationPlugin.h"
#if __has_include(<social_foundation/social_foundation-Swift.h>)
#import <social_foundation/social_foundation-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "social_foundation-Swift.h"
#endif

@implementation SocialFoundationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSocialFoundationPlugin registerWithRegistrar:registrar];
}
@end
