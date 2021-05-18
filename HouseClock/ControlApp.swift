import SwiftUI
import Combine
import Ux

@main
struct ControlApp: App {
	var transmitter = BLETransmitter()
	var controller = Controller()

	var body: some Scene {
		WindowGroup {
			MainView(model: Model(
				transmitter: transmitter,
				controller: controller
			))
			.onAppear { UIApplication.shared.isIdleTimerDisabled = true }
			.onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
		}
	}
}
