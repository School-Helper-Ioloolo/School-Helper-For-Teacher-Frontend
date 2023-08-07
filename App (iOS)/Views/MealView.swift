import SwiftUI
    
struct MealView: View {
    @Environment(\.colorScheme) var scheme
    
    @ObservedObject var settingModel = SettingModel.shared
    
    @State private var meals: [Meal] = []
    @State private var isFetch: Bool = true
    
    var body: some View {
        VStack {
            if isFetch {
                ProgressView()
            } else {
                GeometryReader { geometry in
                    ScrollView(showsIndicators: false) {
                        VStack {
                            ForEach(meals, id: \.type) { meal in
                                HStack {
                                    Spacer()
                                    
                                    VStack {
                                        Text(meal.type.rawValue)
                                            .font(.system(size: 20, weight: .bold))
                                            .padding(.bottom, 5)
                                        
                                        ForEach(meal.menu, id: \.self) { item in
                                            Text(item)
                                                .font(.system(size: 15, weight: .regular))
                                        }
                                    }
                                    .frame(width: geometry.size.width*0.7)
                                    .padding()
                                    .background(ThemeColor.card(scheme: scheme))
                                    .cornerRadius(20)
                                    .shadow(radius: 5, x: 2, y: 2)
                                    
                                    Spacer()
                                }
                                .frame(width: geometry.size.width)
                                .padding(.top, 15)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .onAppear {
            fetch()
        }
        .onChange(of: settingModel.school) { _ in
            fetch()
        }
    }
    
    private func fetch() {
        if let school = settingModel.school {
            Meal.fetch(school: school, isFetch: $isFetch, result: $meals) { error in
                ModalModel.shared.showModal(ErrorModal(error: error))
            }
        }
    }
}

