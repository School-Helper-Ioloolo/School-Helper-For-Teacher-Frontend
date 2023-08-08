import SwiftUI

enum NoUsed: Error {
    case error
}

struct PeriodTimeTable: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    
    let period: Int
    let lecture: String
    let location: String
    let modify: Bool
    
    enum CodingKeys: CodingKey {
        case period
        case lecture
        case location
        case modify
    }
}

struct TimeTable: Codable, Identifiable {
    var id: UUID = UUID()
    
    let dayOfWeek: String
    let timeTable: [PeriodTimeTable]
    
    enum CodingKeys: CodingKey {
        case dayOfWeek
        case timeTable
    }
    

    static func get(timeTables: [TimeTable], dow: DayOfWeek) -> [PeriodTimeTable] {
        let timeTable = timeTables.first { $0.dayOfWeek == dow.upper() }
        
        if let timeTable = timeTable {
            return timeTable.timeTable
        } else {
            return []
        }
    }
    
    static func fetch(school: School, teacher: Teacher, isFetch: Binding<Bool>?, result: Binding<[TimeTable]>, onError: @escaping (Error) -> Void) {
        
        let url = URL(string: "https://teacher-plan.kro.kr/api/timetable/timetable")!
        let bodyData = ["school": school.code, "teacher": teacher.id]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: bodyData) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        isFetch?.wrappedValue = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    isFetch?.wrappedValue = false
                }
            }
            
            if let error = error {
                onError(error)
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let timetable = try JSONDecoder().decode([TimeTable].self, from: data)
                DispatchQueue.main.async {
                    result.wrappedValue = timetable
                }
            } catch {
                onError(error)
            }
        }
        .resume()
    }
    
    static func fetch(school: School, teacher: Teacher) -> Result<[TimeTable], Error> {
        let url = URL(string: "https://teacher-plan.kro.kr/api/timetable/timetable")!
        let bodyData = ["school": school.code, "teacher": teacher.id]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: bodyData) else {
            return .failure(NoUsed.error)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var result: Result<[TimeTable], Error>!

        let semaphore = DispatchSemaphore(value: 0)

        URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                semaphore.signal()
            }

            if let error = error {
                result = .failure(error)
                return
            }

            guard let data = data else {
                result = .failure(NoUsed.error)
                return
            }

            do {
                let timetable = try JSONDecoder().decode([TimeTable].self, from: data)
                result = .success(timetable)
            } catch {
                result = .failure(error)
            }
        }.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return result
    }
}
