//
//  HHPianoView.h
//  Harmonize Helper
//
//  Created by Ольферук Александр on 06.08.15.
//  Copyright (c) 2015 Ольферук Александр. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHPianoView : UIView

@property (nonatomic, assign) BOOL keyAssist;

-(void)shiftOffsetTo:(CGFloat)value;

-(void)highlightScaleWithTonic:(NSString *)tonic ofType:(NSString *)type;

@end
