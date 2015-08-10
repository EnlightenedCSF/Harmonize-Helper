//
//  HHKeyboard.m
//  Harmonize Helper
//
//  Created by Ольферук Александр on 06.08.15.
//  Copyright (c) 2015 Ольферук Александр. All rights reserved.
//

#import "HHKeyboard.h"
#import "HHChord.h"

#import <LGHelper.h>

@interface HHKeyboard ()

@property (strong, nonatomic) NSArray *keys;

@property (strong, nonatomic) NSDictionary *scaleIntervals;
@property (strong, nonatomic) NSDictionary *chordIntervals;

@property (strong, nonatomic) NSDictionary *notesInOctave;

@end

@implementation HHKeyboard

#pragma mark - Initialization

+(HHKeyboard *)sharedKeyboard
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(id)init {
    if (self = [super init]) {
        
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:84];
        
        [temp addObject:@"0A"];
        [temp addObject:@"0A#"];
        [temp addObject:@"0B"];
        
        NSArray *notes = @[ @"C",
                            @"C#",
                            @"D",
                            @"D#",
                            @"E",
                            @"F",
                            @"F#",
                            @"G",
                            @"G#",
                            @"A",
                            @"A#",
                            @"B"
                           ];
        
        for (int i = 1; i < 8; ++i) {
            for (int j = 0; j < notes.count; ++j) {
                [temp addObject:[NSString stringWithFormat:@"%i%@", i, notes[j]]];
            }
        }
        [temp addObject:@"8C"];
        
        self.keys = [temp copy];
        self.notesInOctave = @{ @"C": @(0),
                                @"D": @(1),
                                @"E": @(2),
                                @"F": @(3),
                                @"G": @(4),
                                @"A": @(5),
                                @"B": @(6)
                              };
        
        self.scaleIntervals = @{
                                @(HHScaleMajor): @[@2,@2,@1,@2,@2,@2,@1],
                                @(HHScaleMinor): @[@2,@1,@2,@2,@1,@2,@2]
                                };
        
        self.chordIntervals = @{
                                @(HHChordTypeMajor):            @[ @(HHIntervalMajThird), @(HHIntervalPerfFifth) ],
                                @(HHChordTypeMinor):            @[ @(HHIntervalMinThird), @(HHIntervalPerfFifth) ],
                                
                                @(HHChordTypeAugmented):        @[ @(HHIntervalMajThird), @(HHIntervalMinSixth) ],
                                @(HHChordTypeDiminished):       @[ @(HHIntervalMinThird), @(HHIntervalDimFifth) ],
                                
                                @(HHChordTypeDomSeventh):       @[ @(HHIntervalMajThird), @(HHIntervalPerfFifth), @(HHIntervalMinSeventh) ],
                                @(HHChordTypeMinSeventh):       @[ @(HHIntervalMinThird), @(HHIntervalPerfFifth), @(HHIntervalMinSeventh) ],
                                @(HHChordTypeMajSeventh):       @[ @(HHIntervalMajThird), @(HHIntervalPerfFifth), @(HHIntervalMajSeventh) ],
                                
                                @(HHChordTypeAugSeventh):       @[ @(HHIntervalMajThird), @(HHIntervalMinSixth), @(HHIntervalMinSeventh) ],
                                @(HHChordTypeDimSeventh):       @[ @(HHIntervalMinThird), @(HHIntervalDimFifth), @(HHIntervalMajSixth) ],
                                @(HHChordTypeHalfDimSeventh):   @[ @(HHIntervalMinThird), @(HHIntervalDimFifth), @(HHIntervalMinSeventh) ],
                               };
    }
    
    return self;
}

#pragma mark - Extra methods

-(NSString *)keyAtIndex:(NSInteger)index
{
    if (index < 0 || index > self.keys.count) {
        return nil;
    }
    return self.keys[index];
}

-(NSInteger)noteIndexInOctave:(NSString *)key {
    return [[self.notesInOctave objectForKey:[key substringFromIndex:1]] integerValue];
}

#pragma mark - Intervals

-(HHInterval)intervalBetweenNotesWithIndex:(NSInteger)index andIndex:(NSInteger)anotherIndex
{
    return labs(index - anotherIndex);
}

-(NSString *)getLocalizedIntervalName:(HHInterval)interval
{
//    HHIntervalPerfUnison = 0,
//    
//    HHIntervalMinSecond = 1,
//    HHIntervalMajSecond = 2,
//    
//    HHIntervalMinThird = 3,
//    HHIntervalMajThird = 4,
//    
//    HHIntervalPerfFourth = 5,
//    HHIntervalAugFourth = 6,
//    
//    HHIntervalDimFifth = 6,
//    HHIntervalPerfFifth = 7,
//    HHIntervalAugFifth = 8,
//    
//    HHIntervalMinSixth = 8,
//    HHIntervalMajSixth = 9,
//    
//    HHIntervalDimSeventh = 9,
//    HHIntervalMinSeventh = 10,
//    HHIntervalMajSeventh = 11,
//    
//    HHIntervalPerfOctave = 12
    
    switch (interval) {
        case 0:
            return LS(@"HHIntervalPerfUnison");
            break;
        case 1:
            return LS(@"HHIntervalMinSecond");
            break;
        case 2:
            return LS(@"HHIntervalMajSecond");
            break;
        case 3:
            return LS(@"HHIntervalMinThird");
            break;
        case 4:
            return LS(@"HHIntervalMajThird");
            break;
        case 5:
            return LS(@"HHIntervalPerfFourth");
            break;
        case 6:
            return LS(@"HHIntervalDimFifth");
            break;
        case 7:
            return LS(@"HHIntervalPerfFifth");
            break;
        case 8:
            return LS(@"HHIntervalAugFifth");
            break;
        case 9:
            return LS(@"HHIntervalDimSeventh");
            break;
        case 10:
            return LS(@"HHIntervalMinSeventh");
            break;
        case 11:
            return LS(@"HHIntervalMajSeventh");
            break;
        case 12:
            return LS(@"HHIntervalPerfOctave");
            break;
        default:
            return @"";
            break;
    }
}

#pragma mark - Scales

-(NSArray *)scaleOfRootByIndex:(NSInteger)root scale:(HHScale)scale outputFormat:(HHScaleOutputFormat)format
{
    return [self scaleOfRootByIndex:root scale:scale outputFormat:format continious:NO];
}

-(NSArray *)scaleOfRootByIndex:(NSInteger)root scale:(HHScale)scale outputFormat:(HHScaleOutputFormat)format continious:(BOOL)continious
{
    NSMutableArray *res = [NSMutableArray array];
    if (format == HHScaleOutputFormatIndexes) {
        [res addObject:@(root)];
    }
    else {
        [res addObject:_keys[root]];
    }
    
    NSArray *intervals = [self melodicIntervalsOfScale:scale];
    
    if (!continious) {
        for (NSInteger i = 0; i < intervals.count; ++i) {
            root += [intervals[i] integerValue];
            if (format == HHScaleOutputFormatIndexes) {
                [res addObject:@(root)];
            }
            else {
                [res addObject:_keys[root]];
            }
        }
    }
    else {
        int k = 0;
        while (root < _keys.count) {
            root += [intervals[k++] integerValue];
            if (k == intervals.count) {
                k = 0;
            }
            if (format == HHScaleOutputFormatIndexes) {
                [res addObject:@(root)];
            }
            else {
                [res addObject:_keys[root]];
            }
        }
    }
    
    return res;
}

-(NSArray *)melodicIntervalsOfScale:(HHScale)scale
{
    return [self.scaleIntervals objectForKey:@(scale)];
}

-(BOOL)isKeyWithIndex:(NSInteger)index inScaleWithTonic:(HHNote)tonic ofScaleType:(HHScale)scaleType
{
    NSMutableArray *scale = [NSMutableArray arrayWithArray:[self scaleOfRootByIndex:tonic scale:scaleType outputFormat:(HHScaleOutputFormatIndexes) continious:YES]];
    
    for (NSInteger i = 0; i < scale.count; ++i) {
        scale[i] = @([scale[i] intValue] + 3);
    }
    
    return [scale containsObject:@(index)];
}

#pragma mark - Indexes

-(NSInteger)indexOfKeyByWhiteKeyNumber:(NSInteger)index andSharp:(BOOL)sharp
{
    NSInteger newIndex = [self indexOfKeyByWhiteKeyNumber:index];
    if (sharp) {
        ++newIndex;
    }
    return newIndex;
}

-(NSInteger)indexOfKeyByWhiteKeyNumber:(NSInteger)index
{
    int k = 0;
    for (int i = 0; i < _keys.count; ++i) {
        NSString *key = _keys[i];
        if (key.length == 3) {
            continue;
        }
        
        k++;
        
        if (k == index+1) {
            return i;
        }
    }
    return -1;
}

-(NSInteger)whiteKeyIndexByIndexOfKey:(NSInteger)index
{
    int k = 0;
    for (NSInteger i = 0; i <= index; ++i) {
        NSString *key = _keys[i];
        if (key.length == 2) {
            k++;
        }
    }
    return --k;
}

#pragma mark - Black & Whites

-(BOOL)isKeyWhiteAtIndex:(NSInteger)index
{
    if (index == _keys.count-1)
    {
        return NO;
    }
    
    NSString *key = _keys[index];
    return key.length < 3;
}

-(BOOL)isKeyBlackAtIndex:(NSInteger)index
{
    return ![self isKeyWhiteAtIndex:index];
}

#pragma mark - Flats & Sharps

-(BOOL)hasKeyFlatAtIndex:(NSInteger)index
{
    if (index == 0) {
        return NO;
    }
    
    NSString *key = _keys[index - 1];
    return key.length == 3;
}

-(BOOL)hasKeySharpAtIndex:(NSInteger)index
{
    if (index == _keys.count) {
        return NO;
    }
    
    NSString *key = _keys[index + 1];
    return key.length == 3;
}

#pragma mark - Chords

-(HHChord *)chordOfKeysPressedWithIndexes:(NSArray *)keys
{
    for (NSInteger i = 0; i < keys.count; ++i) {
        
        NSMutableArray *intervals = [NSMutableArray array];
        for (NSInteger j = 0; j < keys.count; ++j) {
            if (j == i) {
                continue;
            }
            
            [intervals addObject:@([self intervalBetweenNotesWithIndex:[keys[i] integerValue] andIndex:[keys[j] integerValue]])];
        }
        
        for (id key in [_chordIntervals allKeys]) {
            NSArray *chordType = [_chordIntervals objectForKey:key];
            
            NSSet *one = [NSSet setWithArray:chordType];
            NSSet *two = [NSSet setWithArray:[intervals copy]];
            if ([one isEqualToSet:two]) {
                
                for (NSInteger k = 0; k < keys.count; ++k) { // search for tonic
                    
                    NSSet *one = [self keysOfChordWithTonic:[keys[k] intValue] ofType:[key intValue]];
                    NSSet *two = [NSSet setWithArray:keys];
                    
                    if ([one isEqualToSet:two]) {
                        return [[HHChord alloc] initWithTonic:[keys[k] intValue] chordType:[key longValue]];
                    }
                }
            }
        }
    }
    
    return [[HHChord alloc] initWithTonic:0 chordType:(HHChordTypeNone)];
}

-(NSSet *)keysOfChordWithTonic:(NSInteger)tonic ofType:(HHChordType)type
{
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:@(tonic)];
    
    NSArray *chordType = self.chordIntervals[@(type)];
    for (id interval in chordType) {
        [arr addObject:@(tonic + [interval intValue])];
    }
    return [NSSet setWithArray:[arr copy]];
}

#pragma mark - test_scale_major_with_index

-(NSArray *)test_scale_major_with_index:(NSInteger)index
{
    return [self scaleOfRootByIndex:index scale:HHScaleMajor outputFormat:HHScaleOutputFormatIndexes];
}

@end
