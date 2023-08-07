import SwiftUI

struct MainView: View {
    @ObservedObject private var model = WatchConnectivityModel.shared
    
    @State private var error: Error?
    
    var body: some View {
        NavigationView {
            VStack {
                if let error = error {
                    ErrorView(error: error)
                } else {
                    if let school = model.school, let teacher = model.teacher {
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(teacher.name)
                                    .font(.system(size: 24, weight: .bold))
                                
                                Text(school.name)
                                    .font(.system(size: 18, weight: .thin))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 10) {
                                NavigationLink(destination: TimeTableView(error: $error)) {
                                    Label(
                                        title: { Text("시간표") },
                                        icon: { Image(systemName: "calendar") }
                                    )
                                }
                                
                                NavigationLink(destination: MealView(error: $error)) {
                                    Label(
                                        title: { Text("급식") },
                                        icon: { Image(systemName: "fork.knife") }
                                    )
                                }

                            }
                        }
                    } else {
                        FirstSettingInfoView()
                    }
                }
            }
            .padding()
        }
    }
}
