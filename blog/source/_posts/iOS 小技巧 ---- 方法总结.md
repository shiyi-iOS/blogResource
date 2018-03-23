---
title: iOS 小技巧 ---- 方法总结
date: 2018-03-15 12:00:00
tags: 
categories: [技术]
password:
---

## iOS中一些不常用方法总结：

### 1. 删除navigationController中的某个VC

``` objectivec
NSMutableArray *tempMarr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
if (tempMarr.count > 0) {
    
    [tempMarr removeObjectAtIndex:tempMarr.count-2];
    
    [self.navigationController setViewControllers:tempMarr animated:NO];
    
}

```

### 2. 将字符串中的字母转化为大写或小写

```
NSString *str = @"123abcABC";
str = [str uppercaseString]; //转化为大写
str = [str lowercaseString]; //转化为小写

```

### 3. 判断scrollView滑动方向

> 这里以判断左右滑动为例，判断上下滑动则将对应的x替换为y即可
> 

``` objectivec

@interface IntroduceViewController ()<UIScrollViewDelegate>
{
    CGFloat contentOffsetX;
    
    CGFloat oldContentOffsetX;
    
    CGFloat newContentOffsetX;
}


//开始拖拽视图

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    contentOffsetX = scrollView.contentOffset.x;
    
}

// 滚动时调用此方法(手指离开屏幕后)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    newContentOffsetX = scrollView.contentOffset.x;
    
    if (newContentOffsetX > oldContentOffsetX && oldContentOffsetX > contentOffsetX) {  // 向左滚动
        
        if (scrollView.contentOffset.x > (_imageArray.count - 1) * SCREEN_WIDTH) {
            [self gotoLoginVC];
        }
        
    }else if (newContentOffsetX < oldContentOffsetX && oldContentOffsetX < contentOffsetX) { // 向右滚动
        
    }else {
        
    }
    
    if (scrollView.dragging) {  // 拖拽

        if ((scrollView.contentOffset.x - contentOffsetX) > 5.0f) {  // 向左拖拽
            
            if (scrollView.contentOffset.x > (_imageArray.count - 1) * SCREEN_WIDTH) {
                [self gotoLoginVC];
            }
            
        }else if ((contentOffsetX - scrollView.contentOffset.x) > 5.0f) {   // 向右拖拽

        }else {

        }
        
    }
    
}

// 完成拖拽(滚动停止时调用此方法，手指离开屏幕前)
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    oldContentOffsetX = scrollView.contentOffset.x;
    
}


```