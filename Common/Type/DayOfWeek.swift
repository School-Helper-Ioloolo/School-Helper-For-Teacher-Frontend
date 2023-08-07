import Foundation

enum DayOfWeek: CaseIterable, Hashable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    
    static func today() -> DayOfWeek {
        let weekday = Calendar.current.component(.weekday, from: Date())
        
        switch (weekday) {
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        default: return .monday
        }
    }
    
    func upper() -> String {
        switch self {
        case .monday:
            return "MONDAY";
        case .tuesday:
            return "TUESDAY";
        case .wednesday:
            return "WEDNESDAY";
        case .thursday:
            return "THURSDAY";
        case .friday:
            return "FRIDAY";
        }
    }
    
    func text() -> String {
        switch self {
        case .monday:
            return "월";
        case .tuesday:
            return "화";
        case .wednesday:
            return "수";
        case .thursday:
            return "목";
        case .friday:
            return "금";
        }
    }
}
