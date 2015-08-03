/*
 Copyright 2015 OpenMarket Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MXKPushRuleTableViewCell.h"

#import "NSBundle+MatrixKit.h"

@implementation MXKPushRuleTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _controlButton.backgroundColor = [UIColor clearColor];
    [_controlButton setImage:[NSBundle mxk_imageFromMXKAssetsBundleWithName:@"icon_pause"] forState:UIControlStateNormal];
    [_controlButton setImage:[NSBundle mxk_imageFromMXKAssetsBundleWithName:@"icon_pause"] forState:UIControlStateHighlighted];
    
    _deleteButton.backgroundColor = [UIColor clearColor];
    [_deleteButton setImage:[NSBundle mxk_imageFromMXKAssetsBundleWithName:@"icon_minus"] forState:UIControlStateNormal];
    [_deleteButton setImage:[NSBundle mxk_imageFromMXKAssetsBundleWithName:@"icon_minus"] forState:UIControlStateHighlighted];
}

- (void)setMxPushRule:(MXPushRule *)mxPushRule
{
    // Set the right control icon
    if (mxPushRule.enabled)
    {
        [_controlButton setImage:[NSBundle mxk_imageFromMXKAssetsBundleWithName:@"icon_pause"] forState:UIControlStateNormal];
        [_controlButton setImage:[NSBundle mxk_imageFromMXKAssetsBundleWithName:@"icon_pause"] forState:UIControlStateHighlighted];
    }
    else
    {
        [_controlButton setImage:[NSBundle mxk_imageFromMXKAssetsBundleWithName:@"icon_play"] forState:UIControlStateNormal];
        [_controlButton setImage:[NSBundle mxk_imageFromMXKAssetsBundleWithName:@"icon_play"] forState:UIControlStateHighlighted];
    }
    
    // Prepare rule description (use rule id by default)
    NSString *description = mxPushRule.ruleId;
    
    switch (mxPushRule.kind)
    {
        case MXPushRuleKindContent:
            description = mxPushRule.pattern;
            break;
        case MXPushRuleKindRoom:
        {
            MXRoom *room = [_mxSession roomWithRoomId:mxPushRule.ruleId];
            if (room)
            {
                description = [NSString stringWithFormat:@"Room: '%@'", room.state.displayname];
            }
            break;
        }
        default:
            break;
    }
    
    _ruleDescription.text = description;
    
    // Delete button and rule actions are hidden for predefined rules
    if (mxPushRule.isDefault)
    {
        if (!_deleteButton.hidden)
        {
            _deleteButton.hidden = YES;
            // Adjust layout by updating constraint
            _ruleDescriptionLeftConstraint.constant -= _deleteButtonWidthConstraint.constant;
        }
        
        if (!_ruleActions.isHidden)
        {
            _ruleActions.hidden = YES;
            // Adjust layout by updating constraint
            _ruleDescriptionBottomConstraint.constant -= _ruleActionsHeightConstraint.constant;
        }
    }
    else
    {
        if (_deleteButton.hidden)
        {
            _deleteButton.hidden = NO;
            // Adjust layout by updating constraint
            _ruleDescriptionLeftConstraint.constant += _deleteButtonWidthConstraint.constant;
        }
        
        // Prepare rule actions description
        NSString *notify;
        NSString *sound = @"";
        NSString *highlight = @"";
        for (MXPushRuleAction *ruleAction in mxPushRule.actions)
        {
            if (ruleAction.actionType == MXPushRuleActionTypeDontNotify)
            {
                notify = @"Never notify";
                sound = @"";
                highlight = @"";
                break;
            }
            else if (ruleAction.actionType == MXPushRuleActionTypeNotify || ruleAction.actionType == MXPushRuleActionTypeCoalesce)
            {
                notify = @"Always notify";
            }
            else if (ruleAction.actionType == MXPushRuleActionTypeSetTweak)
            {
                if ([ruleAction.parameters[@"set_tweak"] isEqualToString:@"sound"])
                {
                    sound = @", Custom sound";
                }
                else if ([ruleAction.parameters[@"set_tweak"] isEqualToString:@"highlight"])
                {
                    // Check the highlight tweak "value"
                    // If not present, highlight. Else check its value before highlighting
                    if (nil == ruleAction.parameters[@"value"] || YES == [ruleAction.parameters[@"value"] boolValue])
                    {
                        highlight = @", Highlight";
                    }
                }
            }
        }
        
        if (notify.length)
        {
            _ruleActions.text = [NSString stringWithFormat:@"%@%@%@", notify, sound, highlight];
        }
        
        if (_ruleActions.isHidden)
        {
            _ruleActions.hidden = NO;
            // Adjust layout by updating constraint
            _ruleDescriptionBottomConstraint.constant += _ruleActionsHeightConstraint.constant;
        }
    }
    
    _mxPushRule = mxPushRule;
}

- (IBAction)onButtonPressed:(id)sender
{
    if (sender == _controlButton)
    {
        // Swap enable state
        [_mxSession.notificationCenter enableRule:_mxPushRule isEnabled:!_mxPushRule.enabled];
    }
    else if (sender == _deleteButton)
    {
        [_mxSession.notificationCenter removeRule:_mxPushRule];
    }
}

@end
