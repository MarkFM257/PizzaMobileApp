import XCTest
@testable import PizzaMobileApp

final class AppShellViewModelTests: XCTestCase {
    @MainActor
    func testRemoteStartupBecomesReadyWithPreparedContent() async {
        let pizzas = [TestFixtures.pizza()]
        let preparer = StubCatalogPreparer(
            initial: prepared(pizzas: pizzas, source: .remote)
        )
        let shell = makeShell(preparer: preparer)

        await shell.start()

        XCTAssertEqual(shell.startupState, .ready)
        XCTAssertEqual(shell.catalogScreen, .content(pizzas))
    }

    @MainActor
    func testStartupDeadlineReleasesSplashWhileNetworkIsStillPending() async {
        let preparer = DelayedCatalogPreparer()
        let shell = AppShellViewModel(
            catalog: PizzaCatalogViewModel(prepareCatalog: preparer),
            connectivity: ConnectivityViewModel(monitor: StubConnectivityMonitor()),
            splashMaximumDuration: .milliseconds(10)
        )

        let startup = Task { await shell.start() }
        try? await Task.sleep(for: .milliseconds(30))

        XCTAssertEqual(shell.startupState, .degraded)
        XCTAssertTrue(shell.isStartupReady)
        XCTAssertEqual(
            shell.catalogScreen,
            .failed("The connection is too slow. Please try again.")
        )

        startup.cancel()
        await startup.value
    }

    @MainActor
    func testCachedStartupPublishesFreshCatalogInCurrentSession() async {
        let cached = [TestFixtures.pizza(id: "cached")]
        let fresh = [TestFixtures.pizza(id: "fresh")]
        let preparer = StubCatalogPreparer(
            initial: prepared(pizzas: cached, source: .cache),
            refreshed: prepared(pizzas: fresh, source: .remote)
        )
        let shell = makeShell(preparer: preparer)

        await shell.start()
        for _ in 0..<100 where shell.catalogScreen != .content(fresh) {
            await Task.yield()
        }

        XCTAssertEqual(shell.catalogScreen, .content(fresh))
    }

    @MainActor
    private func makeShell(
        preparer: StubCatalogPreparer
    ) -> AppShellViewModel {
        AppShellViewModel(
            catalog: PizzaCatalogViewModel(prepareCatalog: preparer),
            connectivity: ConnectivityViewModel(monitor: StubConnectivityMonitor())
        )
    }

    private func prepared(
        pizzas: [Pizza],
        source: PizzaCatalogSource
    ) -> PreparedPizzaCatalog {
        PreparedPizzaCatalog(
            pizzas: pizzas,
            source: source
        )
    }
}

private actor StubCatalogPreparer: PreparePizzaCatalogUseCase {
    let initial: PreparedPizzaCatalog
    let refreshed: PreparedPizzaCatalog

    init(
        initial: PreparedPizzaCatalog,
        refreshed: PreparedPizzaCatalog? = nil
    ) {
        self.initial = initial
        self.refreshed = refreshed ?? initial
    }

    func loadInitial() async throws -> PreparedPizzaCatalog {
        initial
    }

    func refresh() async throws -> PreparedPizzaCatalog {
        refreshed
    }
}

private actor DelayedCatalogPreparer: PreparePizzaCatalogUseCase {
    func loadInitial() async throws -> PreparedPizzaCatalog {
        try await Task.sleep(for: .seconds(5))
        return PreparedPizzaCatalog(pizzas: [], source: .remote)
    }

    func refresh() async throws -> PreparedPizzaCatalog {
        try await loadInitial()
    }
}

private final class StubConnectivityMonitor: ConnectivityMonitoring, @unchecked Sendable {
    @MainActor
    func startObserving(_ onChange: @escaping @MainActor (Bool) -> Void) {}
}
