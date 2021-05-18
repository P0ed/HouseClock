#import <AudioToolbox/AudioToolbox.h>
#import "DSPKernelAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface HouseClockAudioUnit : AUAudioUnit

@property (nonatomic, readonly) DSPKernelAdapter *kernelAdapter;
@property (nonatomic, readonly) AUParameter *step;

@end

NS_ASSUME_NONNULL_END
