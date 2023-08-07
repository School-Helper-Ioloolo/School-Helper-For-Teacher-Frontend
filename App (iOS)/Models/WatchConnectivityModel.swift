import Foundation
import WatchConnectivity

class WatchConnectivityModel: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityModel()
    
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let request = message["request"] as? String, request == "update" {
            WatchConnectivityModel.shared.session.sendMessage(
                [
                    "school": (try? JSONEncoder().encode(School.get() ?? School(code: -1, name: "", location: "")))!,
                    "teacher": (try? JSONEncoder().encode(Teacher.get() ?? Teacher(id: -1, name: "")))!
                ],
                replyHandler: nil)
        }
    }
}
