import SwiftUI

struct TimeTableView: View {
    @ObservedObject private var model = WatchConnectivityModel.shared
    
    @State private var hour = Calendar.current.component(.hour, from: Date())
    
    @State private var timeTables: [TimeTable] = []
    @State private var isFetch: Bool = true
    
    @Binding var error: Error?
    
    var body: some View {
        VStack {
            if isFetch {
                ProgressView()
            } else {
                if let todayTable = timeTables.first(where: { $0.dayOfWeek == DayOfWeek.today().upper() }) {
                    ScrollView(showsIndicators: false) {
                        ForEach(1...7, id: \.self) { period in
                            let timeTable = todayTable.timeTable.first(where: { $0.period == period })
                            
                            HStack {
                                HStack(spacing: 0) {
                                    Text("\(period)교시")
                                        .font(.system(size: 14, weight: .semibold))
                                    
                                    Text("-")
                                        .font(.system(size: 14))
                                        .padding(.horizontal, 5)
                                    
                                    if let timeTable = timeTable {
                                        Text(timeTable.lecture)
                                            .font(.system(size: 14, weight: .regular))
                                        
                                        Text("(\(timeTable.location))")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(timeTable.modify ? Color(hex: 0xffffab) : .secondary)
                                    } else {
                                        Text("(없음)")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(timeTable?.modify ?? false ? Color(hex: 0xffffab) : .secondary)
                                    }
                                }
                                .foregroundColor(timeTable?.modify ?? false ? Color(hex: 0xffffab) : nil)
                                .padding()
                                
                                Spacer()
                            }
                            .background(Color(hex: 0x1c1c1c))
                            .cornerRadius(15)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                        }
                    }
                } else {
                    Text("수업이 없습니다.")
                        .font(.system(size: 18))
                }
            }
        }
        .navigationTitle("시간표")
        .onAppear {
            fetch()
        }
        .onChange(of: model.teacher) { _ in
            fetch()
        }
    }
    
    private func fetch() {
        if let school = model.school, let teacher = model.teacher {
            TimeTable.fetch(school: school, teacher: teacher, isFetch: $isFetch, result: $timeTables) { error in
                self.error = error
            }
        }
    }
}
