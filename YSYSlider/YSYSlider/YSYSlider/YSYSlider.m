//
//  YSYSlider.m
//  YSYSlider
//
//  Created by 吕成翘 on 16/11/3.
//  Copyright © 2016年 Apress. All rights reserved.
//

#import "YSYSlider.h"

/** 自身的宽度 */
#define kSelfWidth self.bounds.size.width
/** 自身的高度 */
#define kSelfHeight self.bounds.size.height
/** 标签的中心点Y值 */
#define kLabelCenterY kSelfHeight - 55
/** 两端间距 */
#define kMargin 20
/** 两端余出的长度 */
#define kCutLength 10
/** 选中标签向上移动的距离 */
#define kUpHeight 10
/** 标签颜色 */
#define kTitleColor [UIColor lightGrayColor]
/** 标签选中颜色 */
#define kTitleSelectedColor [UIColor redColor]
/** 标签字体 */
#define kTitleFont [UIFont systemFontOfSize:15]
/** 标签阴影颜色 */
#define kTitleShadowColor [UIColor lightGrayColor]
/** 滑竿颜色 */
#define kSilderColor [UIColor blueColor]
/** 滑竿选中颜色 */
#define kSilderSelectedCoror [UIColor redColor];
/** 滑竿粗度 */
#define kSilderLineWidth 5
/** 刻度高度 */
#define kScaleHeight 10 - kSilderLineWidth * 0.25


@interface YSYSlider ()

/** 可拖动按钮 */
@property(strong, nonatomic) UIButton *handler;
@property (strong, nonatomic) UIView *redView;

@end


@implementation YSYSlider {
    /** 保存标签内容 */
    NSArray<NSString *> *_titlesList;
    /** 保存标签 */
    NSMutableArray<UILabel *> *_labelList;
    /** 点击按钮的位置与按钮原点的差 */
    CGPoint _differencePoint;
    /** 单位刻度的长度 */
    float _unitSlotSize;
}

-(id)initWithFrame:(CGRect) frame Titles:(NSArray<NSString *> *) titles{
    if (self = [super initWithFrame:frame]) {
        _titlesList = [[NSArray alloc] initWithArray:titles];
        _labelList = [NSMutableArray arrayWithCapacity:_titlesList.count];
        _unitSlotSize = (kSelfWidth - kMargin * 2) / (_titlesList.count - 1);
        
        [self setupUI];
    }
    return self;
}

-(void)setSelectedIndex:(NSInteger)index{
    _selectedIndex = index;
    
    [self animateTitlesToIndex:index];
    [self animateHandlerToIndex:index];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(void)drawRect:(CGRect)rect{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(contextRef, kMargin - kCutLength, rect.size.height - 32.5);
    CGContextAddLineToPoint(contextRef, rect.size.width - kMargin + kCutLength, rect.size.height - 32.5);
    [kSilderColor set];
    CGContextSetLineWidth(contextRef, kSilderLineWidth);
    CGContextStrokePath(contextRef);
    CGContextSaveGState(contextRef);
    
    for (NSInteger i = 0; i < _titlesList.count; i++) {
        CGContextMoveToPoint(contextRef, kMargin + _unitSlotSize * i, rect.size.height - 32.5);
        CGContextAddLineToPoint(contextRef, kMargin  + _unitSlotSize * i, rect.size.height - 32.5 - kScaleHeight);
        [kSilderColor set];
        CGContextSetLineWidth(contextRef, kSilderLineWidth);
        CGContextStrokePath(contextRef);
        CGContextSaveGState(contextRef);
    }
}

#pragma mark - SetupUI
- (void)setupUI {
    CGFloat buttonWidth = 40;
    CGFloat buttonHeight = buttonWidth;
    
    [self setBackgroundColor:[UIColor yellowColor]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    
    // 设置按钮
    _handler = [UIButton buttonWithType:UIButtonTypeCustom];
    _handler.frame = CGRectMake(kMargin, 8, buttonWidth, buttonHeight);
    _handler.center = CGPointMake(_handler.center.x - buttonWidth * 0.5, kSelfHeight - 29.5 + buttonHeight * 0.5);
    _handler.adjustsImageWhenHighlighted = NO;
    [_handler setBackgroundImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    [self addSubview:_handler];
    
    [_handler addTarget:self action:@selector(touchDownAction:withEvent:) forControlEvents:UIControlEventTouchDown];
    [_handler addTarget:self action:@selector(touchUpAction:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [_handler addTarget:self action:@selector(touchDragAction:withEvent:) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
    
    // 设置标签
    for (int i = 0; i < _titlesList.count; i++) {
        NSString *title = _titlesList[i];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 3, _unitSlotSize, 10)];
        label.center = [self getCenterPointForIndex:i];
        label.text = title;
        label.font = kTitleFont;
        label.textColor =kTitleColor;
        label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        label.adjustsFontSizeToFitWidth = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:label];
        [_labelList addObject:label];
    }
    
    // 设置被选中刻度视图
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(kMargin - kSilderLineWidth * 0.5, kSelfHeight - 32.5 - kScaleHeight, kSilderLineWidth, kScaleHeight)];
    redView.backgroundColor = [UIColor redColor];
    [self addSubview:redView];
    _redView = redView;
}

#pragma mark - ButtonTouchEventAction
/**
 按钮点击监听事件
 
 @param recognizer 点击手势
 */
-(void)tapAction:(UITapGestureRecognizer *)recognizer {
    _selectedIndex = [self getSelectedTitleIndexInPoint:[recognizer locationInView:self]];
    [self setSelectedIndex:_selectedIndex];
    
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

/**
 按钮被按下监听事件
 
 @param button 被按的按钮
 @param event 事件
 */
- (void)touchDownAction:(UIButton *)button withEvent:(UIEvent *)event{
    CGPoint currentPoint = [[[event allTouches] anyObject] locationInView:self];
    
    _differencePoint = CGPointMake(currentPoint.x - button.frame.origin.x, currentPoint.y - button.frame.origin.y);
    
    [self sendActionsForControlEvents:UIControlEventTouchDown];
}

/**
 松开按钮监听事件
 
 @param button 松开的按钮
 */
-(void)touchUpAction:(UIButton*)button{
    _selectedIndex = [self getSelectedTitleIndexInPoint:button.center];
    
    [self animateHandlerToIndex:_selectedIndex];
    
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

/**
 按钮被拖动监听事件
 
 @param button 被拖动的按钮
 @param event 事件
 */
- (void)touchDragAction:(UIButton *)button withEvent:(UIEvent *)event {
    CGPoint currentPotin = [[[event allTouches] anyObject] locationInView:self];
    
    CGPoint toPoint = CGPointMake(currentPotin.x - _differencePoint.x, _handler.frame.origin.y);
    toPoint = [self fixFinalPoint:toPoint];
    
    _handler.frame = CGRectMake(toPoint.x, toPoint.y, _handler.frame.size.width, _handler.frame.size.height);
    
    NSInteger selected = [self getSelectedTitleIndexInPoint:button.center];
    
    [self animateTitlesToIndex:selected];
    
    [self sendActionsForControlEvents:UIControlEventTouchDragInside];
    [self sendActionsForControlEvents:UIControlEventTouchDragOutside];
}

#pragma mark - SetupAnimation
/**
 设置按钮动画
 
 @param index 要移动到的索引
 */
-(void)animateHandlerToIndex:(NSInteger)index{
    CGFloat buttonWidth = _handler.bounds.size.width;
    CGFloat buttonHeight = _handler.bounds.size.height;
    
    CGPoint toPoint = [self getCenterPointForIndex:index];
    toPoint = CGPointMake(toPoint.x - buttonWidth * 0.5, _handler.frame.origin.y);
    toPoint = [self fixFinalPoint:toPoint];
    
    [UIView beginAnimations:nil context:nil];
    _handler.frame = CGRectMake(toPoint.x, toPoint.y, buttonWidth, buttonHeight);
    [UIView commitAnimations];
}

/**
 设置标签动画
 
 @param index 执行动画的标签的索引
 */
-(void)animateTitlesToIndex:(NSInteger)index{
    for (NSInteger i = 0; i < _titlesList.count; i++) {
        UILabel *lable = _labelList[i];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        if (i == index) {
            lable.center = CGPointMake(lable.center.x, kLabelCenterY - kUpHeight);
            lable.textColor = kTitleSelectedColor;
            lable.transform = CGAffineTransformMakeScale(1.5, 1.5);
            
            _selectedIndex = index;
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }else{
            lable.center = CGPointMake(lable.center.x, kLabelCenterY);
            lable.textColor = kTitleColor;
            lable.transform = CGAffineTransformIdentity;
        }
        [UIView commitAnimations];
    }
    
    CGFloat redViewCenterX = 20 + _unitSlotSize * index;
    _redView.center = CGPointMake(redViewCenterX, _redView.center.y);
}

#pragma mark - PositionCalculation
/**
 获取松开按钮时，按钮所在索引
 
 @param point 按钮的中心点
 @return 按钮所在的索引
 */
-(NSInteger)getSelectedTitleIndexInPoint:(CGPoint)point{
    // round()四舍五入
    return round((point.x - kMargin) / _unitSlotSize);
}

/**
 计算标签的中心坐标
 
 @param index 索引
 @return 标签坐标
 */
-(CGPoint)getCenterPointForIndex:(NSInteger)index{
    CGFloat centerX = index / (float)(_titlesList.count - 1) * (kSelfWidth - kMargin * 2) + kMargin;
    CGFloat centerY = index == 0 ? kLabelCenterY - kUpHeight : kLabelCenterY;
    
    return CGPointMake(centerX, centerY);
}

/**
 设置上下限
 */
-(CGPoint)fixFinalPoint:(CGPoint)point{
    CGFloat buttonHalfWidth = _handler.frame.size.width * 0.5;
    
    if (point.x < kMargin - buttonHalfWidth) {
        point.x = kMargin - buttonHalfWidth;
    }else if (point.x > kSelfWidth - kMargin - buttonHalfWidth){
        point.x = kSelfWidth - kMargin - buttonHalfWidth;
    }
    
    return point;
}

@end
