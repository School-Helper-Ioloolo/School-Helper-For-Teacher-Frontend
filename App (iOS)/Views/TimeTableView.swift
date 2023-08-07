import SwiftUI

struct TimeTableView: View {
    @ObservedObject private var settingModel = SettingModel.shared
    
    @State private var timeTables: [TimeTable] = []
    @State private var isFetch: Bool = true

    var body: some View {
        VStack {
            if settingModel.teacher != nil {
                VStack {
                    if isFetch {
                        ProgressView()
                    } else {
                        VStack(spacing: 5) {
                            HStack(spacing: 5) {
                                Text("")
                                    .frame(width: 15, alignment: .leading)
                                
                                ForEach(DayOfWeek.allCases, id: \.self) { day in
                                    Text(day.text())
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .frame(width: 60, height: 15, alignment: .center)
                                }
                            }
                            .frame(height: 15)
                            
                            ForEach(1...7, id: \.self) { period in
                                HStack(spacing: 5) {
                                    Text("\(period)")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.primary)
                                        .frame(width: 15, height: 50)
                                    
                                    ForEach(DayOfWeek.allCases, id: \.self) { day in
                                        let timeTable = TimeTable.get(timeTables: timeTables, dow: day)
                                        if let table = timeTable.first(where: { $0.period == period }) {
                                            PeriodView(timeTable: table)
                                        } else {
                                            PeriodView(timeTable: PeriodTimeTable(period: period, lecture: "", location: "", modify: false))
                                        }
                                    }
                                }
                                .frame(height: 20)
                            }
                            .padding()
                        }
                    }
                }
                .onAppear {
                    fetch()
                }
                .onChange(of: settingModel.teacher) { _ in
                    fetch()
                }
            }
        }
    }
    
    private func fetch() {
        if let school = settingModel.school, let teacher = settingModel.teacher {
            TimeTable.fetch(school: school, teacher: teacher, isFetch: $isFetch, result: $timeTables) { error in
                ModalModel.shared.showModal(ErrorModal(error: error))
            }
        }
    }
}

struct PeriodView: View {
    @Environment(\.colorScheme) private var scheme
    
    let timeTable: PeriodTimeTable

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text(timeTable.lecture.isEmpty ? "" : timeTable.lecture)
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.primary)
                
                Text(timeTable.location.isEmpty ? "" : timeTable.location)
                    .font(.system(size: 12))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .frame(minWidth: 60, idealWidth: 60, maxWidth: 60, minHeight: 50, idealHeight: 50, maxHeight: 50)
        .background(ThemeColor.cell(scheme: scheme, highlight: timeTable.modify))
        .cornerRadius(10)
    }
}
