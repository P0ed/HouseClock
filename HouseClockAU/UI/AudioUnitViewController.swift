import CoreAudioKit
import SwiftUI
import Ux

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
	private let transmitter = BLETransmitter()
	private let controller = Controller()
	private var audioUnit: AUAudioUnit?
	private var timer: Timer?
    
    public override func viewDidLoad() {
        super.viewDidLoad()

//		let ctrl = UIHostingController(rootView: MainView(model: Model(
//			transmitter: transmitter,
//			controller: controller
//		)))
//
//		addChild(ctrl)
//		view.addSubview(ctrl.view)
//		ctrl.didMove(toParent: self)
	}
    
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        let unit = try HouseClockAudioUnit(componentDescription: componentDescription, options: [])
		audioUnit = unit

		DispatchQueue.main.async { [weak self] in
			let timer = Timer(timeInterval: 1 / 15, repeats: true) { [step = unit.step, view = self?.view] _ in
				view?.backgroundColor = UIColor(white: CGFloat(step.value / 15), alpha: 1)
			}
			self?.timer = timer
			RunLoop.current.add(timer, forMode: .common)
		}

        return unit
    }
}
