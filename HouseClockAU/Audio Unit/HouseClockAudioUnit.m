#import "HouseClockAudioUnit.h"
#import <AVFoundation/AVFoundation.h>


@interface HouseClockAudioUnit ()

@property (nonatomic) AUParameterTree *parameterTree;
@property (nonatomic) AUAudioUnitBusArray *inputBusArray;
@property (nonatomic) AUAudioUnitBusArray *outputBusArray;

@end


@implementation HouseClockAudioUnit

@synthesize parameterTree = _parameterTree;

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription options:(AudioComponentInstantiationOptions)options error:(NSError **)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    
    if (!self) return nil;

	_kernelAdapter = [DSPKernelAdapter.alloc init];

	_inputBusArray  = [AUAudioUnitBusArray.alloc initWithAudioUnit:self
														   busType:AUAudioUnitBusTypeInput
															busses:@[_kernelAdapter.inputBus]];
	_outputBusArray = [AUAudioUnitBusArray.alloc initWithAudioUnit:self
														   busType:AUAudioUnitBusTypeOutput
															busses:@[_kernelAdapter.outputBus]];

	_step = HouseClockAudioUnit.step;
	_parameterTree = [AUParameterTree createTreeWithChildren:@[_step]];

	DSPKernelAdapter *__block kernelAdapter = _kernelAdapter;
	_parameterTree.implementorValueProvider = ^(AUParameter *param) {
		return kernelAdapter.step;
	};
	_parameterTree.implementorStringFromValueCallback = ^NSString *(AUParameter *param, const AUValue *__nullable valuePtr) {
		AUValue value = valuePtr ? *valuePtr : param.value;
		return [NSString stringWithFormat:@"%d", ((int32_t)value)];
	};

	return self;
}

+ (AUParameter *)step {
	return [AUParameterTree createParameterWithIdentifier:@"step" name:@"Step" address:0
													  min:0 max:15 unit:kAudioUnitParameterUnit_Indexed unitName:@"Step"
													flags:kAudioUnitParameterFlag_IsReadable|kAudioUnitParameterFlag_MeterReadOnly
											 valueStrings:nil
									  dependentParameters:nil];
}

// MARK: - AUAudioUnit Overrides
- (AUAudioFrameCount)maximumFramesToRender {
    return _kernelAdapter.maximumFramesToRender;
}
- (void)setMaximumFramesToRender:(AUAudioFrameCount)maximumFramesToRender {
    _kernelAdapter.maximumFramesToRender = maximumFramesToRender;
}
- (AUAudioUnitBusArray *)inputBusses {
	return _inputBusArray;
}
- (AUAudioUnitBusArray *)outputBusses {
	return _outputBusArray;
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {

	if (_kernelAdapter.outputBus.format.channelCount != _kernelAdapter.inputBus.format.channelCount) {
		if (outError) {
			*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:kAudioUnitErr_FailedInitialization userInfo:nil];
		}
		self.renderResourcesAllocated = NO;

		return NO;
	}

	[super allocateRenderResourcesAndReturnError:outError];
	[_kernelAdapter allocateRenderResources];

	return YES;
}
- (void)deallocateRenderResources {
	[_kernelAdapter deallocateRenderResources];
    [super deallocateRenderResources];
}

// MARK: - AUAudioUnit (AUAudioUnitImplementation)
- (AUInternalRenderBlock)internalRenderBlock {
	return [_kernelAdapter internalRenderBlock:self.MIDIOutputEventBlock];
}
- (NSArray<NSString *> *)MIDIOutputNames {
	return @[@"Pattern"];
}

@end
