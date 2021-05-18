import Foundation
import Fx

extension IO where A: Codable {
	static func store(defaults: UserDefaults = .standard, key: String, fallback: @escaping @autoclosure () -> A) -> IO {
		IO(
			get: {
				defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(A.self, from: $0) } ?? fallback()
			},
			set: { newValue in
				defaults.setValue(try? JSONEncoder().encode(newValue), forKey: key)
			}
		)
	}
}

struct StoredState: Codable {
	var bpm: Float
	var pattern: Pattern
}

extension StoredState {
	static let initial = StoredState(bpm: 120, pattern: .empty)

	var state: Model.State {
		get { Model.State(bpm: bpm, pattern: pattern) }
		set { bpm = newValue.bpm; pattern = newValue.pattern }
	}
}
