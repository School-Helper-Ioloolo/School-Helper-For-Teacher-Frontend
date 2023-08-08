import SwiftUI

struct MainView: View {
    @Environment(\.colorScheme) private var scheme
    
    @ObservedObject private var modalModel = ModalModel.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                ProfileCard()
                    .padding(.top, 15)
                    .background(ThemeColor.background(scheme: scheme))
                
                TabView {
                    ForEach(Pages.allCases, id: \.self) { page in
                        page.view()
                            .frame(width: geometry.size.width, height: geometry.size.height-150)
                            .background(ThemeColor.background(scheme: scheme))
                            .tabItem {
                                page.icon()
                                page.name()
                            }
                    }
                }
                .padding(.top, 115)
                
                if let safeModal = modalModel.get() {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                        
                        VStack {
                            safeModal
                                .padding()
                                .frame(width: geometry.size.width * 0.8)
                        }
                        .background(scheme == .light ? .white : ThemeColor.card(scheme: scheme))
                        .cornerRadius(20)
                        
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            if SettingModel.shared.school == nil || SettingModel.shared.teacher == nil {
                modalModel.showModal(SettingModal())
            }
            
            URLSession.shared.dataTask(with: URLRequest(url: URL(string: "https://teacher-plan.kro.kr/")!)) { data, response, error in
                if let error = error {
                    modalModel.showModal(ErrorModal(error: error))
                }
            }
            .resume()
        }
    }
}

private enum Pages: CaseIterable {
    case timetable, meal
    
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .timetable:
            TimeTableView()
        case .meal:
            MealView()
        }
    }
    
    @ViewBuilder
    func icon() -> some View {
        switch self {
            case .timetable:
                Image(systemName: "calendar")
            case .meal:
                Image(systemName: "fork.knife")
        }
    }
    
    @ViewBuilder
    func name() -> some View {
        switch self {
            case .timetable:
                Text("시간표")
            case .meal:
                Text("급식")
        }
    }
}
