#import <AVFoundation/AVFoundation.h>
#import <CoreAudioKit/AUViewController.h>
#import "DSPKernel.hpp"
#import "BufferedAudioBus.hpp"
#import "DSPKernelAdapter.h"


@implementation DSPKernelAdapter {
    DSPKernel _kernel;
    BufferedInputBus _bufferedBus;
}

- (instancetype)init {
	self = [super init];
	if (!self) return nil;

	AVAudioFormat *format = [AVAudioFormat.alloc initStandardFormatWithSampleRate:44100 channels:1];
	_kernel.init(format.sampleRate);
	_bufferedBus.init(format);
	_inputBus = _bufferedBus.bus;
	_outputBus = [AUAudioUnitBus.alloc initWithFormat:format error:nil];
	_outputBus.maximumChannelCount = 1;

    return self;
}

- (AUValue)step {
    return _kernel.getStep();
}

- (void)allocateRenderResources {
    _bufferedBus.allocateRenderResources(self.maximumFramesToRender);
    _kernel.init(self.outputBus.format.sampleRate);
    _kernel.reset();
}

- (void)deallocateRenderResources {
	_bufferedBus.deallocateRenderResources();
}

- (AUInternalRenderBlock)internalRenderBlock:(AUMIDIOutputEventBlock __unsafe_unretained)midiOut {
    DSPKernel *__block kernel = &_kernel;
    BufferedInputBus *__block input = &_bufferedBus;

    return ^AUAudioUnitStatus(AudioUnitRenderActionFlags 				*actionFlags,
                              const AudioTimeStamp       				*timestamp,
                              AVAudioFrameCount           				frameCount,
                              NSInteger                   				outputBusNumber,
                              AudioBufferList            				*outputData,
                              const AURenderEvent        				*realtimeEventListHead,
                              AURenderPullInputBlock __unsafe_unretained pullInputBlock) {

        AudioUnitRenderActionFlags pullFlags = 0;

        AUAudioUnitStatus err = input->pullInput(&pullFlags, timestamp, frameCount, 0, pullInputBlock);

        if (err != noErr) { return err; }

        AudioBufferList *inAudioBufferList = input->mutableAudioBufferList;

        // If passed null output buffer pointers, process in-place in the input buffer.
        AudioBufferList *outAudioBufferList = outputData;
        if (outAudioBufferList->mBuffers[0].mData == nullptr) {
            for (UInt32 i = 0; i < outAudioBufferList->mNumberBuffers; ++i) {
                outAudioBufferList->mBuffers[i].mData = inAudioBufferList->mBuffers[i].mData;
            }
        }

        kernel->setBuffers(inAudioBufferList, outAudioBufferList);
        kernel->process(timestamp, frameCount, midiOut);

        return noErr;
    };
}

@end
