//
//  ChatCell.m
//  LMeet
//
//  Created by Hicham Abou Jaoude on 1/18/2014.
//  Copyright (c) 2014 Hicham Abou Jaoude. All rights reserved.
//

#import "ChatCell.h"

@implementation ChatCell
@synthesize nameLabel = _nameLabel;
@synthesize textView = _textView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGSize)sizeThatFits:(CGSize)size;
{
    CGSize textViewSize = _textView.bounds.size;
    CGSize fitTextViewSize = CGSizeMake(textViewSize.width, size.height);
    CGSize sizeThatFitsSize = [self.textView sizeThatFits:fitTextViewSize];
    
    CGSize superSize = [super sizeThatFits:size];
    
    sizeThatFitsSize.height = MAX(superSize.height, sizeThatFitsSize.height);
    sizeThatFitsSize.width = superSize.width;
    
    return sizeThatFitsSize;
}

@end
