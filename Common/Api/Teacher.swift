import SwiftUI

struct Teacher: Codable, Hashable {
    let id: Int
    let name: String
    
    static func get() -> Teacher? {
        guard let encodedData = UserDefaults.shared.data(forKey: "teacher") else {
            return nil
        }
        
        return try? JSONDecoder().decode(Teacher.self, from: encodedData)
    }
    
    static func set(teacher: Teacher?) {
        if let encodedData = try? JSONEncoder().encode(teacher) {
            UserDefaults.shared.set(encodedData, forKey: "teacher")
        } else {
            UserDefaults.shared.removeObject(forKey: "teacher")
        }
    }
    
    static func fetch(school: School, result: Binding<[Teacher]>, onError: @escaping (Error) -> Void) {
        let url = URL(string: "https://shtapi.sondaehyeon.kro.kr/api/timetable/teachers")!
        let bodyData = ["school": school.code]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: bodyData) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                onError(error)
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let teachers = try JSONDecoder().decode([Teacher].self, from: data)
                DispatchQueue.main.async {
                    result.wrappedValue = teachers
                }
            } catch {
                onError(error)
            }
        }
        .resume()
    }
}

