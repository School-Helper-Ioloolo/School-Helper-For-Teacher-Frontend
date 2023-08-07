import Foundation
import WatchConnectivity

class WatchConnectivityModel: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchConnectivityModel()
    
    var session: WCSession
    
    @Published var school: School? {
        didSet {
            School.set(school: school)
        }
    }
    
    @Published var teacher: Teacher? {
        didSet {
            Teacher.set(teacher: teacher)
        }
    }
    
    init(session: WCSession = .default) {
        self.school = School.get()
        self.teacher = Teacher.get()
        
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            session.sendMessage(["req": "update"], replyHandler: nil)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let schoolJson = message["school"] as? Data,
           let teacherJson = message["teacher"] as? Data {
            
            DispatchQueue.main.async {
                self.school = try? JSONDecoder().decode(School.self, from: schoolJson)
                if self.school?.code == -1 {
                    self.school = nil
                }
                
                self.teacher = try? JSONDecoder().decode(Teacher.self, from: teacherJson)
                if self.teacher?.id == -1 {
                    self.teacher = nil
                }
            }
        }
    }
}
