//
//  HHColors.m
//  Harmonize Helper
//
//  Created by Ольферук Александр on 06.08.15.
//  Copyright (c) 2015 Ольферук Александр. All rights reserved.
//

#import <LGHelper.h>

#import "HHColors.h"

@implementation HHColors

+(UIColor *)whiteKeyColor
{
    return kColorRGB(213, 230, 226);
}

+(UIColor *)blackKeyColor
{
    return kColorRGB(40, 40, 40);
}


+(UIColor *)highlightedWhiteKeyColor
{
    return kColorRGB(213, 250, 226);
}

+(UIColor *)highlightedBlackKeyColor
{
    return kColorRGB(120, 150, 110);
}


+(UIColor *)playingWhiteKeyColor
{
    return kColorRGB(180, 250, 210);
}

+(UIColor *)playingBlackKeyColor
{
    return kColorRGB(100, 100, 100);
}

@end
