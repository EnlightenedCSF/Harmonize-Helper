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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)keyAssistValueChanged:(UISwitch *)sender {
    self.piano.keyAssist = sender.isOn;
    [self.piano setNeedsDisplay];
}

-(void)viewWillLayoutSubviews
{
    [self.piano setNeedsDisplay];
}

@end
