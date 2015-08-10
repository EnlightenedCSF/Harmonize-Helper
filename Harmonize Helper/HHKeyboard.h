//
//  HHKeyboard.h
//  Harmonize Helper
//
//  Created by Ольферук Александр on 06.08.15.
//  Copyright (c) 2015 Ольферук Александр. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HHChord;

typedef enum : NSUInteger {
    C = 0,
    CSharp,
    D,
    DSharp,
    E,
    F,
    FSharp,
    G,
    GSharp,
    A,
    ASharp,
    B
} HHNote;

typedef enum : NSUInteger {
    HHScaleMajor = 0,
    HHScaleMinor
} HHScale;

typedef enum : NSUInteger {
    HHIntervalPerfUnison = 0,
    
    HHIntervalMinSecond = 1,
    HHIntervalMajSecond = 2,
    
    HHIntervalMinThird = 3,
    HHIntervalMajThird = 4,
    
    HHIntervalPerfFourth = 5,
    HHIntervalAugFourth = 6,
    
    HHIntervalDimFifth = 6,
    HHIntervalPerfFifth = 7,
    HHIntervalAugFifth = 8,
    
    HHIntervalMinSixth = 8,
    HHIntervalMajSixth = 9,
    
    HHIntervalDimSeventh = 9,
    HHIntervalMinSeventh = 10,
    HHIntervalMajSeventh = 11,
    
    HHIntervalPerfOctave = 12
} HHInterval;

typedef enum : NSUInteger {
    HHChordTypeNone,
    HHChordTypeMajor,
    HHChordTypeMinor,
    HHChordTypeAugmented,
    HHChordTypeDiminished,
    HHChordTypeDomSeventh,
    HHChordTypeMinSeventh,
    HHChordTypeMajSeventh,
    HHChordTypeAugSeventh,
    HHChordTypeDimSeventh,
    HHChordTypeHalfDimSeventh
} HHChordType;

typedef enum : NSUInteger {
    HHScaleOutputFormatIndexes = 0,
    HHScaleOutputFormatKeys
} HHScaleOutputFormat;

@interface HHKeyboard : NSObject

+(HHKeyboard *)sharedKeyboard;

-(BOOL)isKeyWhiteAtIndex:(NSInteger)index;
-(BOOL)isKeyBlackAtIndex:(NSInteger)index;
-(BOOL)hasKeyFlatAtIndex:(NSInteger)index;
-(BOOL)hasKeySharpAtIndex:(NSInteger)index;

-(NSInteger)indexOfKeyByWhiteKeyNumber:(NSInteger)index andSharp:(BOOL)sharp;
-(NSInteger)indexOfKeyByWhiteKeyNumber:(NSInteger)index;
-(NSInteger)whiteKeyIndexByIndexOfKey:(NSInteger)index;

-(NSString *)keyAtIndex:(NSInteger) index;
-(NSInteger)noteIndexInOctave:(NSString *)key;

-(NSArray *)melodicIntervalsOfScale:(HHScale)scale;
-(NSArray *)scaleOfRootByIndex:(NSInteger)root scale:(HHScale)scale outputFormat:(HHScaleOutputFormat)format;
-(NSArray *)scaleOfRootByIndex:(NSInteger)root scale:(HHScale)scale outputFormat:(HHScaleOutputFormat)format continious:(BOOL)continious;
-(BOOL)isKeyWithIndex:(NSInteger)index inScaleWithTonic:(HHNote)tonic ofScaleType:(HHScale)scaleType;


-(HHInterval)intervalBetweenNotesWithIndex:(NSInteger)index andIndex:(NSInteger)anotherIndex;
-(NSString *)getLocalizedIntervalName:(HHInterval)interval;

-(HHChord *)chordOfKeysPressedWithIndexes:(NSArray *)keys;

-(NSArray *)test_scale_major_with_index:(NSInteger)index;

@end
