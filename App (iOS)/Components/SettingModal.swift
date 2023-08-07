import SwiftUI
import WidgetKit

private enum SettingType {
    case main, school, teacher
    
    func title() -> String {
        switch self {
        case .main:
            return "설정"
        case .school:
            return "학교 검색"
        case .teacher:
            return "교사 선택"
        }
    }
}

struct SettingModal: View {
    @State private var settingType: SettingType = .main
    
    @State private var results: [Teacher] = []
    @State private var isFetching = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack(alignment: .topTrailing) {
                VStack {
                    Text(settingType.title())
                        .font(.system(size: 28, weight: .semibold))
                        .padding()
                    
                    if settingType == .main {
                        SettingMainView(settingType: $settingType)
                    } else if settingType == .school {
                        SettingSchoolView(settingType: $settingType)
                    } else if settingType == .teacher {
                        SettingTeacherView(settingType: $settingType)
                    }
                }

                if settingType == .main {
                    Button(action: {
                        if SettingModel.shared.school != nil && SettingModel.shared.teacher != nil {
                            ModalModel.shared.close()
                        }
                    }) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                    }
                    .offset(x: -5, y: 20)
                }
            }
            
            if settingType != .main {
                Button(action: {
                    DispatchQueue.main.async {
                        self.settingType = .main
                    }
                }) {
                    Image(systemName: "arrow.backward.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                }
                .offset(x: 5, y: 20)
            }
        }
    }
}

private struct SettingMainView: View {
    @ObservedObject private var settingModel = SettingModel.shared
    
    @Binding var settingType: SettingType
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("학교")
                        .font(.system(size: 22, weight: .semibold))
                    
                    Text(settingModel.school?.name ?? "(없음)")
                        .font(.system(size: 15))
                }
                
                Spacer()
                
                Button(action: {
                    settingType = .school
                }) {
                    HStack {
                        Text("변경")
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 7)
                    .foregroundColor(.white)
                    .background(.blue)
                    .cornerRadius(30)
                }
            }
            .padding()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("교사")
                        .font(.system(size: 22, weight: .semibold))
                    
                    Text(settingModel.teacher?.name ?? "(없음)")
                        .font(.system(size: 15))
                }
                
                Spacer()
                
                Button(action: {
                    settingType = .teacher
                }) {
                    HStack {
                        Text("변경")
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 7)
                    .foregroundColor(.white)
                    .background(settingModel.school == nil ? .gray : .blue)
                    .cornerRadius(30)
                }
                .disabled(settingModel.school == nil)
            }
            .padding()
        }
        .frame(height: 150)
    }
}

private struct SettingSchoolView: View {
    @State private var searchText: String = ""
    @State private var searchResults: [School] = []
    
    @Binding var settingType: SettingType

    var body: some View {
        VStack{
            TextField("학교 이름", text: $searchText)
                .font(.system(size: 16, design: .default))
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(20)
                .onChange(of: searchText) { _ in
                    School.fetch(
                        searchText: searchText,
                        result: $searchResults,
                        onError: { error in
                            ModalModel.shared.showModal(ErrorModal(error: error))
                        }
                    )
                }

            ScrollView {
                VStack {
                    ForEach(Array(searchResults.sorted { $0.name < $1.name }.enumerated()), id: \.element) { index, school in
                        VStack(alignment: .leading) {
                            Text(school.name)
                                .font(.system(size: 16))
                            
                            Text(school.location)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.clear)
                        .onTapGesture {
                            SettingModel.shared.school = school
                            SettingModel.shared.teacher = nil
                            settingType = .main
                            
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                        
                        if index != searchResults.count - 1 {
                            Divider()
                        }
                    }
                }
            }
            .padding()
            .frame(maxHeight: 250)
        }
    }
}

private struct SettingTeacherView: View {
    @State private var results: [Teacher] = []
    
    @Binding var settingType: SettingType

    var body: some View {
        ScrollView {
            VStack {
                ForEach(Array(results.sorted { $0.name < $1.name }.enumerated()), id: \.element) { index, teacher in
                    VStack(alignment: .leading) {
                        Text(teacher.name)
                            .font(.system(size: 15))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.clear)
                    .onTapGesture {
                        SettingModel.shared.teacher = teacher
                        settingType = .main
                        
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    
                    if index != results.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        .frame(height: 200)
        .onAppear {
            Teacher.fetch(
                school: SettingModel.shared.school!,
                result: $results,
                onError: { error in
                    ModalModel.shared.showModal(ErrorModal(error: error))
                })
        }
    }
}
