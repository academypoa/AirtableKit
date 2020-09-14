import SwiftUI
import AirtableKit
import Combine
import URLImage


/// This examples requires that your Airtable base possesses the following fields
///
/// `name` : A single-line or multi-line text
/// `age` : An integer field
/// `isCool`: A checkbox field
/// `updatedTime`: A date field
/// `image`: An attachment field
///
///  Check the `base-setup.png` file to see how the table should appear in Airtable.
///
///
/// The applicaiton state
final class AppState: ObservableObject, Equatable {
    
    @Published var name: String = "Nicolas"
    @Published var age: Int = 25
    @Published var isCool: Bool = false
    @Published var createdTime: Date = Date()
    @Published var updatedTime: Date = Date()
    @Published var imageUrl: URL = URL(string: "https://placehold.it/300")!
    
    // MARK: - Equatable
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        lhs.name == rhs.name &&
            lhs.age == rhs.age &&
            lhs.isCool == rhs.isCool &&
            lhs.createdTime == rhs.createdTime &&
            lhs.updatedTime == rhs.updatedTime &&
            lhs.imageUrl == rhs.imageUrl
    }
}

extension AppState {
    // Standard URLs
    static let happyUrlStringUrl = "https://www.treehugger.com/thmb/4ahsE_-KAyHY9GFQdwVvny0_SaA=/735x0/__opt__aboutcom__coeus__resources__content_migration__mnn__images__2013__09__bigbabysmileonetooth-7f0e2c7898c54124a6a3472938177a95.jpg"
    static let sadUrlStringUrl = "https://minutohm.files.wordpress.com/2013/11/sad-baby.jpg?w=604"
    static let placeholderStringUrl = "https://placehold.it/300"
}

struct ContentView: View {
    
    // MARK: - Private
    
    /// Generate this at https://api.airtable.com
    private let apiKey = "API_KEY"
    
    /// The id of the base in Airtable
    private let apiBaseId = "BASE_ID"
    
    /// The name of the table
    private let tableName: String = "TABLE_NAME"
    
    /// The subscriptions of this view
    @State
    private var subscriptions: Set<AnyCancellable> = []
    
    /// The Airtable Record
    @State
    private var record: AirtableKit.Record? = nil
    
    // MARK: - State
    @ObservedObject
    private var state = AppState()
    
    /// The airtable base we will be accessing
    private var airtable: Airtable
    
    // MARK: - Init
    init() { self.airtable = Airtable(baseID: apiBaseId, apiKey: apiKey) }
    
    // MARK: - Body
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
                    .font(.system(size: 10, weight: .regular))
                
                Text("Airtable created time \n\(self.state.createdTime)")
                    .font(.system(size: 10, weight: .regular))
            }
            .padding()
            .navigationBarTitle("Example")
            .navigationBarItems(
                trailing: Button(action: updateInAirtable) { Text("Send to Airtable") }
            )
        }
        .onAppear(perform: loadItems)
    }
    
    /// A publisher that lists the items from Airtable
    private var listFromAirtablePublisher: AnyPublisher<AirtableKit.Record, AirtableError> {
        airtable
            .list(tableName: tableName, fields: ["name", "age", "image", "updatedTime", "isCool"])
            .receive(on: DispatchQueue.main)
            .compactMap(\.first)
            .eraseToAnyPublisher()
    }
    
    /// Sends local data to Airtable
    private func updateInAirtable() {
        guard var record = self.record else { return }
        record.fields["name"] = state.name
        record.fields["isCool"] = state.isCool
        record.fields["age"] = state.age
        record.fields["updatedTime"] = Date()
        let urlString = state.isCool ? AppState.happyUrlStringUrl : AppState.sadUrlStringUrl
        record.attachments["image"] = [.init(url: URL(string: urlString)!)]
        
        airtable.update(tableName: tableName, record: record)
            .flatMap{ _ in self.listFromAirtablePublisher }
            .replaceError(with: .init(fields: [:]))
            .sink(receiveValue: update(with:))
            .store(in: &subscriptions)
        
    }
    
    /// Loads the items stored in Airtable
    private func loadItems() {
        self.listFromAirtablePublisher
            .replaceError(with: .init(fields: [:]))
            .sink(receiveValue: update(with:))
            .store(in: &subscriptions)
    }
    
    /// Updates local state using the provided Record
    /// - Parameter record: The record from which to get the data
    private func update(with record: AirtableKit.Record) {
        self.record = record
        self.state.name = record.name ?? ""
        self.state.age = record.age ?? 0
        self.state.isCool = record.isCool ?? false
        self.state.createdTime = record.createdTime ?? Date()
        self.state.updatedTime = record.updatedTime ?? Date()
        self.state.imageUrl = record.attachments["image"]?.first?.url ?? URL(string: AppState.placeholderStringUrl)!
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
