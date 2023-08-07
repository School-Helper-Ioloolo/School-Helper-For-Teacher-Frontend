import SwiftUI

struct ErrorView: View {
    var error: Error
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 42))
            
            Text("오류가 발생했습니다.")
                .font(.system(size: 18))
                .padding(.top, 5)
            
            Divider()
                .padding(.vertical, 10)
            
            Text(error.localizedDescription)
                .font(.system(size: 16))
        }
    }
}
