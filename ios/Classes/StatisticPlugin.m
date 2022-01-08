#import "StatisticPlugin.h"
#if __has_include(<statistic/statistic-Swift.h>)
#import <statistic/statistic-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "statistic-Swift.h"
#endif

@implementation StatisticPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftStatisticPlugin registerWithRegistrar:registrar];
}
@end
