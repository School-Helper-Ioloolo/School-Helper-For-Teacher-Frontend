import Foundation

class SettingModel: ObservableObject {
    static let shared = SettingModel()
    
    @Published var school: School? {
        didSet {
            School.set(school: school)
            
            WatchConnectivityModel.shared.session.sendMessage(
                [
                    "school": (try? JSONEncoder().encode(school ?? School(code: -1, name: "", location: "")))!,
                    "teacher": (try? JSONEncoder().encode(teacher ?? Teacher(id: -1, name: "")))!
                ],
                replyHandler: nil)
        }
    }
    
    @Published var teacher: Teacher? {
        didSet {
            Teacher.set(teacher: teacher)
            
            WatchConnectivityModel.shared.session.sendMessage(
                [
                    "school": (try? JSONEncoder().encode(school ?? School(code: -1, name: "", location: "")))!,
                    "teacher": (try? JSONEncoder().encode(teacher ?? Teacher(id: -1, name: "")))!
                ],
                replyHandler: nil)
        }
    }
    
    init() {
        self.school = School.get()
        self.teacher = Teacher.get()
    }
}
