//
//  HHKeyboard.h
//  Harmonize Helper
//
//  Created by Ольферук Александр on 06.08.15.
//  Copyright (c) 2015 Ольферук Александр. All rights reserved.
//

#import <Foundation/Foundation.h>

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
    
    HHIntervalMinSixth = 8,
    HHIntervalMajSixth = 9,
    
    HHIntervalMinSeventh = 10,
    HHIntervalMajSeventh = 11,
    
    HHIntervalPerfOctave = 12
} HHInterval;

typedef enum : NSUInteger {
    HHChordMajor,
    HHChordMinor,
    HHChordAugmented,
    HHChordDiminished,
    HHChordDomSeventh,
    HHChordMinSeventh,
    HHChordMajSeventh,
    HHChordAugSeventh,
    HHChordDimSeventh,
    HHChordHalfDimSeventh
} HHChord;

typedef enum : NSUInteger {
    HHScaleOutputFormatIndexes = 0,
    HHScaleOutputFormatKeys
} HHScaleOutputFormat;

@interface HHKeyboard : NSObject

+(HHKeyboard *)sharedKeyboard;

-(BOOL)isKeyWhiteAtIndex:(NSInteger)index;
-(BOOL)hasKeyFlatAtIndex:(NSInteger)index;
-(BOOL)hasKeySharpAtIndex:(NSInteger)index;

-(NSInteger)indexOfKeyByWhiteKeyNumber:(NSInteger)index andSharp:(BOOL)sharp;
-(NSInteger)indexOfKeyByWhiteKeyNumber:(NSInteger)index;
-(NSInteger)whiteKeyIndexByIndexOfKey:(NSInteger)index;

-(NSString *)getKeyAtIndex:(NSInteger) index;
-(NSInteger)getNoteIndexInOctave:(NSString *)key;

-(NSArray *)getMelodicIntervalsOfScale:(HHScale)scale;
-(NSArray *)getScaleOfRootByIndex:(NSInteger)root scale:(HHScale)scale outputFormat:(HHScaleOutputFormat)format;
-(NSArray *)getScaleOfRootByIndex:(NSInteger)root scale:(HHScale)scale outputFormat:(HHScaleOutputFormat)format continious:(BOOL)continious;

-(HHInterval)getDistanceBetweenNotesWithIndex:(NSInteger)index andIndex:(NSInteger)anotherIndex;

-(NSArray *)test_scale_major_with_index:(NSInteger)index;

@end
