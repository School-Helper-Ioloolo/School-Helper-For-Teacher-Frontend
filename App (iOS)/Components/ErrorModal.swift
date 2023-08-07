import SwiftUI

struct ErrorModal: View {
    var error: Error
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 10) {
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("오류가 발생했습니다.")
                    .font(.system(size: 24))
                
                Divider()
                    .padding(.vertical, 20)
                
                Text(error.localizedDescription)
                    .font(.system(size: 18))
            }
            .padding(.vertical, 15)
            
            Button(action: {
                ModalModel.shared.close()
            }) {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
            }
            .offset(x: -5, y: 5)
        }
    }
}
