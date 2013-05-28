//
//  Red Queen Cards - OS X - TestBoardLayout.m
//  Copyright 2013 Bryant Adams. All rights reserved.
//
//  Created by: Bryant Adams
//

    // Class under test
#import "RQCmPlaymat.h"
#import "RQC_MI_Playmatted.h"

    // Collaborators

    // Test support
#import <SenTestingKit/SenTestingKit.h>

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

// Uncomment the next two lines to use OCMockito for mock objects:
#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>


@interface TestBoardLayout : SenTestCase
@end

@implementation TestBoardLayout
{
    id<RQC_MI_Playmatted> sut;
    id secretary;
    
}
- (void)setUp
{
    [super setUp];
    sut = [[RQCmPlaymat alloc] init];

    secretary = mock([NSObject class]); //Just need it to support KVO
    [(id)sut addObserver:secretary
              forKeyPath:@"currentBoardState"
                 options:(NSKeyValueObservingOptionOld |
                          NSKeyValueObservingOptionNew)
                 context:NULL];
    [(id)sut addObserver:self
              forKeyPath:@"currentBoardState"
                 options:(NSKeyValueObservingOptionOld |
                          NSKeyValueObservingOptionNew)
                 context:NULL];
}
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    NSLog(@"Change dictionary: %@", change);
}


- (void)tearDown
{
    [(id)sut removeObserver:secretary
                 forKeyPath:@"currentBoardState"];
    [(id)sut removeObserver:self
                 forKeyPath:@"currentBoardState"];
    sut = nil;
    secretary = nil;
    [super tearDown];
}



- (void)testInitialBoardStateIsImpotence
{
    assertThat(sut, hasProperty(@"currentBoardState", @(RQC_e_Impotence)));
}

- (void)testPlayOneMAMPStillImpotent
{
    [sut playMAMP:@"a"];

    assertThat(sut, hasProperty(@"currentBoardState", @(RQC_e_Impotence)));
}
- (void)testPlayOneMAMPLeavesStateUnchanged
{
    NSDictionary* fearedChange = nil; //Prepare to cast to avoid warnings!
    fearedChange = (NSDictionary*) hasEntry(@"old", @(RQC_e_Impotence));
    
    [sut playMAMP:@"a"];
    
    [verifyCount(secretary, never()) observeValueForKeyPath:@"currentBoardState"
                                                   ofObject:sut
                                                     change:fearedChange
                                                    context:NULL];
}
//MAMP-A         MAMP-B                         //Virulence
- (void)testPlayTwoMAMPsTriggersVirulence
{
    NSDictionary* expectedChange = nil; //Prepare to cast to avoid warnings!
    expectedChange = (NSDictionary*) hasEntries(@"old", @(RQC_e_Impotence),
                                                @"new", @(RQC_e_Virulence),
                                                nil);
    
    [sut playMAMP:@"a"];
    [sut playMAMP:@"b"];
    
    [verify(secretary) observeValueForKeyPath:@"currentBoardState"
                                     ofObject:sut
                                       change:expectedChange
                                      context:NULL];
}

//MAMP-A mampD-A                                //Impotence
- (void)testPlayOneMAMPAndMatchingDetectorRetainsImpotence
{
    NSDictionary* fearedChange = nil; //Prepare to cast to avoid warnings!
    fearedChange = (NSDictionary*) hasEntry(@"old", @(RQC_e_Impotence));
    
    [sut playMAMP:@"a"];
    [sut playMAMPDetector:@"b"];
    
    [verifyCount(secretary, never()) observeValueForKeyPath:@"currentBoardState"
                                                   ofObject:sut
                                                     change:fearedChange
                                                    context:NULL];
}

//MAMP-A mampD-A MAMP-B                         //Virulence
- (void)testPlayTwoMAMPsAndOnlyOneMatchingDetectorsAllowsVirulence
{
    [sut playMAMP:@"a"];
    [sut playMAMP:@"b"];
    [sut playMAMPDetector:@"a"];

    assertThat(sut, hasProperty(@"currentBoardState", @(RQC_e_Virulence)));
}


//MAMP-A mampD-A MAMP-B mampD-B                 //MTI
- (void)testPlayTwoMAMPsAndMatchingDetectorsTriggersMTI
{
    [sut playMAMP:@"a"];
    [sut playMAMP:@"b"];
    [sut playMAMPDetector:@"a"];
    [sut playMAMPDetector:@"b"];
    
    assertThat(sut, hasProperty(@"currentBoardState", @(RQC_e_MTI)));
}

//MAMP-A mampD-A MAMP-B mampD-C                 //Virulence
//- (void)testPlayTwoMAMPsAndMismatchedDetectorsAllowsVirulence
//{
//    [sut playMAMP:@"a"];
//    [sut playMAMP:@"b"];
//    [sut playMAMPDetector:@"a"];
//    [sut playMAMPDetector:'c'];
//    
//    assertThat(sut, hasProperty(@"currentBoardState", @(RQC_e_Virulence)));
//}

//MAMP-A mampD-A MAMP-B mampD-B EFF-B1          //Virulence

//MAMP-A mampD-A MAMP-B mampD-B EFF-B1 effD-B2  //Virulence
//MAMP-A mampD-A MAMP-B mampD-B EFF-B1 effD-B1  //ETI

//                              EFF-B2 effD-B2  //ETI





@end
