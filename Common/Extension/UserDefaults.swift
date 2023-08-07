import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        let sharedSuiteName = "group.com.github.iolooloTeacher-Plan"
        
        if let sharedDefaults = UserDefaults(suiteName: sharedSuiteName) {
            return sharedDefaults
        } else {
            return UserDefaults.standard
        }
    }
}
