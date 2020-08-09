//
//  WordListView.h
//  keyboard
//
//  Created by everettjf on 2019/8/29.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WordListView;
@protocol WordListViewDelegate <NSObject>

- (void)wordListView:(WordListView*)view wordsTapped:(NSString*)words;

@end

@interface WordListView : UIView

@property (nonatomic,strong) id<WordListViewDelegate> delegate;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
