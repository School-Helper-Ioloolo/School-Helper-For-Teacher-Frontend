import SwiftUI

struct ProfileCard: View {
    @Environment(\.colorScheme) private var scheme
    
    @ObservedObject private var settingModel = SettingModel.shared
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                
                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            if let teacher = settingModel.teacher, let school = settingModel.school {
                                Text(teacher.name)
                                    .font(.system(size: 26, weight: .bold))
                                
                                Text(school.name)
                                    .font(.system(size: 14, weight: .thin))
                                    .foregroundColor(.secondary)
                            } else {
                                Text("설정을 해주세요.")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                        }
                        .padding(.leading, 20)
                    }
                    .frame(width: geometry.size.width * 0.8, height: 85, alignment: .leading)
                    .background(ThemeColor.card(scheme: scheme))
                    .cornerRadius(20)
                    .shadow(radius: 5, x: 2, y: 2)
                    
                    Button(action: {
                        ModalModel.shared.showModal(SettingModal())
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 24))
                    }
                    .offset(x: -20, y: 15)
                }
                
                Spacer()
            }
        }
    }
}
