import SwiftUI

struct MealView: View {
    @ObservedObject private var model = WatchConnectivityModel.shared
    
    @State private var hour = Calendar.current.component(.hour, from: Date())
    
    @State private var meals: [Meal] = []
    @State private var isFetch: Bool = true
    @State private var index: MealType = .lunch
    
    @Binding var error: Error?
    
    var body: some View {
        VStack {
            if isFetch {
                ProgressView()
            } else if meals.isEmpty {
                Text("급식이 없습니다.")
                    .font(.system(size: 18))
            } else {
                TabView(selection: $index) {
                    ForEach(MealType.allCases, id: \.self) { type in
                        if let meal = meals.first(where: { $0.type == type }) {
                            ScrollView(showsIndicators: false) {
                                VStack {
                                    ForEach(meal.menu, id: \.self) { menu in
                                        Text(menu)
                                    }
                                }
                            }
                            .tag(type)
                            .navigationTitle(type.rawValue)
                        }
                    }
                }
            }
        }
        .onAppear {
            fetch()
        }
        .onChange(of: model.teacher) { _ in
            fetch()
        }
        .onChange(of: meals) { _ in
            if hour < 9 && meals.contains(where: { $0.type == .breakfast }) {
                self.index = .breakfast
            } else if hour >= 9 && hour < 15 && meals.contains(where: { $0.type == .lunch }) {
                self.index = .lunch
            }  else if hour >= 15 && meals.contains(where: { $0.type == .dinner }) {
                self.index = .dinner
            } else {
                self.index = meals.first?.type ?? .lunch
            }
        }
    }
    
    private func fetch() {
        if let school = model.school {
            Meal.fetch(school: school, isFetch: $isFetch, result: $meals) { error in
                self.error = error
            }
        }
    }
}
