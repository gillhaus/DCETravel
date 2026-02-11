import SwiftUI

@main
struct DCETravelApp: App {
    @StateObject private var appState: AppState
    @StateObject private var router = AppRouter()

    private let localServer: LocalServer?

    init() {
        // Check for remote API URL (e.g. deployed Vapor server on Railway)
        if let remoteURL = ProcessInfo.processInfo.environment["API_BASE_URL"] {
            print("[DCETravelApp] Using remote API at \(remoteURL)")
            self.localServer = nil
            let client = APIClient(baseURL: remoteURL)
            let services = ServiceContainer(mode: .local(client))
            _appState = StateObject(wrappedValue: AppState(services: services))
            return
        }

        // Set up local API server
        let dataStore = DataStore.shared
        let router = Router()
        APIRouter.configure(router: router, dataStore: dataStore)

        let server = LocalServer(router: router)
        do {
            try server.start()
            self.localServer = server

            // Wait briefly for port assignment
            Thread.sleep(forTimeInterval: 0.1)

            let client = APIClient(baseURL: server.baseURL)
            let services = ServiceContainer(mode: .local(client))
            _appState = StateObject(wrappedValue: AppState(services: services))
        } catch {
            print("[DCETravelApp] Failed to start local server: \(error). Falling back to mock mode.")
            self.localServer = nil
            _appState = StateObject(wrappedValue: AppState())
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(router)
        }
    }
}
