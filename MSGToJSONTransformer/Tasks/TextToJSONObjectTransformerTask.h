//
//  TextToJSONObjectTransformerTask.h
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/23/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "TaskProvider.h"
#import "ChatMsgObject.h"

/**
 Providing a string it parses the mentions, emoticons and links as described in http://help.hipchat.com/knowledgebase/articles/64429-how-do-mentions-work- and https://www.hipchat.com/emoticons.
 The resultant task result contains ChatMsgObject;
If any error occurrs the consumer of this class should handle that which can be detected by observing task's error property.
 */
@interface TextToJSONObjectTransformerTask : NSObject<TaskProvider>

/**
 *
 *  @param text a string to convert into json.
 *
 */
-(instancetype)initWithText:(NSString*)text;

@end


@interface TextToJSONObjectTransformerTask (CompositeTask)
/**
 *  Given a URL the task provides the title of the url. Internally it uses FetchHTMLPageContentTask and ParseHTMLPageTask
 *  in order to perform the task. If any error occurs (i.e. network issue) the title for that url is given as an empty string.
 *
 *  @param url to fetch the title.
 *
 *  @return A task contains the result LinkObject.
 */
+(ChainableTask*)taskForPageTitleForURL:(NSURL*)url;

/**
 *  Given a text it performs regular expression matching for finding mentions. Mentions are defined here http://help.hipchat.com/knowledgebase/articles/64429-how-do-mentions-work-.
 *
 *  @param text text
 *
 *  @return returns a task having the result as an set containing unique mentions
 */
+(ChainableTask*)taskForEmoticonsForText:(NSString*)text;

/**
 *  Given a text it performs regular expression matching for finding emoticons. Emoticons are defined here https://www.hipchat.com/emoticons.
 *  They are alphanumeric and 1 to 15 char long.
 *
 *  @param text text
 *
 *  @return returns a task having the result as an set containing unique emoticons
 */
+(ChainableTask*)taskForMentionsForText:(NSString*)text;

@end



