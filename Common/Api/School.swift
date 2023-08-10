import SwiftUI

struct School: Codable, Hashable {
    let id: UUID = UUID()
    let code: Int
    let name: String
    let location: String
    
    static var uuid: UUID = UUID()
    
    enum CodingKeys: String, CodingKey {
        case code
        case name
        case location
    }
    
    static func get() -> School? {
        guard let encodedData = UserDefaults.shared.data(forKey: "school") else {
            return nil
        }
        
        return try? JSONDecoder().decode(School.self, from: encodedData)
    }
    
    static func set(school: School?) {
        if let encodedData = try? JSONEncoder().encode(school) {
            UserDefaults.shared.set(encodedData, forKey: "school")
        } else {
            UserDefaults.shared.removeObject(forKey: "school")
        }
    }
    
    static func fetch(searchText: String, uuid: UUID, result: Binding<[School]>, onError: @escaping (Error) -> Void) {
        if searchText.isEmpty {
            return
        }
        
        let url = URL(string: "https://teacher-plan.kro.kr/api/timetable/school")!
        let bodyData = ["query": searchText]
        
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
                let schools = try JSONDecoder().decode([School].self, from: data)
           
                if School.uuid == uuid {
                    DispatchQueue.main.async {
                        result.wrappedValue = schools
                    }
                }
            } catch {
                onError(error)
            }
        }
        .resume()
    }
}
