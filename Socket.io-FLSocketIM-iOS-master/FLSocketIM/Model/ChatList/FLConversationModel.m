//
//  FLConversationModel.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/14.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLConversationModel.h"

@implementation FLConversationModel

- (void)setLatestMessage:(FLMessageModel *)latestMessage {
    
    self.latestMsgTimeStamp = latestMessage.timestamp;
    self.latestMsgStr = [FLConversationModel getMessageStrWithMessage:latestMessage];
    
}

- (instancetype)initWithMessageModel:(FLMessageModel *)message conversationId:(NSString *)conversationId{
    if (self = [super init]) {
        
        self.latestMessage = message;
        self.userName = conversationId;
    }
    return self;
}


+ (NSString *)getMessageStrWithMessage:(FLMessageModel *)message {
    
    NSString *latestMsgStr;
    switch (message.type) {
        case FLMessageText:
            latestMsgStr = message.bodies.msg;
            break;
            
        case FLMessageImage:
            latestMsgStr = @"[图片]";
            break;
            
        case FLMessageLoc:
            latestMsgStr = @"[定位]";
            break;
            
        case FlMessageAudio:
            latestMsgStr = @"[语音]";
            break;
            
        case FLMessageVideo:
            latestMsgStr = @"[视频]";
            break;
            
        case FLMessageOther:
            latestMsgStr = @"[其他]";
            break;
            
        default:
            latestMsgStr = @"错误";
            break;
    }
    return latestMsgStr;
}

@end
