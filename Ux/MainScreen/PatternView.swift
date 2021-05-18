import SwiftUI
import Combine

struct PatternView: View {
	var pattern: Pattern
	var idx = nil as Int?

	var body: some View {
		VStack {
			ForEach(0..<pattern.rows, id: \.self) { row in
				HStack {
					ForEach(0..<pattern.cols, id: \.self) { col in
						Color(idx == row * 8 + col ? .cellSelected : pattern[row * 8 + col] ? .cellOn : .cellOff)
							.frame(width: 32, height: 32)
					}
				}
			}
		}
	}
}
