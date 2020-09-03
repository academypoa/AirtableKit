import SwiftUI
import AirtableKit
import Combine
import URLImage


/// The applicaiton state
/// This examples requires that your Airtable base possesses the following fields
///
/// `name` : A single-line or multi-line text
/// `age` : An integer field
/// `isCool`: A checkbox field
/// `updatedTime`: A date field
/// `image`: An attachment field
///
final class AppState: ObservableObject, Equatable {
    
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        lhs.name == rhs.name &&
        lhs.age == rhs.age &&
        lhs.isCool == rhs.isCool &&
        lhs.createdTime == rhs.createdTime &&
        lhs.updatedTime == rhs.updatedTime &&
        lhs.imageUrl == rhs.imageUrl
    }
    
    @Published var name: String = "Nicolas"
    @Published var age: Int = 25
    @Published var isCool: Bool = false
    @Published var createdTime: Date = Date()
    @Published var updatedTime: Date = Date()
    @Published var imageUrl: URL = URL(string: "https://placehold.it/300")!
}

extension AppState {
    static let happyUrlStringUrl = "https://www.treehugger.com/thmb/4ahsE_-KAyHY9GFQdwVvny0_SaA=/735x0/__opt__aboutcom__coeus__resources__content_migration__mnn__images__2013__09__bigbabysmileonetooth-7f0e2c7898c54124a6a3472938177a95.jpg"
    static let sadUrlStringUrl = "https://minutohm.files.wordpress.com/2013/11/sad-baby.jpg?w=604"
    static let placeholderStringUrl = "https://placehold.it/300"
}

struct ContentView: View {
    
    // MARK: - Private
    
    /// Generate this at https://api.airtable.com
    private let apiKey = "YOUR_API_KEEY"
    
    /// The id of the base in Airtable
    private let apiBaseId = "YOUR_BASE_ID"
    
    /// The name of the table
    private let tableName: String = "YOUR_TABLE_NAME"
    
    /// The subscriptions of this view
    @State private var subscriptions: Set<AnyCancellable> = []
        
    /// The Airtable Record
    @State private var record: AirtableKit.Record? = nil
    
    /// A boolean indicating whether there are changes to send to airtable
    @State private var loadedState = AppState()
    
    // MARK: - State
    @ObservedObject var state = AppState()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("My name is")
                    
                    VStack(spacing: 0) {
                        TextField("name", text: self.$state.name)
                        Divider()
                    }
                }.font(.title)
                
                HStack {
                    Text("I am")
                    
                    VStack(spacing: 0) {
                        TextField("age",
                                  text: Binding(
                                    get: { String(self.state.age) },
                                    set: { if let value = Int($0) { self.state.age = value } }
                            )
                        )
                        Divider()
                    }
                    Spacer()
                    
                    Text("year\(self.state.age != 1 ? "s" : "") old")
                }
                .font(.title)

                
                HStack {
                    Toggle("Am I cool?", isOn: self.$state.isCool)
                }
                
                URLImage(state.imageUrl) { proxy in
                    proxy.image
                        .resizable()
                        .scaledToFit()
                        .clipped()
                }.frame(width: nil, height: UIScreen.main.bounds.size.height*0.5)
                
                Spacer()
                
                Text("Airtable updated time \n\(self.state.updatedTime)")
                    .font(.system(size: 9, weight: .regular))
                
                Text("Airtable created time \n\(self.state.createdTime)")
                    .font(.system(size: 9, weight: .regular))
            }
            .padding()
            .navigationBarTitle("Example")
            .navigationBarItems(
                trailing: Button(action: updateInAirtable) {
                    Text("Send to Airtable")
                }.disabled(state != loadedState)
            )
        }
        .onAppear(perform: loadItems)
    }
    
    private func updateInAirtable() {
        guard var record = self.record else { return }
        let airtable = Airtable(baseID: apiBaseId, apiKey: apiKey)
        record.fields["name"] = state.name
        record.fields["isCool"] = state.isCool
        record.fields["age"] = state.age
        record.fields["updatedTime"] = Date()
        let urlString = state.isCool ? AppState.happyUrlStringUrl : AppState.sadUrlStringUrl
        record.attachments["image"] = [.init(url: URL(string: urlString)!)]
        
        airtable.update(tableName: tableName, record: record)
            .flatMap{ _ in airtable.list(tableName: self.tableName) }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { records in
                if let record = records.first {
                    self.record = record
                    self.update(with: record)
                }
            }.store(in: &subscriptions)
        
    }
    private func loadItems() {
        let airtable = Airtable(baseID: apiBaseId, apiKey: apiKey)
        airtable
            .list(tableName: tableName, fields: ["name", "age", "image", "updatedTime", "isCool"])
            .print()
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { records in
                if let record = records.first {
                    self.record = record
                    self.update(with: record)
                }
        }.store(in: &subscriptions)
    }
    
    private func update(with record: AirtableKit.Record) {
        self.state.name = record.fields["name"] as? String ?? ""
        self.state.age = record.fields["age"] as? Int ?? 0
        self.state.isCool = record.fields["isCool"] as? Bool ?? false
        self.state.createdTime = record.createdTime ?? Date()
        self.state.updatedTime = record.fields["updatedTime"] as? Date ?? Date()
        self.state.imageUrl = record.attachments["image"]?.first?.url ?? URL(string: AppState.placeholderStringUrl)!
        self.loadedState = self.state
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
