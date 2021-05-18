#ifndef DSPKernel_h
#define DSPKernel_h

#import <AudioToolbox/AudioToolbox.h>
#import <algorithm>

class DSPKernel {
public:
	DSPKernel() {}

	void reset() {
		step = -1;
	}

	void init(double inSampleRate) {
		sampleRate = inSampleRate;
	}

	AUValue getStep() {
		return AUValue(MIN(MAX(step, 0), 15));
	}

	void setBuffers(AudioBufferList *inBufferList, AudioBufferList *outBufferList) {
		inBufferListPtr = inBufferList;
		outBufferListPtr = outBufferList;
	}

	void process(AudioTimeStamp const *timestamp, AUAudioFrameCount frameCount, AUMIDIOutputEventBlock midiOut) {
		float const *in = (float *)inBufferListPtr->mBuffers[0].mData;
		auto time = AUEventSampleTime(timestamp->mSampleTime);

		for (int frame = 0; frame < frameCount; ++frame) {
			auto sampleAbs = abs(in[frame]);

			if (sampleAbs > 0.5 && lastEvent + 2048 < time + frame) {
				step = (step + 1) % 16;
				lastEvent = time + frame;
				if (midiOut) playStep(frame, midiOut);
				break;
			}
		}
	}

	void playStep(int frame, AUMIDIOutputEventBlock midiOut) {
		uint8_t kickOn[3] = {0x90, 0x10, 0x7F};
		uint8_t kickOff[3] = {0x80, 0x10, 0x7F};
		uint8_t clapOn[3] = {0x90, 0x09, 0x7F};
		uint8_t clapOff[3] = {0x80, 0x09, 0x7F};
		uint8_t oHatOn[3] = {0x90, 0x0A, 0x7F};
		uint8_t oHatOff[3] = {0x80, 0x0A, 0x7F};
		uint8_t cHatOn[3] = {0x90, 0x0B, 0x7F};
		uint8_t cHatOff[3] = {0x80, 0x0B, 0x7F};

		if (step % 4 == 0) {
			midiOut(AUEventSampleTimeImmediate + frame, 0, 3, kickOn);
			midiOut(AUEventSampleTimeImmediate + frame + 2048, 0, 3, kickOff);
		}
		if (step % 8 == 0) {
			midiOut(AUEventSampleTimeImmediate + frame, 0, 3, clapOn);
			midiOut(AUEventSampleTimeImmediate + frame + 2048, 0, 3, clapOff);
		}
		if ((step + 2) % 4 == 0) {
			midiOut(AUEventSampleTimeImmediate + frame, 0, 3, oHatOn);
			midiOut(AUEventSampleTimeImmediate + frame + 2048, 0, 3, oHatOff);
		}
		midiOut(AUEventSampleTimeImmediate + frame, 0, 3, cHatOn);
		midiOut(AUEventSampleTimeImmediate + frame + 2048, 0, 3, cHatOff);
	}

private:
	int step = -1;
	AUEventSampleTime lastEvent = 0;

	AUAudioFrameCount maxFramesToRender = 1024;
	double sampleRate = 44100;

	AudioBufferList *inBufferListPtr = nullptr;
	AudioBufferList *outBufferListPtr = nullptr;
};

#endif
