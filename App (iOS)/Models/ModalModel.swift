import SwiftUI

class ModalModel: ObservableObject {
    static let shared = ModalModel()
    
    @Published private var modal: (AnyView)? = nil
    
    func showModal<Content: View>(_ content: Content) {
        DispatchQueue.main.async {
            self.modal = AnyView(content)
        }
    }
    
    func close() {
        modal = nil
    }
    
    func get() -> (AnyView)? {
        return self.modal
    }
}
