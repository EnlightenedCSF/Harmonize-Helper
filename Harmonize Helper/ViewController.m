//
//  ViewController.m
//  Harmonize Helper
//
//  Created by Ольферук Александр on 06.08.15.
//  Copyright (c) 2015 Ольферук Александр. All rights reserved.
//

#import "ViewController.h"
#import "HHPianoView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet HHPianoView *piano;

@end

@implementation ViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Controls

- (IBAction)keyAssistValueChanged:(UISwitch *)sender {
    self.piano.keyAssist = sender.isOn;
    [self.piano setNeedsDisplay];
}

- (IBAction)pianoOffsetChanged:(UISlider *)sender {
    [self.piano shiftOffsetTo:sender.value];
}


#pragma mark - Rotation

-(void)viewWillLayoutSubviews
{
    [self.piano setNeedsDisplay];
}

@end
