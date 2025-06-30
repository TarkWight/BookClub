//
//  ChapterStorageServiceTests.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import XCTest
import CoreData
@testable import BookClub

final class BookStorageServiceTests: XCTestCase {
  var container: NSPersistentContainer!
  var service: BookStorageService!

  override func setUpWithError() throws {
    let model = NSManagedObjectModel.mergedModel(from: nil)!
    container = NSPersistentContainer(name: "BookClub", managedObjectModel: model)
    let desc = NSPersistentStoreDescription()
    desc.type = NSInMemoryStoreType
    container.persistentStoreDescriptions = [desc]
    container.loadPersistentStores { _, error in
      XCTAssertNil(error)
    }
    service = BookStorageService(container: container)
  }

  override func tearDown() {
    service = nil
    container = nil
  }

  // MARK: – Helpers

  private func makeDummyBooks() -> [Book] {
    [
      Book(id: 1, documentId: "a", title: "A", coverURL: nil, illustrationURL: nil, isFavorite: false, isNew: true, authorName: "X", description: "D"),
      Book(id: 2, documentId: "b", title: "B", coverURL: nil, illustrationURL: nil, isFavorite: true, isNew: false, authorName: "Y", description: "E"),
    ]
  }

  // MARK: – Tests

  func testSaveAndFetchAll() async throws {
    let books = makeDummyBooks()
    try await service.save(books)
    let fetched = try await service.fetch(isNew: nil)
    XCTAssertEqual(Set(fetched.map(\.id)), Set(books.map(\.id)))
  }

  func testFetchWithIsNewFilter() async throws {
    let books = makeDummyBooks()
    try await service.save(books)
    let onlyNew = try await service.fetch(isNew: true)
    XCTAssertEqual(onlyNew.map(\.id), [1])
    let onlyOld = try await service.fetch(isNew: false)
    XCTAssertEqual(onlyOld.map(\.id), [2])
  }

  func testFetchByIDAndDocumentId() async throws {
    let books = makeDummyBooks()
    try await service.save(books)
    let byID = try await service.fetch(byID: 2)
    XCTAssertEqual(byID?.documentId, "b")
    let byDoc = try await service.fetch(byDocumentId: "a")
    XCTAssertEqual(byDoc?.id, 1)
  }

  func testDeleteAll() async throws {
    try await service.save(makeDummyBooks())
    try await service.deleteAll()
    let fetched = try await service.fetch(isNew: nil)
    XCTAssertTrue(fetched.isEmpty)
  }

  func testSetFavorite() async throws {
    let book = makeDummyBooks()[0]
    try await service.save([book])
    try await service.setFavorite(documentId: book.documentId, to: true)
    let reFetched = try await service.fetch(byDocumentId: book.documentId)
    XCTAssertEqual(reFetched?.isFavorite, true)
  }

  // MARK: – Memory Leak Tests

    func testLeak_save() throws {
       weak var weakSvc: BookStorageService?
       autoreleasepool {
         let svc = BookStorageService(container: container)
         weakSvc = svc
         let exp = XCTestExpectation()
         Task {
           try? await svc.save(makeDummyBooks())
           exp.fulfill()
         }
         wait(for: [exp], timeout: 1)
       }
       XCTAssertNil(weakSvc, "save(_:) должен освобождать экземпляр сервиса")
     }

     func testLeak_fetchAll() throws {
       weak var weakSvc: BookStorageService?
       autoreleasepool {
         let svc = BookStorageService(container: container)
         weakSvc = svc
         let exp = XCTestExpectation()
         Task {
           _ = try? await svc.fetch(isNew: nil)
           exp.fulfill()
         }
         wait(for: [exp], timeout: 1)
       }
       XCTAssertNil(weakSvc, "fetch(isNew:) должен освобождать экземпляр сервиса")
     }

     func testLeak_fetchByID() throws {
       weak var weakSvc: BookStorageService?
       autoreleasepool {
         let svc = BookStorageService(container: container)
         weakSvc = svc
         let exp = XCTestExpectation()
         Task {
           _ = try? await svc.fetch(byID: 0)
           exp.fulfill()
         }
         wait(for: [exp], timeout: 1)
       }
       XCTAssertNil(weakSvc, "fetch(byID:) должен освобождать экземпляр сервиса")
     }

     func testLeak_fetchByDocumentId() throws {
       weak var weakSvc: BookStorageService?
       autoreleasepool {
         let svc = BookStorageService(container: container)
         weakSvc = svc
         let exp = XCTestExpectation()
         Task {
           _ = try? await svc.fetch(byDocumentId: "")
           exp.fulfill()
         }
         wait(for: [exp], timeout: 1)
       }
       XCTAssertNil(weakSvc, "fetch(byDocumentId:) должен освобождать экземпляр сервиса")
     }

     func testLeak_deleteAll() throws {
       weak var weakSvc: BookStorageService?
       autoreleasepool {
         let svc = BookStorageService(container: container)
         weakSvc = svc
         let exp = XCTestExpectation()
         Task {
           try? await svc.deleteAll()
           exp.fulfill()
         }
         wait(for: [exp], timeout: 1)
       }
       XCTAssertNil(weakSvc, "deleteAll() должен освобождать экземпляр сервиса")
     }

     func testLeak_setFavorite() throws {
       weak var weakSvc: BookStorageService?
       autoreleasepool {
         let svc = BookStorageService(container: container)
         weakSvc = svc
         let exp = XCTestExpectation()
         Task {
           try? await svc.setFavorite(documentId: "", to: false)
           exp.fulfill()
         }
         wait(for: [exp], timeout: 1)
       }
       XCTAssertNil(weakSvc, "setFavorite(_:to:) должен освобождать экземпляр сервиса")
     }
   }
