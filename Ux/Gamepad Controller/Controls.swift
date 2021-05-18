import Foundation

struct Controls {
	var leftStick = Thumbstick.zero
	var rightStick = Thumbstick.zero
	var leftTrigger = 0 as Float
	var rightTrigger = 0 as Float
	var buttons = [] as Buttons

	struct Buttons: OptionSet {
		var rawValue: Int16 = 0

		static let up = Buttons(rawValue: 1 << 0)
		static let down = Buttons(rawValue: 1 << 1)
		static let left = Buttons(rawValue: 1 << 2)
		static let right = Buttons(rawValue: 1 << 3)
		static let shiftLeft = Buttons(rawValue: 1 << 4)
		static let shiftRight = Buttons(rawValue: 1 << 5)
		static let cross = Buttons(rawValue: 1 << 6)
		static let circle = Buttons(rawValue: 1 << 7)
		static let square = Buttons(rawValue: 1 << 8)
		static let triangle = Buttons(rawValue: 1 << 9)
		static let scan = Buttons(rawValue: 1 << 10)

		static let dPad = Buttons([.up, .down, .left, .right])
	}

	struct Thumbstick {
		var x: Float
		var y: Float

		static let zero = Thumbstick(x: 0, y: 0)
	}
}

struct BLEControls: OptionSet {
	var rawValue: Int16 = 0

	static let run = BLEControls(rawValue: 1 << 0)
	static let reset = BLEControls(rawValue: 1 << 1)
	static let mute = BLEControls(rawValue: 1 << 2)
	static let changePattern = BLEControls(rawValue: 1 << 3)

	mutating func set(_ control: BLEControls, pressed: Bool) {
		if pressed { insert(control) } else { remove(control) }
	}
}

extension Controls.Buttons {
	var dPadDirection: Direction? {
		if contains(.up) { return .up }
		if contains(.right) { return .right }
		if contains(.down) { return .down }
		if contains(.left) { return .left }
		return .none
	}
}

extension LFO {
	init(stick: Controls.Thumbstick, trigger: Float) {
		self = LFO(
			offset: stick.x >= 0
				? UInt8(min(max(stick.x, 0), 1) * 255)
				: UInt8(min(max(-stick.x, 0), 1) * 255) & ~0x1F,
			am: UInt8(min(max(stick.y, 0), 1) * 255),
			fm: UInt8(min(max(trigger, 0), 1) * 255)
		)
	}
}

extension Controls {
	var lfoA: LFO { LFO(stick: leftStick, trigger: leftTrigger) }
	var lfoB: LFO { LFO(stick: rightStick, trigger: rightTrigger) }
}
