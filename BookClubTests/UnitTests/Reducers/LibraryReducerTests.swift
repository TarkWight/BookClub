//
//  LibraryReducerTests.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import Alamofire
import XCTest

@testable import BookClub

private func makeStrapiResponseJSON<T: Codable>(data: T) throws -> Data {
    let meta = PaginationMeta(
        pagination: .init(page: 1, pageSize: 1, pageCount: 1, total: 1)
    )
    let resp = StrapiResponse(data: data, meta: meta)
    return try JSONEncoder().encode(resp)
}

@MainActor
final class LibraryReducerTests: XCTestCase {
    // MARK: — Заглушка BookStorageServiceProtocol

    private struct StubBookStorage: BookStorageServiceProtocol {
        let newBooksDomain: [Book]
        let popularBooksDomain: [Book]

        func save(_ books: [Book]) async throws {}
        func fetch(isNew: Bool?) async throws -> [Book] {
            isNew == true ? newBooksDomain : popularBooksDomain
        }
        func fetch(byID id: Int64) async throws -> Book?    { nil }
        func fetch(byDocumentId documentId: String) async throws -> Book? { nil }
        func deleteAll() async throws {}
        func setFavorite(documentId: String, to isFav: Bool) async throws {}
    }

    // MARK: — Заглушка NetworkClientProtocol

    private struct StubNetworkClient: NetworkClientProtocol {
        let newBooksResult: Result<[BookDetailsItem], NetworkError>
        let popularBooksResult: Result<[BookDetailsItem], NetworkError>

        func request<T: Decodable>(
            _ config: NetworkConfigProtocol,
            decoder: DataDecoder = JSONDecoder()
        ) async throws -> T {
            // Определяем, какие данные вернуть
            let path = config.path.lowercased()
            let items: [BookDetailsItem] = try {
                if path.contains("new") {
                    return try newBooksResult.get()
                } else {
                    return try popularBooksResult.get()
                }
            }()

            // Упаковываем в StrapiResponse и кодируем в JSON
            let wrapper = StrapiResponse(
                data: items,
                meta: .init(
                    pagination: .init(
                        page: 1,
                        pageSize: items.count,
                        pageCount: 1,
                        total: items.count
                    )
                )
            )
            let json = try JSONEncoder().encode(wrapper)

            // Декодируем из JSON в требуемый тип T
            return try decoder.decode(T.self, from: json)
        }

        func request(_ config: NetworkConfigProtocol) async throws {
            // Здесь просто «заглушка» без тела
        }
    }
    // MARK: — Общие тестовые данные

    private var storage: StubBookStorage!
    private var network: StubNetworkClient!
    private var env: LibraryEnvironment!

    override func setUp() {
        super.setUp()
        storage = StubBookStorage(newBooksDomain: [], popularBooksDomain: [])
        network = StubNetworkClient(
            newBooksResult: .success([]),
            popularBooksResult: .success([])
        )
        env = LibraryEnvironment(networkClient: network, storage: storage)
    }

    // MARK: — Тест onAppear с реальным MockNetworkService

    func testOnAppear_triggersNetworkUsingMockNetworkService() async throws {
        var state = LibraryState()
        let storage = StubBookStorage(newBooksDomain: [], popularBooksDomain: [])
        let mockNet = MockNetworkService()
        let item = BookDetailsItem(
            id: 1,
            documentId: "D1",
            title: "Title",
            coverURL: nil,
            isNew: true,
            illustrationURL: nil,
            isFavorite: false,
            authorName: "Auth",
            description: "Desc"
        )
        mockNet.stubbedData = try makeStrapiResponseJSON(data: [item])
        let env = LibraryEnvironment(networkClient: mockNet, storage: storage)

        let eff = libraryReducer(state: &state, action: .onAppear, env: env)
        XCTAssertTrue(state.didLoadOnAppear)
        guard case let .batch(effects) = eff else {
            return XCTFail("Ожидали batch")
        }
        XCTAssertEqual(effects.count, 4)

        let netNewEffect = effects[2]
        guard case .task = netNewEffect else {
            return XCTFail("Третий эффект должен быть .task (networkNewBooks)")
        }

        let action = await netNewEffect.run()
        switch action {
        case .newBooksResponse(.success(let arr)):
            XCTAssertEqual(arr, [item])
        default:
            XCTFail("Ожидали .newBooksResponse(.success([item])), получили \(action)")
        }
    }
    func testOnAppear_firstTime_producesFourTasks() async {
        var state = LibraryState()
        let eff = libraryReducer(state: &state, action: .onAppear, env: env)
        XCTAssertTrue(state.didLoadOnAppear)
        guard case let .batch(effects) = eff else {
            return XCTFail("Ожидали batch из 4 эффектов")
        }
        XCTAssertEqual(effects.count, 4)
        XCTAssertTrue(effects.allSatisfy { if case .task = $0 { return true } else { return false } })
    }

    // MARK: — Тест локальной загрузки новых книг

    func testFetchLocalNewBooks_emptyLocal_returnsRequestNewBooks() async {
        var state = LibraryState()
        state.newBooks = .idle

        let eff = localNewBooksReducer(
            state: &state,
            action: .fetchLocalNewBooks,
            env: env
        )

        XCTAssertEqual(state.newBooks, .loading)
        XCTAssertTrue(eff.isTask)
        let action = await eff.run()
        XCTAssertEqual(action, .requestNewBooks)
    }

    func testFetchLocalNewBooks_nonEmptyLocal_emitsLocalLoaded() async {
        let detailsItem = BookDetailsItem(
            id: 1,
            documentId: "D",
            title: "T",
            coverURL: nil,
            isNew: true,
            illustrationURL: nil,
            isFavorite: false,
            authorName: "A",
            description: "D"
        )
        // конвертим в домен
        let domainBook = Book(
            id: detailsItem.id,
            documentId: detailsItem.documentId,
            title: detailsItem.title,
            coverURL: detailsItem.coverURL,
            illustrationURL: detailsItem.illustrationURL,
            isFavorite: detailsItem.isFavorite,
            isNew: detailsItem.isNew,
            authorName: detailsItem.authorName,
            description: detailsItem.description
        )
        let storage = StubBookStorage(
            newBooksDomain: [domainBook],
            popularBooksDomain: []
        )
        // используем тот же network, что в setUp
        let env = LibraryEnvironment(networkClient: network, storage: storage)

        var state = LibraryState()
        state.newBooks = .idle

        let eff = localNewBooksReducer(
            state: &state,
            action: .fetchLocalNewBooks,
            env: env
        )

        XCTAssertEqual(state.newBooks, .loading)
        XCTAssertTrue(eff.isTask)
        let resultAction = await eff.run()
        // теперь сравниваем с правильным case
        XCTAssertEqual(
            resultAction,
            .localNewBooksLoaded([detailsItem])
        )
    }

    // MARK: — Тест didSelectBook

    func testDidSelectBook_emitsConfigureAndOnAppear() async {
        let item = BookDetailsItem(
            id: 1,
            documentId: "DOC",
            title: "Title",
            coverURL: nil,
            isNew: true,
            illustrationURL: nil,
            isFavorite: false,
            authorName: "Auth",
            description: "Desc"
        )
        var state = LibraryState()
        state.newBooks = .loaded([item])
        state.popularBooks = .loaded([])

        let eff = libraryReducer(
            state: &state,
            action: .didSelectBook(documentId: "DOC"),
            env: env
        )

        XCTAssertEqual(state.bookDetails, .init())
        guard case let .batch(effects) = eff else {
            return XCTFail("Ожидали batch")
        }
        XCTAssertEqual(effects.count, 2)
        XCTAssertTrue(effects.allSatisfy { if case .task = $0 { return true } else { return false } })

        let a0 = await effects[0].run()
        if case .bookDetails(.configure(let payload)) = a0 {
            XCTAssertEqual(payload.documentId, item.documentId)
            XCTAssertEqual(payload.title, item.title)
            XCTAssertEqual(payload.author, item.authorName)
            XCTAssertEqual(payload.bookId, Int(item.id))
            XCTAssertEqual(payload.description, item.description)
            XCTAssertEqual(payload.coverURL, item.coverURL)
        } else {
            XCTFail("Первый эффект должен быть .bookDetails(.configure(...))")
        }

        let a1 = await effects[1].run()
        XCTAssertEqual(a1, .bookDetails(.onAppear))
    }
}
