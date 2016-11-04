//
//  ViewController.m
//  YSYSlider
//
//  Created by 吕成翘 on 16/11/3.
//  Copyright © 2016年 Apress. All rights reserved.
//

#import "ViewController.h"
#import "YSYSlider.h"


@interface ViewController ()

@property(strong, nonatomic) UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YSYSlider *slider = [[YSYSlider alloc] initWithFrame:CGRectMake(8, 400, self.view.frame.size.width - 16, 70)Titles:@[@"10", @"20", @"30", @"40", @"50", @"60", @"70", @"80"]];
    slider.selectedIndex = 0;
    [slider addTarget:self action:@selector(handlerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 100, self.view.frame.size.width - 16, 40)];
    label.backgroundColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    _label = label;
}

-(void)handlerValueChanged:(YSYSlider *)sender{
    switch (sender.selectedIndex) {
        case 0:
            _label.text = @"10";
            break;
        case 1:
            _label.text = @"20";
            break;
        case 2:
            _label.text = @"30";
            break;
        case 3:
            _label.text = @"40";
            break;
        case 4:
            _label.text = @"50";
            break;
        case 5:
            _label.text = @"60";
            break;
        case 6:
            _label.text = @"70";
            break;
        case 7:
            _label.text = @"80";
            break;
        default:
            break;
    }
}


@end
