import Foundation

struct OSStatusError: Error {
	var code: Int
}

extension OSStatusError {

	static func run(_ f: () -> OSStatus) throws {
		let val = f()
		if val != 0 { throw OSStatusError(code: Int(val)) }
	}

	static func run<A>(_ f: (UnsafeMutablePointer<A>) -> OSStatus) throws -> A {
		let ptr = UnsafeMutablePointer<A>.allocate(capacity: MemoryLayout<A>.size)
		defer { ptr.deallocate() }
		try run { f(ptr) }
		return ptr.pointee
	}
}

import SwiftUI

extension Color {
	static let base = Color.black
	static let bleDisconnected = Color(.sRGB, red: 0.1, green: 0.11, blue: 0.19, opacity: 1)
	static let controllerDisconnected = Color(.sRGB, red: 0.2, green: 0.11, blue: 0.13, opacity: 1)
	static let cellOff = Color(.sRGB, red: 0.28, green: 0.33, blue: 0.34, opacity: 0.8)
	static let cellOn = Color(.sRGB, red: 0.4, green: 0.56, blue: 0.63, opacity: 0.8)
	static let cellSelected = Color(.sRGB, red: 0.78, green: 0.73, blue: 0.67, opacity: 0.8)
	static let text = Color(.sRGB, red: 0.94, green: 0.96, blue: 0.99, opacity: 1)

	init(_ color: Color) {
		self = color
	}
}
