//
//  HHChord.h
//  Harmonize Helper
//
//  Created by Ольферук Александр on 10.08.15.
//  Copyright (c) 2015 Ольферук Александр. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHKeyboard.h"

@interface HHChord : NSObject

@property (assign, nonatomic) HHChordType type;
@property (assign, nonatomic) NSInteger tonic;

-(id)initWithTonic:(NSInteger)tonic chordType:(HHChordType)type;

-(NSString *)description;

-(NSComparisonResult)isEqualToChord:(HHChord *)chord;

@end
