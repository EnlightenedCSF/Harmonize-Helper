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
#import "HHChord.h"

#import <LGHelper.h>

@import AVFoundation;

#import <STKAudioPlayer.h>

#define WHITE_KEYS_COUNT 52
#define WIDTH_HEIGHT_RATIO 4.0f

#define NUMBER_IN_FILENAME 39148
#define REST_OF_THE_FILENAME @"__jobro__piano-ff-0"

typedef enum : NSUInteger {
    HHShowingModeNone = 0,
    HHShowingModeScale,
    HHShowingModeInterval,
    HHShowingModeChord
} HHShowingMode;

@interface HHPianoView () <AVAudioPlayerDelegate>

@property (weak, nonatomic) HHKeyboard *keyboard;

@property (strong, nonatomic) NSMutableArray *players;

@property (assign, nonatomic) CGFloat offsetX;
@property (assign, nonatomic) NSInteger firstWhiteKeyIndex;
@property (assign, nonatomic) BOOL isPreviousBlackKeyVisible;

@property (assign, nonatomic) NSInteger whiteKeysCount;
@property (assign, nonatomic) CGFloat keyWidth;
@property (assign, nonatomic) CGFloat keyHeight;

@property (assign, nonatomic) CGFloat blackKeyShift;
@property (assign, nonatomic) CGFloat blackKeyWidth;
@property (assign, nonatomic) CGFloat blackKeyHeight;

@property (assign, nonatomic) CGFloat keyboardWidth;

@property (assign, nonatomic) CGFloat keyAssistLabelOffsetX;
@property (assign, nonatomic) CGFloat keyAssistLabelOffsetY;
@property (assign, nonatomic) CGFloat keyAssistLabelWidth;
@property (assign, nonatomic) CGFloat keyAssistLabelHeight;

@property (strong, nonatomic) NSArray *keyAssistLabelColors;

@property (assign, nonatomic) HHShowingMode mode;

@property (assign, nonatomic) BOOL isInScaleMode;
@property (assign, nonatomic) HHScale scaleType;
@property (assign, nonatomic) HHNote scaleTonic;

@property (strong, nonatomic) NSMutableArray *highlightedWhiteKeys;
@property (strong, nonatomic) NSMutableArray *highlightedBlackKeys;

@end

@implementation HHPianoView

@synthesize firstWhiteKeyIndex = _firstWhiteKeyIndex;
@synthesize keyWidth = _keyWidth;

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
    self.multipleTouchEnabled = YES;
    
    _players = [NSMutableArray array];
    
    _keyAssist = YES;
    _offsetX = 0;
    _firstWhiteKeyIndex = 0;
    _isPreviousBlackKeyVisible = YES;
    
    _keyboard = [HHKeyboard sharedKeyboard];
    
    _keyHeight = self.bounds.size.height < self.bounds.size.width ? self.bounds.size.height : self.bounds.size.width;
    self.keyWidth = _keyHeight / WIDTH_HEIGHT_RATIO;
    
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
    
    _mode = HHShowingModeNone;
    
    _isInScaleMode = NO;
}

-(void)setOffsetX:(CGFloat)offsetX
{
    _offsetX = offsetX;
    _firstWhiteKeyIndex = abs((int)(offsetX / _keyWidth));
    _isPreviousBlackKeyVisible = ((int)round(offsetX) % (int)round(_keyWidth)) <= _blackKeyWidth/2.0f;
}

-(void)setKeyWidth:(CGFloat)keyWidth
{
    _keyWidth = keyWidth;
    _keyboardWidth = keyWidth * WHITE_KEYS_COUNT;
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
    
    switch (_mode) {
        case HHShowingModeScale:
            if (self.highlightedWhiteKeys.count > 0 || self.highlightedBlackKeys.count > 0) {
                [self drawHighlightedKeys];
            }
            break;
            
        case HHShowingModeInterval:
            [self drawInterval];
            break;
        
        case HHShowingModeChord:
            [self drawChord];
            break;
            
        default:
            break;
    }
}

-(void)recalculateKeysCount
{
    _whiteKeysCount = ceil(self.bounds.size.width / _keyWidth);
}

-(void)drawKeys
{
    [[HHColors blackKeyColor] setStroke];
    
    for (NSInteger i = 0; i < _whiteKeysCount + 1; ++i) {
        
        if (self.isInScaleMode && [self isKeyInHighlightedScaleWithIndex:[_keyboard indexOfKeyByWhiteKeyNumber:(i + _firstWhiteKeyIndex)]]) {
            [[HHColors highlightedWhiteKeyColor] setFill];
        }
        else {
            [[HHColors whiteKeyColor] setFill];
        }
        
        UIBezierPath *whiteKeyPath = [UIBezierPath bezierPathWithRect:CGRectMake(
                                                                                 [self xCoordForKeyWithIndex:i isBlack:NO],
                                                                                 0,                     // y
                                                                                 _keyWidth,
                                                                                 _keyHeight)];
        [whiteKeyPath fill];
        [whiteKeyPath stroke];
    }
    
    
    [[UIColor blackColor] setStroke];

    
    //    | ## ## | ## ## ## |
    //    | ## ## | ## ## ## |
    //    | ## ## | ## ## ## |
    //    | ## ## | ## ## ## |
    //    |       |          |
    
    for (NSInteger i = 0; i < _whiteKeysCount + 1; ++i) {
        
        if ([self indexIsBad:i]) {
            continue;
        }
        
        if (self.isInScaleMode && [self isKeyInHighlightedScaleWithIndex:[_keyboard indexOfKeyByWhiteKeyNumber:(i + _firstWhiteKeyIndex) andSharp:YES]]) {
            [[HHColors highlightedBlackKeyColor] setFill];
        }
        else {
            [[HHColors blackKeyColor] setFill];
        }
        
        UIBezierPath *blackKeyPath = [UIBezierPath bezierPathWithRect:CGRectMake(
                                                                                 [self xCoordForKeyWithIndex:i isBlack:YES],
                                                                                 0,
                                                                                 _blackKeyWidth,
                                                                                 _blackKeyHeight)];
        [blackKeyPath fill];
        [blackKeyPath stroke];
    }
}

-(BOOL)isKeyInHighlightedScaleWithIndex:(NSInteger)index {
    if (!self.isInScaleMode) {
        return NO;
    }
    return [_keyboard isKeyWithIndex:index inScaleWithTonic:self.scaleTonic ofScaleType:self.scaleType];
}

-(BOOL)indexIsBad:(NSInteger)i
{
    NSInteger realKeyIndex = [_keyboard indexOfKeyByWhiteKeyNumber:(_firstWhiteKeyIndex + i)];
    return ![_keyboard hasKeySharpAtIndex:realKeyIndex];
}


-(CGFloat)xCoordForKeyWithIndex:(NSInteger)index isBlack:(BOOL)isBlack
{
//    NSInteger white = [_keyboard whiteKeyIndexByIndexOfKey:index];
//    white -= _firstWhiteKeyIndex;
    
    int mult = isBlack ? 1 : -1;
    CGFloat s = mult * (int)round(-_offsetX) % (int)round(_keyWidth); // на сколько первая белая клавиша сдвинута
    if (isBlack) {
        s = _keyWidth - s;
        s -= _blackKeyWidth/2.0f;
    }
    return s + index*_keyWidth;
} // todo

-(CGFloat)xCoordForKeyWithKeyboardIndex:(NSInteger)index
{
    NSInteger whiteIndex = [_keyboard whiteKeyIndexByIndexOfKey:index];
    whiteIndex -= _firstWhiteKeyIndex;
    
    CGFloat shift = (int)round(-_offsetX) % (int)round(_keyWidth);
    CGFloat result = whiteIndex * _keyWidth - shift;

    if ([_keyboard isKeyBlackAtIndex:index]) {
        result += _blackKeyShift;
    }
    
    return result;
} // this method is ok


-(void)drawChord
{
    HHChord *chord = [_keyboard chordOfKeysPressedWithIndexes:[_highlightedWhiteKeys copy]];
    
        NSLog(@"This is %@", chord);
    
    if (chord.type == HHChordTypeNone)
        return;
    
    NSMutableArray *xs = [NSMutableArray array];
    for (id item in _highlightedWhiteKeys) {
        [xs addObject:@([self xCoordForKeyWithKeyboardIndex:[item intValue]])];
    }
    
    NSNumber *minX = [xs valueForKeyPath:@"@min.self"];
    NSNumber *maxX = [xs valueForKeyPath:@"@max.self"];
    
    UIColor *color = _keyAssistLabelColors[0];
    [color set];
    
    CGRect rect = CGRectMake([minX floatValue] + _keyWidth/2.0,
                             _blackKeyHeight - _keyWidth * 2.0f,
                             [maxX floatValue] - [minX floatValue],
                             25.0f);
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:rect];
    [rectPath fill];
    
    NSString *chordDescription = [NSString stringWithFormat:@"%@", chord];
    CGSize size = [chordDescription sizeWithAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16.0f] }];
    CGRect labelRect = CGRectMake(rect.origin.x + 30.0f,
                                  rect.origin.y - size.height,
                                  size.width,
                                  size.height);
    
    color = _keyAssistLabelColors[1];
    [chordDescription drawInRect:labelRect withAttributes:@{ NSBackgroundColorAttributeName: color,
                                                             NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                                             NSForegroundColorAttributeName: [UIColor whiteColor] }];
}


-(void)drawInterval
{
    NSInteger index1 = [_highlightedWhiteKeys[0] integerValue];
    NSInteger index2 = [_highlightedWhiteKeys[1] integerValue];
    
    CGFloat x1 = [self xCoordForKeyWithKeyboardIndex:index1];
    CGFloat x2 = [self xCoordForKeyWithKeyboardIndex:index2];
    
    BOOL bothAreWhite = [_keyboard isKeyWhiteAtIndex:index1] && [_keyboard isKeyWhiteAtIndex:index2];
    
    UIColor *navy = _keyAssistLabelColors[3];
    [navy set];
    
    CGRect rect = CGRectMake(MIN(x1, x2) + _keyWidth/2.0, // x
                             (bothAreWhite ? _keyHeight - 80.0 : _keyHeight - 170.0),
                             fabs(x1-x2),
                             25.0f);
    
    UIBezierPath *line = [UIBezierPath bezierPathWithRect:rect];
    [line fill];
    
    NSInteger distance = [_keyboard intervalBetweenNotesWithIndex:index1 andIndex:index2];
    NSString *s = [_keyboard getLocalizedIntervalName:distance];
    CGSize size = [s sizeWithAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16.0f] }];
    
    UIColor *orange = _keyAssistLabelColors[1];
    [orange set];
    
    CGRect label = CGRectMake(rect.origin.x,
                              rect.origin.y - size.height,
                              size.width,
                              size.height);
    UIBezierPath *labelPath = [UIBezierPath bezierPathWithRect:label];
    [labelPath fill];
    
    [s drawInRect:label withAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16.0f],
                               NSForegroundColorAttributeName: [UIColor whiteColor] }];
}

-(void)drawKeyAssistLabels
{
    CGFloat s = - (int)round(-_offsetX) % (int)round(_keyWidth);

    for (NSInteger i = 0; i < _whiteKeysCount; ++i)
    {
        CGRect keyAssistLabelRect = CGRectMake(s + i*_keyWidth + _keyAssistLabelOffsetX,
                                               _keyAssistLabelOffsetY,
                                               _keyAssistLabelWidth,
                                               _keyAssistLabelHeight);
        
        UIBezierPath *rect = [UIBezierPath bezierPathWithRect:keyAssistLabelRect];
        NSString *keyString = [_keyboard keyAtIndex:[_keyboard indexOfKeyByWhiteKeyNumber:(_firstWhiteKeyIndex + i)]];
        [[_keyAssistLabelColors objectAtIndex:[_keyboard noteIndexInOctave:keyString]] setFill];
        
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

#pragma mark - Highlighting

-(void)highlightKeyWithIndex:(NSInteger)index
{
    if ([_keyboard isKeyWhiteAtIndex:index]) {
        NSInteger whiteIndex = [_keyboard whiteKeyIndexByIndexOfKey:index];
        [self.highlightedWhiteKeys addObject:@(whiteIndex)];
    }
    else {
        NSInteger whiteIndex = [_keyboard whiteKeyIndexByIndexOfKey:index+1];
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
        
        for (NSInteger i = 0; i < indexes.count; ++i) {
            [self highlightKeyWithIndex:[indexes[i] integerValue]];
        }
        
        [self setNeedsDisplay];
    }
}

-(void)clearHighlights {
    [self.highlightedBlackKeys removeAllObjects];
    [self.highlightedWhiteKeys removeAllObjects];
}

#pragma mark - Gesture recognition

-(NSInteger)getIndexOfKeyPressed:(UITouch *)touch
{
    CGPoint locationInView = [touch locationInView:self];
    CGFloat oneKeyOffset = (int)round(_offsetX) % (int)round(_keyWidth);

    if (locationInView.y > _blackKeyHeight)  //white key processing
    {
        int whiteKeyIndex = (int)(locationInView.x - oneKeyOffset) / (int)round(_keyWidth);
        whiteKeyIndex += _firstWhiteKeyIndex;
        
        return [_keyboard indexOfKeyByWhiteKeyNumber:whiteKeyIndex];
    }
    else
    {
        int blackKeyIndex = (int)(locationInView.x - oneKeyOffset - _blackKeyShift) / (int)round(_keyWidth);
        blackKeyIndex += _firstWhiteKeyIndex;
        return [_keyboard indexOfKeyByWhiteKeyNumber:blackKeyIndex andSharp:YES];
    }
}

-(void)processSingleTouch:(UITouch *)touch
{
    NSArray *highlights;
    NSInteger index = [self getIndexOfKeyPressed:touch];
    if ([_keyboard isKeyWhiteAtIndex:index]) {
        highlights = [_keyboard test_scale_major_with_index:index];
    }
    else {
        highlights = [_keyboard test_scale_major_with_index:index];
    }
    [self clearHighlights];
    [self highlightKeysWithIndexes:highlights];
    
    //[self playKeyWithIndex:index]; // вынести это отсюда
}

-(void)processDoubleTouch:(NSSet *)touches
{
    NSArray *twoTouches = [touches allObjects];
    UITouch *first = twoTouches[0];
    UITouch *second = twoTouches[1];
    
    NSInteger index1 = [self getIndexOfKeyPressed:first];
    NSInteger index2 = [self getIndexOfKeyPressed:second];
    
    [self.highlightedWhiteKeys addObject:@(index1)];
    [self.highlightedWhiteKeys addObject:@(index2)];
}

-(void)processMultipleTouch:(NSSet *)touches
{
    [self clearHighlights];
 
    NSArray *orderedTouched = [touches allObjects];
    for (UITouch *touch in orderedTouched) {
        [_highlightedWhiteKeys addObject:@([self getIndexOfKeyPressed:touch])];
    }
}

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    switch (event.allTouches.count) {
        
        // single tap; showing scale
        case 1: {
//            NSLog(@"Single began");
            NSLog(@"Single began; touches: %lu, events.allTouches: %lu", (unsigned long)touches.count, (unsigned long)event.allTouches.count);

            
            _mode = HHShowingModeScale;
            UITouch *touch = [[event allTouches] anyObject];
            [self processSingleTouch:touch];
            [self playKeyWithIndex:[self getIndexOfKeyPressed:touch]];
            break;
        }
            
        // double tap; showing interval
        case 2: {
            if (_mode == HHShowingModeScale) {
                [self clearHighlights];
            }
            
            NSLog(@"Double began; touches: %lu, events.allTouches: %lu", (unsigned long)touches.count, (unsigned long)event.allTouches.count);
            
            _mode = HHShowingModeInterval;
            [self processDoubleTouch:event.allTouches];
            
            for (UITouch *touch in event.allTouches) {
                if (![touches containsObject:touch]) {
                    continue;
                }
                [self playKeyWithIndex:[self getIndexOfKeyPressed:touch]];
            }
            
            break;
        }
            
        // 3 or more; showing chord
        default: {
            NSLog(@"Triple began");
            
            _mode = HHShowingModeChord;
            [self processMultipleTouch:event.allTouches];
            
            for (UITouch *touch in event.allTouches) {
                if (![touches containsObject:touch]) {
                    continue;
                }
                [self playKeyWithIndex:[self getIndexOfKeyPressed:touch]];
            }
            
            break;
        }
    }
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    switch (event.allTouches.count) {
        case 1: {
            NSLog(@"Single ended");
            _mode = HHShowingModeNone;
            break;
        }
        case 2: {
            NSLog(@"Double ended");
            
            if (touches.count == event.allTouches.count) { // убрали сразу оба пальца
                _mode = HHShowingModeNone;
                [self clearHighlights];
            }
            else {
                UITouch *takenOff = [touches anyObject];
                for (UITouch *touch in event.allTouches) {
                    if (takenOff != touch)
                    {
                    
                        _mode = HHShowingModeScale;
                        [self processSingleTouch:touch]; // process not the taken off, but the left on the screen finger
                        break;
                    }
                }
            }
            break;
        }
        default: {
//            NSLog(@"Triple or more ended");
            NSLog(@"Multiple ended; touches: %lu, events.allTouches: %lu", (unsigned long)touches.count, (unsigned long)event.allTouches.count);

            long fingersLeft = event.allTouches.count - touches.count;
            switch (fingersLeft) {
                case 2: {
                    _mode = HHShowingModeInterval;
                    
                    NSMutableSet *twoTouches = [NSMutableSet set];
                    for (UITouch *t in event.allTouches) {
                        if (![touches containsObject:t]) {
                            [twoTouches addObject:t];
                        }
                    }
                    [self processDoubleTouch:twoTouches];
                    
                    break;
                }
                case 1: {
                    _mode = HHShowingModeScale;
                    
                    for (UITouch *t in event.allTouches) {
                        if (![touches containsObject:t]) {
                            [self processSingleTouch:t];
                            break;
                        }
                    }
                    break;
                }
                default:
                    _mode = HHShowingModeNone;
                    [self clearHighlights];
                    break;
            }
            break;
        }
    }
    [self setNeedsDisplay];
}

#pragma mark - Playing sounds

-(NSString *)getCorrectFileNameOfNoteWithIndex:(NSInteger)index
{
    int addition = NUMBER_IN_FILENAME + (int)index;
    
    ++index;
    NSString *num = [NSString stringWithFormat:(index < 10 ? @"0%li" : @"%li"), (long)index];
    
    return [NSString stringWithFormat:@"%i%@%@.wav", addition, REST_OF_THE_FILENAME, num];
}

-(void)playKeyWithIndex:(NSInteger)index
{
    NSString *fileName = [self getCorrectFileNameOfNoteWithIndex:index];
    
    NSURL *url = kMainBundleDirectoryURL;
    url = [url URLByAppendingPathComponent:fileName];
    
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    player.delegate = self;
    
    [_players addObject:player];
    
    [player play];
}

#pragma mark - Audio player Delegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_players removeObject:player];
}

#pragma mark - Controls

-(void)shiftOffsetTo:(CGFloat)value
{
    self.offsetX = -value * (_keyboardWidth - self.bounds.size.width - 120);
    [self setNeedsDisplay];
}

-(void)highlightScaleWithTonic:(NSString *)tonic ofType:(NSString *)type
{
    if ([@"None" isEqualToString:tonic]) {
        self.isInScaleMode = NO;
        [self setNeedsDisplay];
        return;
    }
    
    self.isInScaleMode = YES;
    
    if ([@"Major" isEqualToString:type]) {
        self.scaleType = HHScaleMajor;
    }
    else {
        self.scaleType = HHScaleMinor;
    }
    
    if ([@"C" isEqualToString:tonic]) {
        self.scaleTonic = C;
    }
    else if ([@"C#" isEqualToString:tonic]) {
        self.scaleTonic = CSharp;
    }
    else if ([@"D" isEqualToString:tonic]) {
        self.scaleTonic = D;
    }
    else if ([@"D#" isEqualToString:tonic]) {
        self.scaleTonic = DSharp;
    }
    else if ([@"E" isEqualToString:tonic]) {
        self.scaleTonic = E;
    }
    else if ([@"F" isEqualToString:tonic]) {
        self.scaleTonic = F;
    }
    else if ([@"F#" isEqualToString:tonic]) {
        self.scaleTonic = FSharp;
    }
    else if ([@"G" isEqualToString:tonic]) {
        self.scaleTonic = G;
    }
    else if ([@"G#" isEqualToString:tonic]) {
        self.scaleTonic = GSharp;
    }
    else if ([@"A" isEqualToString:tonic]) {
        self.scaleTonic = A;
    }
    else if ([@"A#" isEqualToString:tonic]) {
        self.scaleTonic = ASharp;
    }
    else if ([@"B" isEqualToString:tonic]) {
        self.scaleTonic = B;
    }
    
    [self setNeedsDisplay];
}

@end
