import Foundation

func date(day: Int, month: Int, year: Int, hour: Int, minute: Int, second: Int) -> Date? {
    var components = DateComponents()
    
    components.day = day
    components.month = month
    components.year = year
    components.hour = hour
    components.minute = minute
    components.second = second
    
    return Calendar.current.date(from: components)!
}

func readFile(_ resource: String) -> Data {
    let components = resource.components(separatedBy: ".")
    let name = components.dropLast().joined(separator: ".")
    let ext = components.last
    
    guard let url = Bundle.module.url(forResource: "Resources/\(name)", withExtension: ext) else {
        fatalError("Unknown resource: \(resource)")
    }
    
    do {
        return try Data(contentsOf: url)
    } catch {
        fatalError("Failed to read data for resource at \(url)")
    }
}
