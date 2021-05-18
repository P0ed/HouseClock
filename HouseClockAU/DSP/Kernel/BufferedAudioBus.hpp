#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>

struct BufferedAudioBus {
    AUAudioUnitBus *bus = nullptr;
    AUAudioFrameCount maxFrames = 0;
    
    AVAudioPCMBuffer *pcmBuffer = nullptr;
    
    AudioBufferList const *originalAudioBufferList = nullptr;
    AudioBufferList *mutableAudioBufferList = nullptr;

    void init(AVAudioFormat *format) {
        maxFrames = 0;
        pcmBuffer = nullptr;
        originalAudioBufferList = nullptr;
        mutableAudioBufferList = nullptr;

        bus = [AUAudioUnitBus.alloc initWithFormat:format error:nil];
		bus.maximumChannelCount = format.channelCount;
    }

    void allocateRenderResources(AUAudioFrameCount inMaxFrames) {
        maxFrames = inMaxFrames;

        pcmBuffer = [AVAudioPCMBuffer.alloc initWithPCMFormat:bus.format frameCapacity:maxFrames];

        originalAudioBufferList = pcmBuffer.audioBufferList;
        mutableAudioBufferList = pcmBuffer.mutableAudioBufferList;
    }
    
    void deallocateRenderResources() {
        pcmBuffer = nullptr;
        originalAudioBufferList = nullptr;
        mutableAudioBufferList = nullptr;
    }
};

struct BufferedOutputBus: BufferedAudioBus {
    void prepareOutputBufferList(AudioBufferList *outBufferList, AVAudioFrameCount frameCount, bool zeroFill) {
        UInt32 byteSize = frameCount * sizeof(float);
        for (UInt32 i = 0; i < outBufferList->mNumberBuffers; ++i) {
            outBufferList->mBuffers[i].mNumberChannels = originalAudioBufferList->mBuffers[i].mNumberChannels;
            outBufferList->mBuffers[i].mDataByteSize = byteSize;
            if (outBufferList->mBuffers[i].mData == nullptr) {
                outBufferList->mBuffers[i].mData = originalAudioBufferList->mBuffers[i].mData;
            }
            if (zeroFill) {
                memset(outBufferList->mBuffers[i].mData, 0, byteSize);
            }
        }
    }
};

struct BufferedInputBus: BufferedAudioBus {

	AUAudioUnitStatus pullInput(AudioUnitRenderActionFlags *actionFlags,
                                AudioTimeStamp const *timestamp,
                                AVAudioFrameCount frameCount,
                                NSInteger inputBusNumber,
                                AURenderPullInputBlock __unsafe_unretained pullInputBlock) {
        if (pullInputBlock == nullptr) {
            return kAudioUnitErr_NoConnection;
        }
        
        /*
         Important:
         The Audio Unit must supply valid buffers in (inputData->mBuffers[x].mData) and mDataByteSize.
         mDataByteSize must be consistent with frameCount.

         The AURenderPullInputBlock may provide input in those specified buffers, or it may replace
         the mData pointers with pointers to memory which it owns and guarantees will remain valid
         until the next render cycle.

         See prepareInputBufferList()
         */

        prepareInputBufferList(frameCount);

        return pullInputBlock(actionFlags, timestamp, frameCount, inputBusNumber, mutableAudioBufferList);
    }
    
    /*
     prepareInputBufferList populates the mutableAudioBufferList with the data
     pointers from the originalAudioBufferList.
     
     The upstream audio unit may overwrite these with its own pointers, so each
     render cycle this function needs to be called to reset them.
     */
    void prepareInputBufferList(UInt32 frameCount) {
        UInt32 byteSize = std::min(frameCount, maxFrames) * sizeof(float);
        mutableAudioBufferList->mNumberBuffers = originalAudioBufferList->mNumberBuffers;

        for (UInt32 i = 0; i < originalAudioBufferList->mNumberBuffers; ++i) {
            mutableAudioBufferList->mBuffers[i].mNumberChannels = originalAudioBufferList->mBuffers[i].mNumberChannels;
            mutableAudioBufferList->mBuffers[i].mData = originalAudioBufferList->mBuffers[i].mData;
            mutableAudioBufferList->mBuffers[i].mDataByteSize = byteSize;
        }
    }
};
