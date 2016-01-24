//
//  CardAnimationTests.swift
//  CardAnimationTests
//
//  Created by seedante on 15/9/30.
//  Copyright © 2015年 seedante. All rights reserved.
//

import XCTest
@testable import CardAnimation

class CardAnimationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCallsToTheDelegate() {
        let cardComponent = AnimatedCardsView(frame: CGRectMake(0, 0, 800, 800))
        let dataSourceMock = DataSourceDelegateMock()
        
        cardComponent.dataSourceDelegate = dataSourceMock
        
        let visibleCount = dataSourceMock.numberOfVisibleCardsCallCount
        let cardCount = dataSourceMock.numberOfCardsCallCount
        XCTAssert(cardCount > 0, "numberOfCards delegate not called")
        XCTAssert(visibleCount > 0, "numberOfVisibleCards delegate not called")
    }
    
    func testComponentAsksForTheCorrectAmountOfData() {
        let numberOfCards = 10, numberOfVisibleCards = 5
        
        let cardComponent = AnimatedCardsView(frame: CGRectMake(0, 0, 800, 800))
        let dataSourceMock = DataSourceDelegateMock()
        dataSourceMock.numberOfCardsValue = numberOfCards
        dataSourceMock.numberOfVisibleCardsValue = numberOfVisibleCards
        
        cardComponent.dataSourceDelegate = dataSourceMock
        
        let visibleCount = dataSourceMock.numberOfVisibleCardsCallCount
        let cardCount = dataSourceMock.numberOfCardsCallCount
        XCTAssert(cardCount == 1, "wrong number of calls to numberOfCards delegate")
        XCTAssert(visibleCount == 1, "wrong number of calls to numberOfVisibleCards delegate")
        XCTAssert(numberOfVisibleCards == dataSourceMock.cardNumberCallCount, "wrong number of calls to cardNumber delegate")
    }
    
    func testReloadDataAsksAgainForAllTheData() {
        let cardComponent = AnimatedCardsView(frame: CGRectMake(0, 0, 800, 800))
        let dataSourceMock = DataSourceDelegateMock()
        
        cardComponent.dataSourceDelegate = dataSourceMock
        
        let visibleCount = dataSourceMock.numberOfVisibleCardsCallCount
        let cardCount = dataSourceMock.numberOfCardsCallCount

        cardComponent.reloadData()
        
        XCTAssert(cardCount == dataSourceMock.numberOfCardsCallCount/2, "not the same number of calls to the numberOfCards delegate")
        XCTAssert(visibleCount == dataSourceMock.numberOfVisibleCardsCallCount/2, "not the same number of calls to the numberOfVisibleCards delegate")
    }
    
    func testChangeOfSizeReloadsData() {
        let cardComponent = AnimatedCardsView(frame: CGRectMake(0, 0, 800, 800))
        let dataSourceMock = DataSourceDelegateMock()
        
        cardComponent.dataSourceDelegate = dataSourceMock
        
        let visibleCount = dataSourceMock.numberOfVisibleCardsCallCount
        let cardCount = dataSourceMock.numberOfCardsCallCount
        
        cardComponent.cardSize = (100,100)
        
        XCTAssert(cardCount == dataSourceMock.numberOfCardsCallCount/2, "not the same number of calls to the numberOfCards delegate")
        XCTAssert(visibleCount == dataSourceMock.numberOfVisibleCardsCallCount/2, "not the same number of calls to the numberOfVisibleCards delegate")
    }
    
}

class DataSourceDelegateMock : AnimatedCardsViewDataSource {
    var numberOfVisibleCardsValue = 10, numberOfVisibleCardsCallCount = 0
    func numberOfVisibleCards() -> Int {
        numberOfVisibleCardsCallCount++
        return numberOfVisibleCardsValue
    }
    
    var numberOfCardsValue = 5, numberOfCardsCallCount = 0
    func numberOfCards() -> Int {
        numberOfCardsCallCount++
        return numberOfCardsValue
    }
    
    var cardNumberCallCount = 0, cacheMiss = 0, cacheHit = 0
    func cardNumber(number:Int, view:BaseCardView?) -> BaseCardView {
        cardNumberCallCount++
        view != nil ? cacheHit++ : cacheMiss++
        return BaseCardView(frame: CGRectMake(0, 0, 10, 10))
    }
}
