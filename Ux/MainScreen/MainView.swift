import SwiftUI
import Combine

public struct MainView: View {
	@ObservedObject public var model: Model

	public init(model: Model) {
		self.model = model
	}

	public var body: some View {
		ZStack {
			Color(model.color).ignoresSafeArea()
			VStack {
				PatternView(
					pattern: model.state.pendingPattern ?? model.state.pattern,
					idx: model.state.pendingIndex
				)
				Text("\(String(format: "%.1f", model.state.bpm))")
					.font(.system(.largeTitle, design: .monospaced))
					.foregroundColor(model.state.bpm == 0 || !model.state.bleControls.contains(.run) ? .clear : .text)
				VStack {
					HStack {
						byteText(model.controls.lfoA.offset, .trailing)
						byteText(model.controls.lfoB.offset, .leading)
					}
					HStack {
						byteText(model.controls.lfoA.am, .trailing)
						byteText(model.controls.lfoB.am, .leading)
					}
					HStack {
						byteText(model.controls.lfoA.fm, .trailing)
						byteText(model.controls.lfoB.fm, .leading)
					}
				}
			}
		}
	}

	private func byteText(_ value: UInt8, _ alignment: Alignment) -> some View {
		Text("\(value)")
			.font(.system(.headline, design: .monospaced))
			.foregroundColor(value == 0 ? .clear : .text)
			.frame(width: 64, alignment: alignment)
	}
}

extension Model {
	var color: Color {
		isControllerConnected ? isBLEConnected ? .base : .bleDisconnected : .controllerDisconnected
	}
}
