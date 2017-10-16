//
//  UIView+ZGDragable.m
//  ZGViewDragable
//
//  Created by offcn_zcz32036 on 2017/10/16.
//  Copyright © 2017年 cn. All rights reserved.
//

#import "UIView+ZGDragable.h"
#import <objc/runtime.h>
static const char *actionHandlePanGestureKey;
@implementation UIView (ZGDragable)
-(void)addDragableActionWithEnd:(void(^)(CGRect endFrame))endBlock
{
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanAction:)];
    [self addGestureRecognizer:pan];
    objc_setAssociatedObject(self, actionHandlePanGestureKey, endBlock, OBJC_ASSOCIATION_COPY);
}
-(void)handlePanAction:(UIPanGestureRecognizer*)sender
{
    CGPoint point=[sender translationInView:[sender.view superview]];
    CGFloat senderHalfViewWidth=sender.view.frame.size.width/2;
    CGFloat senderHalfViewHeight=sender.view.frame.size.height/2;
    
    __block CGPoint viewCenter=CGPointMake(sender.view.center.x+point.x, sender.view.center.y+point.y);
    //拖拽状态结束
    if (sender.state==UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.4 animations:^{
            if ((sender.view.center.x+point.x-senderHalfViewWidth)<=12) {
                viewCenter.x=senderHalfViewWidth+12;
            }
            if ((sender.view.center.x+point.x+senderHalfViewWidth)>=(SCREENWIDTH-12)) {
                viewCenter.x = SCREENWIDTH - senderHalfViewWidth - 12;
            }
            if ((sender.view.center.y + point.y - senderHalfViewHeight) <= 12) {
                viewCenter.y = senderHalfViewHeight + 12;
            }
            if ((sender.view.center.y + point.y + senderHalfViewHeight) >= (SCREENHEIGHT - 12)) {
                viewCenter.y = SCREENHEIGHT - senderHalfViewHeight - 12;
            }
            sender.view.center = viewCenter;
        } completion:^(BOOL finished) {
            void (^endBlock)(CGRect endFrame) = objc_getAssociatedObject(self, actionHandlePanGestureKey);
            if (endBlock) {
                endBlock(sender.view.frame);
            }
        }];
        [sender setTranslation:CGPointMake(0, 0) inView:[sender.view superview]];
    }
    else
    {
        // UIGestureRecognizerStateBegan || UIGestureRecognizerStateChanged
        viewCenter.x = sender.view.center.x + point.x;
        viewCenter.y = sender.view.center.y + point.y;
        sender.view.center = viewCenter;
        [sender setTranslation:CGPointMake(0, 0) inView:[sender.view superview]];
    }
}
@end
