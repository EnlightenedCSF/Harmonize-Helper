//
//  HHKeyboard.m
//  Harmonize Helper
//
//  Created by Ольферук Александр on 06.08.15.
//  Copyright (c) 2015 Ольферук Александр. All rights reserved.
//

#import "HHKeyboard.h"

@interface HHKeyboard ()

@property (strong, nonatomic) NSArray *keys;
@property (strong, nonatomic) NSDictionary *scaleIntervals;
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
        NSLog(@"Total: %lu", (unsigned long)temp.count);
        
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
    }
    
    return self;
}

#pragma mark - Scales

-(NSArray *)getMelodicIntervalsOfScale:(HHScale)scale
{
    return [self.scaleIntervals objectForKey:@(scale)];
}

-(NSArray *)getScaleOfRootByIndex:(NSInteger)root scale:(HHScale)scale outputFormat:(HHScaleOutputFormat)format
{
    return [self getScaleOfRootByIndex:root scale:scale outputFormat:format continious:NO];
}

-(NSArray *)getScaleOfRootByIndex:(NSInteger)root scale:(HHScale)scale outputFormat:(HHScaleOutputFormat)format continious:(BOOL)continious
{
    NSMutableArray *res = [NSMutableArray array];
    if (format == HHScaleOutputFormatIndexes) {
        [res addObject:@(root)];
    }
    else {
        [res addObject:_keys[root]];
    }
    
    NSArray *intervals = [self getMelodicIntervalsOfScale:scale];
    
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

#pragma mark - 

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


-(BOOL)isKeyWhiteAtIndex:(NSInteger)index
{
    if (index == _keys.count-1)
    {
        return NO;
    }
    
    NSString *key = _keys[index];
    return key.length < 3;
}

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
    NSString *key = _keys[index + 1];
    return key.length == 3;
}

-(NSString *)getKeyAtIndex:(NSInteger)index
{
    if (index < 0 || index > self.keys.count) {
        return nil;
    }
    return self.keys[index];
}

-(NSInteger)getNoteIndexInOctave:(NSString *)key {
    return [[self.notesInOctave objectForKey:[key substringFromIndex:1]] integerValue];
}

#pragma mark - test_scale_major_with_index

-(void)test_scale_major_with_index:(NSInteger)index completion:(void (^)(NSArray *))completion
{
    NSArray *result = [self getScaleOfRootByIndex:index scale:HHScaleMajor outputFormat:HHScaleOutputFormatIndexes];
    completion(result);
}

@end
