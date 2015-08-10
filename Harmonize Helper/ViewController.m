//
//  ViewController.m
//  Harmonize Helper
//
//  Created by Ольферук Александр on 06.08.15.
//  Copyright (c) 2015 Ольферук Александр. All rights reserved.
//

#import "ViewController.h"
#import "HHPianoView.h"

@interface ViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet HHPianoView *piano;

@property (weak, nonatomic) IBOutlet UIPickerView *scaleTonicPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *scaleTypePickerView;

@property (strong, nonatomic) NSArray *notes;
@property (strong, nonatomic) NSArray *scaleTypes;

@end

@implementation ViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.notes = @[
                    @"None",
                    @"C",
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
    self.scaleTypes = @[ @"Major", @"Minor" ];
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

#pragma Picker view stuff

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
        if (pickerView == self.scaleTonicPickerView) {
            return 13;
        }
        else
            return 2;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.scaleTonicPickerView) {
        return self.notes[row];
    }
    else
        return self.scaleTypes[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *note, *type;
    
    if (pickerView == self.scaleTonicPickerView) {
        NSLog(@"Tonic is %@", self.notes[row]);
        
        note = self.notes[row];
        type = [self.scaleTypes objectAtIndex:[self.scaleTypePickerView selectedRowInComponent:0]];
    }
    else {
        NSLog(@"Type is %@", self.scaleTypes[row]);
        
        type = self.scaleTypes[row];
        note = [self.notes objectAtIndex:[self.scaleTonicPickerView selectedRowInComponent:0]];
    }
    
    [self.piano highlightScaleWithTonic:note ofType:type];
}

@end
