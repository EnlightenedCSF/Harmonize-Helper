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
#import <STKAudioPlayer.h>

#define WHITE_KEYS_COUNT 52
#define WIDTH_HEIGHT_RATIO 5.0f

#define NUMBER_IN_FILENAME 39148
#define REST_OF_THE_FILENAME @"__jobro__piano-ff-0"

@interface HHPianoView () <STKAudioPlayerDelegate>

@property (weak, nonatomic) HHKeyboard *keyboard;

//@property (strong, nonatomic) STKAudioPlayer *player;
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

@property (assign, nonatomic) BOOL isSingleTapHolding;
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
    //_player = [[STKAudioPlayer alloc] init];
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
    _isSingleTapHolding = NO;
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
    
    if (_isSingleTapHolding && (self.highlightedWhiteKeys.count > 0 || self.highlightedBlackKeys.count > 0)) {
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
    
    CGFloat s = - (int)round(-_offsetX) % (int)round(_keyWidth);
    
    for (NSInteger i = 0; i < _whiteKeysCount + 1; ++i) {
        UIBezierPath *whiteKeyPath = [UIBezierPath bezierPathWithRect:CGRectMake(s + i*_keyWidth,       // x
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
        
        if ([self indexIsBad:i]) {
            continue;
        }
        
        CGFloat s = (int)round(-_offsetX) % (int)round(_keyWidth);
        s = _keyWidth - s;
        s -= _blackKeyWidth/2.0f;
        
        UIBezierPath *blackKeyPath = [UIBezierPath bezierPathWithRect:CGRectMake(s + i*_keyWidth,
                                                                                 0,
                                                                                 _blackKeyWidth,
                                                                                 _blackKeyHeight)];
        [blackKeyPath fill];
        [blackKeyPath stroke];
    }
}

-(BOOL)indexIsBad:(NSInteger)i
{
    NSInteger realKeyIndex = [_keyboard indexOfKeyByWhiteKeyNumber:(_firstWhiteKeyIndex + i)];
    return ![_keyboard hasKeySharpAtIndex:realKeyIndex];
}

-(void)drawKeyAssistLabels
{
    CGFloat s = - (int)round(-_offsetX) % (int)round(_keyWidth);

    for (NSInteger i = 0; i < _whiteKeysCount; ++i)
    {
        CGRect keyAssistLabelRect = CGRectMake(s + i*_keyWidth + _keyAssistLabelOffsetX,  //_offsetX + i*_keyWidth + _keyAssistLabelOffsetX,
                                               _keyAssistLabelOffsetY,
                                               _keyAssistLabelWidth,
                                               _keyAssistLabelHeight);
        
        UIBezierPath *rect = [UIBezierPath bezierPathWithRect:keyAssistLabelRect];
        NSString *keyString = [_keyboard getKeyAtIndex:[_keyboard indexOfKeyByWhiteKeyNumber:(_firstWhiteKeyIndex + i)]];
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
    
    [self playKeyWithIndex:index];
}

-(void)processDoubleTouch:(NSSet *)touches
{
    NSArray *twoTouches = [touches allObjects];
    UITouch *first = twoTouches[0];
    UITouch *second = twoTouches[1];
    
    NSInteger index1 = [self getIndexOfKeyPressed:first];
    NSInteger index2 = [self getIndexOfKeyPressed:second];
    
    NSInteger distance = [_keyboard getDistanceBetweenNotesWithIndex:index1 andIndex:index2];
    
    NSLog(@"The distance is: %lu", distance);    
}

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    switch (event.allTouches.count) {
        
        // single tap; showing scale
        case 1: {
            NSLog(@"Single began");
            _isSingleTapHolding = YES;
            UITouch *touch = [[event allTouches] anyObject];
            [self processSingleTouch:touch];
            break;
        }
            
        // double tap; showing interval
        case 2: {
            if (_isSingleTapHolding) {
                [self clearHighlights];
            }
            
            NSLog(@"Double began");
            [self processDoubleTouch:event.allTouches];
            break;
        }
            
        // 3 or 4; showing chord
        case 3:
        case 4: {
            NSLog(@"Triple began");
            
            break;
        }
        default:
            break;
    }
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    switch (event.allTouches.count) {
        case 1: {
            NSLog(@"Single ended");
            _isSingleTapHolding = NO;
            break;
        }
        case 2: {
            NSLog(@"Double ended");
            
            UITouch *takenOff = [touches anyObject];
            for (UITouch *touch in event.allTouches) {
                if (takenOff != touch) {
                    [self processSingleTouch:touch]; // process not the taken off, but the left on the screen finger
                    break;
                }
            }
            break;
        }
        case 3:
        case 4: {
            NSLog(@"Triple or more ended");
            
            break;
        }
        default:
            break;
    }
    [self setNeedsDisplay];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Cancelled");
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
    
    STKAudioPlayer *player = [[STKAudioPlayer alloc] init];
    player.delegate = self;
    [_players addObject:player];
    
    NSURL *url = kMainBundleDirectoryURL;
    url = [url URLByAppendingPathComponent:fileName];
    
    [player play:[url absoluteString]];
}

#pragma mark - STK Delegate

-(void)audioPlayer:(STKAudioPlayer *)audioPlayer didFinishPlayingQueueItemId:(NSObject *)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    [_players removeObject:audioPlayer];
}

-(void)audioPlayer:(STKAudioPlayer *)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject *)queueItemId {}
-(void)audioPlayer:(STKAudioPlayer *)audioPlayer didStartPlayingQueueItemId:(NSObject *)queueItemId {}
-(void)audioPlayer:(STKAudioPlayer *)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState {}
-(void)audioPlayer:(STKAudioPlayer *)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode {}

#pragma mark - Controls

-(void)shiftOffsetTo:(CGFloat)value
{
    self.offsetX = -value * (_keyboardWidth - self.bounds.size.width - 120);
//    NSLog(@"Value = %f; Offset is %f; width is %f", value, self.offsetX, self.bounds.size.width);
    [self setNeedsDisplay];
}

@end
