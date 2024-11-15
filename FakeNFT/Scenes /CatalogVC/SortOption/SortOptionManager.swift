


import Foundation

enum SortOption: String {
    case none
    case byName
    case byCount
}

final class SortOptionManager {
    private let key = "currentSortOption"
    
    func save(_ option: SortOption) {
        UserDefaults.standard.set(option.rawValue, forKey: key)
    }
    
    func load() -> SortOption {
        guard let rawValue = UserDefaults.standard.string(forKey: key) else {
            return .none
        }
        return SortOption(rawValue: rawValue) ?? .none
    }
}
