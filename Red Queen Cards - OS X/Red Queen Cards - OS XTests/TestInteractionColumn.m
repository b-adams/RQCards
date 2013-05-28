//
//  Red Queen Cards - OS X - TestInteractionColumn.m
//  Copyright 2013 Bryant Adams. All rights reserved.
//
//  Created by: Bryant Adams
//

    // Class under test
#import "RQCmInteractionColumn.h"
#import "RQC_MI_Columnar.h"

    // Collaborators

    // Test support
#import <SenTestingKit/SenTestingKit.h>

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

// Uncomment the next two lines to use OCMockito for mock objects:
#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>


@interface TestInteractionColumn : SenTestCase
@end

@implementation TestInteractionColumn
{
    id<RQC_MI_Columnar> sut;
    // test fixture ivars go here
}

- (void)setUp
{
    [super setUp];
    sut = [[RQCmInteractionColumn alloc] init];
}
- (void)tearDown
{
    sut = nil;
    [super tearDown];
}

- (void)testEffectorDetectionStartsClear
{
    assertThat(sut, hasProperty(@"isEffectorAlarmTriggered", @(NO)));
}
- (void)testEffectorAlarmOnMatchedEffector
{
    [sut enableEffector:1];
    [sut enableRProtein:1];
    assertThatBool([sut isEffectorAlarmTriggered], equalToBool(YES));
}
- (void)testEffectorNoFalsePositiveWithDetector
{
    [sut enableRProtein:1];
    assertThatBool([sut isEffectorAlarmTriggered], equalToBool(NO));
}
- (void)testEffectorNoFalsePositiveWithoutDetector
{
    [sut enableEffector:1];
    assertThatBool([sut isEffectorAlarmTriggered], equalToBool(NO));
}
- (void)testEffectorNoFalsePositiveOnUnmatchedEffector
{
    
    [sut enableEffector:1];
    [sut enableRProtein:2];
    assertThatBool([sut isEffectorAlarmTriggered], equalToBool(NO));
}
- (void)testMultipleEffectorsWithSingleTarget
{
    [sut enableEffector:1];
    [sut enableRProtein:1];
    [sut enableRProtein:2];
    assertThatBool([sut isEffectorAlarmTriggered], equalToBool(YES));
}

- (void)testPAMPDetectionStartsClear
{
    assertThat(sut, hasProperty(@"isMAMPAlarmTriggered", @(NO)));
}

- (void)testBasicPAMPDetection
{
    [sut enableMAMP];
    [sut enablePRR];
    assertThatBool([sut isMAMPAlarmTriggered], equalToBool(YES));
}


- (void)testBasicPAMPNoFalsePositiveWithoutDetector
{
    [sut enableMAMP];
    assertThatBool([sut isMAMPAlarmTriggered], equalToBool(NO));
}

- (void)testBasicPAMPNoFalsePositiveWithDetector
{
    [sut enablePRR];
    assertThatBool([sut isMAMPAlarmTriggered], equalToBool(NO));
}

- (void)testSubvertedPAMPDetection
{
    [sut enableMAMP];
    [sut enablePRR];
    [sut enableEffector:1];
    assertThatBool([sut isMAMPAlarmTriggered], equalToBool(NO));
}
- (void)testDoublySubvertedPAMPDetection
{
    [sut enableMAMP];
    [sut enablePRR];
    [sut enableEffector:1];
    [sut enableEffector:0];
    assertThatBool([sut isMAMPAlarmTriggered], equalToBool(NO));
}




@end
