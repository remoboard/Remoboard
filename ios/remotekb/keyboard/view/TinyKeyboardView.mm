//
//  TinyKeyboardView.mm
//  QVKeyboard
//
//  Created by everettjf on 2018/10/19.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "TinyKeyboardView.h"
#include <string>
#include <vector>
#import <Masonry.h>
#include <unordered_map>

enum class KeyType{
    Number,
    Letter,
    Special,
};

struct KeyItem{
    KeyType type;
    std::string lowercase;
    std::string uppercase;
};


std::vector<std::vector<KeyItem>> getKeys(){
    std::vector<std::vector<KeyItem>> keys;
    {
        std::vector<KeyItem> strokes;
        for(auto c : std::string("1234567890")){
            KeyItem item;
            item.type = KeyType::Number;
            item.lowercase = std::string(1,c);
            item.uppercase = item.lowercase;
            strokes.push_back(item);
        }
        strokes.push_back(KeyItem {KeyType::Special,"bak","BAK"});
        keys.push_back(strokes);
    }
    
    {
        std::vector<KeyItem> strokes;
        for(auto c : std::string("qwertyuiop")){
            KeyItem item;
            item.type = KeyType::Letter;
            item.lowercase = std::string(1,c);
            item.uppercase = std::string(1,toupper(c));
            strokes.push_back(item);
        }
        keys.push_back(strokes);
    }

    {
        std::vector<KeyItem> strokes;
        for(auto c : std::string("asdfghjkl")){
            KeyItem item;
            item.type = KeyType::Letter;
            item.lowercase = std::string(1,c);
            item.uppercase = std::string(1,toupper(c));
            strokes.push_back(item);
        }
        keys.push_back(strokes);
    }


    {
        std::vector<KeyItem> strokes;
        strokes.push_back(KeyItem {KeyType::Special,"sft","SFT"});
        for(auto c : std::string("zxcvbnm")){
            KeyItem item;
            item.type = KeyType::Letter;
            item.lowercase = std::string(1,c);
            item.uppercase = std::string(1,toupper(c));
            strokes.push_back(item);
        }
        strokes.push_back(KeyItem {KeyType::Special,"spc","SPC"});
        keys.push_back(strokes);
    }
    return keys;
}

@interface TinyKeyboardView ()
{
    std::unordered_map<uint64_t, KeyItem> _buttonMap;
    NSMutableArray<UIButton*> *_buttons;
    BOOL _shiftMode;
}

@end

@implementation TinyKeyboardView

- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow{
    [super willMoveToWindow:newWindow];
    
    if(newWindow){
        [self buildUI];
    }
}

- (void)buildUI{
    std::vector<std::vector<KeyItem>> keys = getKeys();
    
    _buttons = [[NSMutableArray alloc]init];
    static int colorIdx = 0;

    UIView * topView = nil;
    for(int rowIdx = 0; rowIdx < keys.size(); ++rowIdx) {
        bool isFirstRow = rowIdx == 0;
        bool isLastRow = rowIdx == keys.size() - 1;
        auto & row = keys[rowIdx];
        
        colorIdx = 0;
        
        UIView * leftView = nil;
        for(int colIdx = 0; colIdx < row.size(); ++colIdx) {
            KeyItem & key = row[colIdx];
            bool isFirstCol = colIdx == 0;
            bool isLastCol = colIdx == row.size() - 1;
            
            UIButton *button = [[UIButton alloc] init];
            [button setTitle:[NSString stringWithUTF8String:key.lowercase.c_str()] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(keyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            _buttonMap[(uint64_t)button] = key;
            [_buttons addObject:button];
            
            colorIdx += 1;
            if((rowIdx + colorIdx) % 2 == 0){
                button.backgroundColor = TinyKeyboardViewColor1;
            }else{
                button.backgroundColor = TinyKeyboardViewColor2;
            }
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            if (isFirstRow) {
                if (isFirstCol) {
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(self.mas_left);
                        make.top.equalTo(self.mas_top);
                    }];
                    topView = button;
                } else if (isLastCol) {
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.right.equalTo(self.mas_right);
                        make.top.equalTo(leftView.mas_top);
                        make.width.equalTo(leftView.mas_width);
                        make.height.equalTo(leftView.mas_height);
                        make.left.equalTo(leftView.mas_right);
                    }];
                } else {
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(leftView.mas_right);
                        make.top.equalTo(leftView.mas_top);
                        make.width.equalTo(leftView.mas_width);
                        make.height.equalTo(leftView.mas_height);
                    }];
                }
            } else if (isLastRow) {
                if (isFirstCol) {
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(topView.mas_bottom);
                        make.left.equalTo(self.mas_left);
                        make.bottom.equalTo(self.mas_bottom);
                        make.height.equalTo(topView.mas_height);
                    }];
                    topView = button;
                } else if (isLastCol) {
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(leftView.mas_right);
                        make.right.equalTo(self.mas_right);
                        make.bottom.equalTo(self.mas_bottom);
                        make.height.equalTo(leftView.mas_height);
                        make.width.equalTo(leftView.mas_width);
                    }];
                } else {
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(leftView.mas_right);
                        make.top.equalTo(leftView.mas_top);
                        make.height.equalTo(leftView.mas_height);
                        make.width.equalTo(leftView.mas_width);
                    }];
                }
            } else {
                // other row : 2 & 3
                if (isFirstCol) {
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(self.mas_left);
                        make.top.equalTo(topView.mas_bottom);
                        make.height.equalTo(topView.mas_height);
                    }];
                    topView = button;
                } else if (isLastCol) {
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(leftView.mas_right);
                        make.top.equalTo(leftView.mas_top);
                        make.width.equalTo(leftView.mas_width);
                        make.height.equalTo(leftView.mas_height);
                        make.right.equalTo(self.mas_right);
                    }];
                } else {
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(leftView.mas_right);
                        make.top.equalTo(leftView.mas_top);
                        make.width.equalTo(leftView.mas_width);
                        make.height.equalTo(leftView.mas_height);
                    }];
                }
            }
            
            leftView = button;
        }
    }
}

- (void)keyButtonTapped:(UIButton*)sender{
    auto findit = _buttonMap.find((uint64_t)sender);
    if(findit == _buttonMap.end()){
        return;
    }
    
    KeyItem key = findit->second;
    switch (key.type) {
        case KeyType::Number:
        case KeyType::Letter:{
            [self onCharacterKeyTapped:key];
            break;
        }
        case KeyType::Special:{
            [self onSpecialKeyTapped:key];
            break;
        }
        default:
            break;
    }
    
    UIImpactFeedbackGenerator *feedBackGenertor = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [feedBackGenertor impactOccurred];
}

- (void)onCharacterKeyTapped:(const KeyItem & )key{
    std::string keyCurrent;
    if(_shiftMode){
        keyCurrent = key.uppercase;
    }else{
        keyCurrent = key.lowercase;
    }

    NSString *keyValue = [NSString stringWithUTF8String:keyCurrent.c_str()];
    if(self.delegate){
        [self.delegate TinyKeyboardView:self characterTapped:keyValue];
    }
}
- (void)onSpecialKeyTapped:(const KeyItem & )key{
    if(key.lowercase == "sft"){
        _shiftMode = !_shiftMode;
        // Refresh UI
        [self refreshButtonText];
    }else if(key.lowercase == "spc"){
        if(self.delegate){
            [self.delegate TinyKeyboardView:self characterTapped:@" "];
        }
    }else if(key.lowercase == "bak"){
        if(self.delegate){
            [self.delegate TinyKeyboardView:self specialTapped:@"bak"];
        }
    }else{
        
    }
}

- (void)refreshButtonText{
    for(UIButton *button in _buttons){
        auto findit = _buttonMap.find((uint64_t)button);
        if(findit == _buttonMap.end()){
            continue;
        }
        KeyItem key = findit->second;
        NSString *text;
        if(_shiftMode){
            text = [NSString stringWithUTF8String:key.uppercase.c_str()];
        }else{
            text = [NSString stringWithUTF8String:key.lowercase.c_str()];
        }
        
        [button setTitle:text forState:UIControlStateNormal];
    }
}

@end
