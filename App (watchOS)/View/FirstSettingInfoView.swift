import SwiftUI

struct FirstSettingInfoView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.circle")
                .font(.system(size: 42))
                .padding(.bottom, 10)
            
            Text("핸드폰에서 설정을 해주세요.")
                .font(.system(size: 15))
            
            ProgressView()
        }
    }
}
