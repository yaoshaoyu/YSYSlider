//
//  YSYSlider.h
//  YSYSlider
//
//  Created by 吕成翘 on 16/11/3.
//  Copyright © 2016年 Apress. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YSYSlider : UIControl

/** 选中的索引 */
@property(nonatomic, readonly) NSInteger selectedIndex;

/**
 自定义构造方法

 @param frame 控件的frame
 @param titles 要显示的标签array
 @return 可拖动带刻度滑竿slider
 */
-(id) initWithFrame:(CGRect) frame Titles:(NSArray<NSString *> *) titles;
/**
 设置选中的索引

 @param index 索引indexs
 */
-(void) setSelectedIndex:(NSInteger)index;

@end
