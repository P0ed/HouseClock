import GameController
import Combine
import Fx

public final class Controller {
	@MutableProperty
	private var current: GCController? = GCController.controllers().first
	private let lifetime: Cancellable

	@Property
	public var isConnected: Bool

	@MutableProperty
	private(set) var controls = Controls()

	public init() {
		let observers = [
			NotificationCenter.default.addObserver(name: .GCControllerDidBecomeCurrent) { [_current] n in
				_current.value = n.object as? GCController
			},
			NotificationCenter.default.addObserver(name: .GCControllerDidStopBeingCurrent) { [_current] n in
				_current.value = nil
			}
		]
		_isConnected = _current.map { $0 != nil }
		let handlers = _current.observe { [_controls] controller in
			guard let gamepad = controller?.extendedGamepad else { return }
			_controls.value = Controls()

			gamepad.leftThumbstick.valueChangedHandler = { _, x, y in
				_controls.value.leftStick = Controls.Thumbstick(x: x, y: y)
			}
			gamepad.rightThumbstick.valueChangedHandler = { _, x, y in
				_controls.value.rightStick = Controls.Thumbstick(x: x, y: y)
			}
			gamepad.leftTrigger.valueChangedHandler = { _, value, _ in
				_controls.value.leftTrigger = value
			}
			gamepad.rightTrigger.valueChangedHandler = { _, value, _ in
				_controls.value.rightTrigger = value
			}

			let mapControl: (GCControllerButtonInput, Controls.Buttons) -> Void = { button, control in
				button.valueChangedHandler = { _, _, pressed in
					_controls.modify { if pressed { $0.buttons.insert(control) } else { $0.buttons.remove(control) } }
				}
			}
			mapControl(gamepad.buttonA, .cross)
			mapControl(gamepad.buttonB, .circle)
			mapControl(gamepad.dpad.up, .up)
			mapControl(gamepad.dpad.down, .down)
			mapControl(gamepad.dpad.left, .left)
			mapControl(gamepad.dpad.right, .right)
			mapControl(gamepad.leftShoulder, .shiftLeft)
			mapControl(gamepad.rightShoulder, .shiftRight)
			mapControl(gamepad.buttonX, .square)
			mapControl(gamepad.buttonY, .triangle)
			mapControl(gamepad.buttonMenu, .scan)
		}

		lifetime = AnyCancellable { capture([observers, handlers]) }
	}
}
