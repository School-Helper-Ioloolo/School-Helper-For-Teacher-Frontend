import SwiftUI

enum MealType: String, Codable, CaseIterable {
    case breakfast = "조식"
    case lunch = "중식"
    case dinner = "석식"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "조식":
            self = .breakfast
        case "중식":
            self = .lunch
        case "석식":
            self = .dinner
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid meal type value")
        }
    }
}

struct Meal: Codable, Hashable, Identifiable {
    let id: UUID = UUID()
    let type: MealType
    let menu : [String]
    
    enum CodingKeys: String, CodingKey {
        case type
        case menu
    }
    
    static func fetch(school: School, isFetch: Binding<Bool>?, result: Binding<[Meal]>, onError: @escaping (Error) -> Void) {
        let url = URL(string: "https://teacher-plan.kro.kr/api/meal")!
        let bodyData = ["name": school.name, "location": school.location]
        
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
                let schools = try JSONDecoder().decode([Meal].self, from: data)
                DispatchQueue.main.async {
                    result.wrappedValue = schools
                }
            } catch {
                onError(error)
            }
        }
        .resume()
    }
    
    static func fetch(school: School) -> Result<[Meal], Error> {
        let url = URL(string: "https://teacher-plan.kro.kr/api/meal")!
        let bodyData = ["name": school.name, "location": school.location]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: bodyData) else {
            return .failure(NoUsed.error)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var result: Result<[Meal], Error>!

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
                let meal = try JSONDecoder().decode([Meal].self, from: data)
                result = .success(meal)
            } catch {
                result = .failure(error)
            }
        }.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return result
    }
}
