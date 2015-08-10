//
//  HHChord.m
//  Harmonize Helper
//
//  Created by Ольферук Александр on 10.08.15.
//  Copyright (c) 2015 Ольферук Александр. All rights reserved.
//

#import "HHChord.h"

#import <LGHelper.h>

@implementation HHChord

-(id)initWithTonic:(NSInteger)tonic chordType:(HHChordType)type
{
    if (self = [super init]) {
        self.tonic = tonic;
        self.type = type;
    }
    return self;
}

-(NSString *)description
{
    char t = [[[HHKeyboard sharedKeyboard] keyAtIndex:self.tonic] characterAtIndex:1];
    NSString *addition;
        
    switch (self.type) {
        case HHChordTypeMajor:
            addition = LS(@"HHChordTypeMajor");
            break;
        case HHChordTypeMinor:
            addition = LS(@"HHChordTypeMinor");
            break;
        case HHChordTypeAugmented:
            addition = LS(@"HHChordTypeAugmented");
            break;
        case HHChordTypeDiminished:
            addition = LS(@"HHChordTypeDiminished");
            break;
        case HHChordTypeDomSeventh:
            addition = LS(@"HHChordTypeDomSeventh");
            break;
        case HHChordTypeMinSeventh:
            addition = LS(@"HHChordTypeMinSeventh");
            break;
        case HHChordTypeMajSeventh:
            addition = LS(@"HHChordTypeMajSeventh");
            break;
        case HHChordTypeAugSeventh:
            addition = LS(@"HHChordTypeAugSeventh");
            break;
        case HHChordTypeDimSeventh:
            addition = LS(@"HHChordTypeDimSeventh");
            break;
        case HHChordTypeHalfDimSeventh:
            addition = LS(@"HHChordTypeHalfDimSeventh");
            break;
        default:
            addition = LS(@"HHChordTypeNone");
            break;
    }
    
    return [NSString stringWithFormat:@"%c%@", t, addition];
}

-(NSComparisonResult)isEqualToChord:(HHChord *)chord
{
    if ((self.tonic == chord.tonic) && (self.type == chord.type)) {
        return 0;
    }
    return -1; // todo
}

@end
