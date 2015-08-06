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
    HHScaleOutputFormatIndexes = 0,
    HHScaleOutputFormatKeys
} HHScaleOutputFormat;

@interface HHKeyboard : NSObject

+(HHKeyboard *)sharedKeyboard;

-(BOOL)isKeyWhiteAtIndex:(NSInteger)index;
-(BOOL)hasKeyFlatAtIndex:(NSInteger)index;
-(BOOL)hasKeySharpAtIndex:(NSInteger)index;

-(NSInteger)indexOfKeyByWhiteKeyNumber:(NSInteger)index;
-(NSInteger)whiteKeyIndexByIndexOfKey:(NSInteger)index;

-(NSString *)getKeyAtIndex:(NSInteger) index;
-(NSInteger)getNoteIndexInOctave:(NSString *)key;

-(NSArray *)getMelodicIntervalsOfScale:(HHScale)scale;
-(NSArray *)getScaleOfRootByIndex:(NSInteger)root scale:(HHScale)scale outputFormat:(HHScaleOutputFormat)format;
-(NSArray *)getScaleOfRootByIndex:(NSInteger)root scale:(HHScale)scale outputFormat:(HHScaleOutputFormat)format continious:(BOOL)continious;

-(void)test_scale_major_with_index:(NSInteger)index completion:(void (^)(NSArray *))completion;

@end
