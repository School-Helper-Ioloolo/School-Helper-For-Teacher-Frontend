import WidgetKit
import SwiftUI

struct TimeTableProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimeTableWidgetEntry {
        TimeTableWidgetEntry(date: Date(), timetable: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (TimeTableWidgetEntry) -> ()) {
        let school = School(code: 0, name: "서울고등학교", location: "서울")
        let teacher = Teacher(id: 0, name: "홍길동")
        
        let timeTable = [
            PeriodTimeTable(period: 1, lecture: "국어", location: "1-1", modify: false),
            PeriodTimeTable(period: 2, lecture: "영어", location: "2-2", modify: true),
            PeriodTimeTable(period: 3, lecture: "수학", location: "3-3", modify: false)
        ]
        
        let entry = TimeTableWidgetEntry(date: Date(), school: school, teacher: teacher, timetable: timeTable)
        
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimeTableWidgetEntry>) -> ()) {
       var entries: [TimeTableWidgetEntry] = []

       let currentDate = Date()
        for _ in 0..<1 {
           let entryDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!

           let school = School.get()
           let teacher = Teacher.get()

           var timetable: [PeriodTimeTable] = []

           if let school = school, let teacher = teacher {
                let result = TimeTable.fetch(school: school, teacher: teacher)

                switch result {
                case .success(let fetchedTimetable):
                    timetable = TimeTable.get(timeTables: fetchedTimetable, dow: DayOfWeek.today())
                case .failure(_):
                    timetable = []
                }
            }
            
            let entry = TimeTableWidgetEntry(date: entryDate, school: school, teacher: teacher, timetable: timetable)
            
           entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        
        completion(timeline)
   }
}

struct TimeTableWidgetEntry: TimelineEntry {
    let date: Date
    var school: School?
    var teacher: Teacher?
    var timetable: [PeriodTimeTable]
}

struct TimeTableWidgetView: View {
    @Environment(\.colorScheme) var scheme
    @Environment(\.widgetFamily) var family
    
    var entry: TimeTableProvider.Entry
    
    var body: some View {
        if let school = entry.school, let teacher = entry.teacher {
            ZStack(alignment: .topLeading) {
                VStack {
                    if entry.timetable.isEmpty {
                        Text("수업이 없습니다.")
                            .font(.system(size: 14))
                    } else {
                        ForEach(entry.timetable) { detail in
                            VStack {
                                HStack(spacing: 0) {
                                    Text("\(detail.period)교시")
                                        .font(.system(size: 14, weight: .bold))
                                        .padding(.trailing, 10)
                                        .foregroundColor(detail.modify ? ThemeColor.yellowText(scheme: scheme) : .primary)
                                    
                                    Text(detail.lecture)
                                        .font(.system(size: 14))
                                        .foregroundColor(detail.modify ? ThemeColor.yellowText(scheme: scheme) : .primary)
                                    
                                    Text("(\(detail.location))")
                                        .font(.system(size: 13))
                                        .foregroundColor(detail.modify ? ThemeColor.yellowText(scheme: scheme) : .secondary)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                
                if family == .systemMedium {
                    VStack(alignment: .leading) {
                        Text(school.name)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                        
                        Text(teacher.name)
                            .font(.system(size: 18, weight: .bold))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .offset(x: 15, y: 15)
                }
            }
            .background(ThemeColor.background(scheme: scheme))
        } else {
            Text("앱을 실행 후 초기 설정을 진행해주세요")
                .font(.system(size: 14))
                .background(ThemeColor.background(scheme: scheme))
        }
    }
}

struct TimeTableWidget: Widget {
    private let kind: String = "TimeTableWidget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimeTableProvider()) { entry in
            TimeTableWidgetView(entry: entry)
        }
        .configurationDisplayName("시간표")
        .description("시간표")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
