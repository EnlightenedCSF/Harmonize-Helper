//
//  HHPianoView.m
//  Harmonize Helper
//
//  Created by Ольферук Александр on 06.08.15.
//  Copyright (c) 2015 Ольферук Александр. All rights reserved.
//

#import "HHPianoView.h"
#import "HHColors.h"
#import "HHKeyboard.h"

#import <LGHelper.h>

#define WIDTH_HEIGHT_RATIO 5.0f

@interface HHPianoView ()

@property (weak, nonatomic) HHKeyboard *keyboard;

@property (assign, nonatomic) CGFloat offsetX;
@property (assign, nonatomic) NSInteger firstWhiteKeyIndex;
@property (assign, nonatomic) BOOL isPreviousBlackKeyVisible;

@property (assign, nonatomic) NSInteger whiteKeysCount;
@property (assign, nonatomic) CGFloat keyWidth;
@property (assign, nonatomic) CGFloat keyHeight;

@property (assign, nonatomic) CGFloat blackKeyShift;
@property (assign, nonatomic) CGFloat blackKeyWidth;
@property (assign, nonatomic) CGFloat blackKeyHeight;

@property (assign, nonatomic) CGFloat keyAssistLabelOffsetX;
@property (assign, nonatomic) CGFloat keyAssistLabelOffsetY;
@property (assign, nonatomic) CGFloat keyAssistLabelWidth;
@property (assign, nonatomic) CGFloat keyAssistLabelHeight;

@property (strong, nonatomic) NSArray *keyAssistLabelColors;

@property (strong, nonatomic) NSMutableArray *highlightedWhiteKeys;
@property (strong, nonatomic) NSMutableArray *highlightedBlackKeys;

@end

@implementation HHPianoView

@synthesize firstWhiteKeyIndex = _firstWhiteKeyIndex;

#pragma mark - Initialization

-(void)awakeFromNib {
    [self setup];
}

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

-(void)setup
{
    _keyAssist = YES;
    _offsetX = 0;
    _firstWhiteKeyIndex = 0;
    _isPreviousBlackKeyVisible = YES;
    
    _keyboard = [HHKeyboard sharedKeyboard];
    
    _keyHeight = self.bounds.size.height < self.bounds.size.width ? self.bounds.size.height : self.bounds.size.width;
    _keyWidth = _keyHeight / WIDTH_HEIGHT_RATIO;
    
    _blackKeyShift = _keyWidth / 3.0f * 2.0f;
    _blackKeyHeight = _keyHeight * 0.62f;
    _blackKeyWidth = _keyWidth / 3.0f *2.0f;
    
    _whiteKeysCount = ceil(self.bounds.size.width / _keyWidth);
    
    _keyAssistLabelWidth = _keyWidth - 16.0f;
    _keyAssistLabelHeight = _keyHeight * 0.1f;
    _keyAssistLabelOffsetX = (_keyWidth - _keyAssistLabelWidth) / 2.0f;
    _keyAssistLabelOffsetY = _keyHeight - _keyAssistLabelHeight * 1.2f;
    
    _keyAssistLabelColors = @[ kColorRGB(200, 100, 60),
                               kColorRGB(255, 205, 102),
                               kColorRGB(120, 200, 160),
                               kColorRGB(75, 190, 215),
                               kColorRGB(140, 100, 135),
                               kColorRGB(88, 144, 180),
                               kColorRGB(220, 160, 120)
                               ];
    _highlightedWhiteKeys = [NSMutableArray arrayWithArray:@[]];
    _highlightedBlackKeys = [NSMutableArray arrayWithArray:@[]];
}

-(void)setOffsetX:(CGFloat)offsetX
{
    _offsetX = offsetX;
    _firstWhiteKeyIndex = offsetX / _keyWidth;
    _isPreviousBlackKeyVisible = ((int)round(offsetX) % (int)round(_keyWidth)) <= _blackKeyWidth/2.0f;
}


#pragma mark - Drawing

-(void)drawRect:(CGRect)rect
{
    UIGraphicsGetCurrentContext();

    [self recalculateKeysCount];

    [self drawKeys];
    
    if (self.keyAssist) {
        [self drawKeyAssistLabels];
    }
    
    if (self.highlightedWhiteKeys.count > 0 || self.highlightedBlackKeys.count > 0) {
        [self drawHighlightedKeys];
    }
}

-(void)recalculateKeysCount
{
    _whiteKeysCount = ceil(self.bounds.size.width / _keyWidth);
}

-(void)drawKeys
{
    [[HHColors whiteKeyColor] setFill];
    [[HHColors blackKeyColor] setStroke];
    
    for (NSInteger i = 0; i < _whiteKeysCount; ++i) {
        UIBezierPath *whiteKeyPath = [UIBezierPath bezierPathWithRect:CGRectMake(_offsetX + i*_keyWidth, // x
                                                                                 0,                     // y
                                                                                 _keyWidth,
                                                                                 _keyHeight)];
        [whiteKeyPath fill];
        [whiteKeyPath stroke];
    }
    
    
    [[HHColors blackKeyColor] setFill];
    [[UIColor blackColor] setStroke];

    
//    | ## ## | ## ## ## |
//    | ## ## | ## ## ## |
    
    for (NSInteger i = 0; i < _whiteKeysCount + 1; ++i) {
        
        if (i == 0 && !_isPreviousBlackKeyVisible) {
            continue;
        }
        
        if ([self indexIsBad:i]) {
            continue;
        }
        
        UIBezierPath *blackKeyPath = [UIBezierPath bezierPathWithRect:CGRectMake(_offsetX + i*_keyWidth + _blackKeyShift,   // x
                                                                                 0,                                         // y
                                                                                 _blackKeyWidth,
                                                                                 _blackKeyHeight)];
        [blackKeyPath fill];
        [blackKeyPath stroke];
    }
}

-(BOOL)indexIsBad:(NSInteger)i
{
    NSInteger realKeyIndex = [_keyboard indexOfKeyByWhiteKeyNumber:_firstWhiteKeyIndex + i];
    return ![_keyboard hasKeySharpAtIndex:realKeyIndex];
}

-(void)drawKeyAssistLabels
{
    for (NSInteger i = 0; i < _whiteKeysCount; ++i)
    {
        CGRect keyAssistLabelRect = CGRectMake(_offsetX + i*_keyWidth + _keyAssistLabelOffsetX,
                                               _keyAssistLabelOffsetY,
                                               _keyAssistLabelWidth,
                                               _keyAssistLabelHeight);
        
        UIBezierPath *rect = [UIBezierPath bezierPathWithRect:keyAssistLabelRect];
        NSString *keyString = [_keyboard getKeyAtIndex:[_keyboard indexOfKeyByWhiteKeyNumber:i]];
        [[_keyAssistLabelColors objectAtIndex:[_keyboard getNoteIndexInOctave:keyString]] setFill];
        
        [rect fill];
        [keyString drawInRect:keyAssistLabelRect withAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:20.0f],
                                                                   NSForegroundColorAttributeName: [UIColor whiteColor]
                                                                }];
    }
}

-(void)drawHighlightedKeys
{
    [[UIColor orangeColor] setFill];

    for (NSNumber *n in self.highlightedWhiteKeys)
    {
        UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(_offsetX + _keyWidth * [n intValue] + (_keyWidth-20)/2.0f,
                                                                                 _blackKeyHeight + 10.0f,
                                                                                 20,
                                                                                 20)];
        [circle fill];
    }
    
    for (NSNumber *n in self.highlightedBlackKeys)
    {
        UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(_offsetX + _keyWidth * [n intValue] + (_keyWidth-20)/2.0f - _keyWidth/2.0f,
                                                                                 _blackKeyHeight - 40.0f,
                                                                                 20,
                                                                                 20)];
        [circle fill];
    }
}

-(void)highlightKeyWithIndex:(NSInteger)index
{
    if ([_keyboard isKeyWhiteAtIndex:index]) {
        NSInteger whiteIndex = [_keyboard whiteKeyIndexByIndexOfKey:index];
        whiteIndex -= _firstWhiteKeyIndex;

        [self.highlightedWhiteKeys addObject:@(whiteIndex)];
    }
    else {
        NSInteger whiteIndex = [_keyboard whiteKeyIndexByIndexOfKey:index+1];
        whiteIndex -= _firstWhiteKeyIndex;
        
        [self.highlightedBlackKeys addObject:@(whiteIndex)];
    }
}

-(void)highlightKeysWithIndexes:(NSArray *)indexes
{
    NSInteger firstVisibleKeyIndex = [_keyboard indexOfKeyByWhiteKeyNumber:_firstWhiteKeyIndex];
    NSInteger lastVisibleKeyIndex = [_keyboard indexOfKeyByWhiteKeyNumber:(_firstWhiteKeyIndex + _whiteKeysCount)];
    
    NSInteger firstScaleNote = [indexes[0] integerValue];
    NSInteger lastScaleNote = [indexes[indexes.count-1] integerValue];
    
    if (firstScaleNote <= lastVisibleKeyIndex || lastScaleNote >= firstVisibleKeyIndex) { // if any of the scale
        
        NSLog(@"It's visible");
        for (NSInteger i = 0; i < indexes.count; ++i) {
            [self highlightKeyWithIndex:[indexes[i] integerValue]];
        }
        
        [self setNeedsDisplay];
    }
}

#pragma mark - Gesture recognition

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint locationInView = [touch locationInView:self];
    
    if (locationInView.y > _blackKeyHeight) { //white key processing
        
        CGFloat oneKeyOffset = (int)round(_offsetX) % (int)round(_keyWidth);
        int whiteKeyIndex = (int)(locationInView.x - oneKeyOffset) / (int)round(_keyWidth);
        NSLog(@"Index: %i", whiteKeyIndex);
        
        [_keyboard test_scale_major_with_index:[_keyboard indexOfKeyByWhiteKeyNumber:whiteKeyIndex] completion:^(NSArray *indexes)
        {
            NSLog(@"Scale is: %@", indexes);
            [self.highlightedWhiteKeys removeAllObjects];
            [self.highlightedBlackKeys removeAllObjects];
            
            [self highlightKeysWithIndexes:indexes];
        }];
    }
    else {
        NSLog(@"Black key was pressed");
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}



@end
