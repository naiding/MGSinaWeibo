//
//  MGSinaEngine.h
//  mySinaWeibo
//
//  Created by LEON on 14/10/22.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGWeiboModel.h"

/******************更改测试账号时需要修改以下三条内容*********************/

#define SINA_APP_KEY       @"2383111962"
#define SINA_APP_SECRET    @"ef24fd57f1be7f27f1ce5d55c7def81c"
#define SINA_REDIRECT_URI    @"http://www.powercam.us/"

/*********************************************************************/
#define HOSTURL @"https://api.weibo.com"
#define SINA_AUTHORIZE_URL   @"https://api.weibo.com/oauth2/authorize"
#define SINA_ACCESSTOKEN_URL @"https://api.weibo.com/oauth2/access_token"

#define SINA_ACCESS_TOKEN_KEY      @"SINAAccessTokenKey"
#define SINA_ACCESS_EXPIRES_IN_KEY @"SINAAccessExpiresInKey"
#define SINA_USER_ID_KEY           @"SINAUserIdKey"
#define SINA_USER_SCREEN_NAME      @"SINAUserScreenName"


#define SINA_USER_HEAD_IMAGE        @"USER_HEAD_IMAGE"
#define SINA_USER_BACKGROUND_IMAGE  @"USER_BACKGROUND_IMAGE"
#define SINA_USER_NAME              @"USER_NAME"
#define SINA_USER_FOLLOWING_COUNT   @"USER_FOLLOWING_COUNT"
#define SINA_USER_FOLLOWER_COUNT    @"USER_FOLLOWER_COUNT"
#define SINA_USER_STATUS_COUNT      @"USER_STATUS_COUNT"
#define SINA_USER_DESCRIPTION       @"USER_DESCRIPTION"
#define SINA_USER_LOCATION          @"USER_LOCATION"

@interface MGSinaEngine : NSObject

/**
 *	授权地址
 *
 *	@return     UIWebView所要加载的url
 */
+ (NSURL *)authorizeURL;



#pragma mark -
#pragma mark 关于登录和登出的接口

/**
 *	判断有没有登录过，并且获得到的token有没有过期
 *
 *	@return     YES 有可用的token ，并且没有过期; NO 没有可用的token
 */
+ (BOOL)isAuthorized;


/**
 *	保存登录信息
 *
 *	@param	aDic	字典中有access_token，exoires_in，uid等信息
 */
+ (void)saveLoginInfo:(NSDictionary *)aDic;



/**
 *	登出，清除当前账号的信息
 */
+ (void)logout;


/**
 *	根据用户ID获取用户信息
 *
 *	@param	uid         用户ID
 *  @param  isSuccess   block   请求成功的回调
 *                      BOOL    请求是否成功 YES or NO
 *                      User    返回的用户信息对象
 */
+ (void)getUserInfo:(NSString *)uid
            success:(void (^) (BOOL isSuccess, User *aUser))isSuccess;


/**
 *	获取当前登录用户及其所关注用户的最新微博
 *
 *	@param	sinceId     若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
 *	@param	maxId       若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
 *	@param	count       单页返回的记录条数，最大不超过100，默认为20。
 *	@param	page        返回结果的页码，默认为1。
 *	@param	feature     过滤类型ID，0：全部、1：原创、2：图片、3：视频、4：音乐，默认为0。
 *	@param	trimUser	返回值中user字段开关，0：返回完整user字段、1：user字段仅返回user_id，默认为0。
 *  @param  isSuccess   block           请求成功的回调
 *                      BOOL            请求是否成功 YES or NO
 *                      NSMutableArray  返回的微博信息数组
 */
+ (void)getStatusesWithSinceId:(int)sinceId
                         maxId:(int)maxId
                         count:(int)count
                          page:(int)page
                       feature:(int)feature
                      trimUser:(int)trimUser
                       success:(void (^) (BOOL isSuccess, NSMutableArray *array))isSuccess;


/**
 *	获取双向关注用户的最新微博
 *
 *	@param	sinceId     若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
 *	@param	maxId       若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
 *	@param	count       单页返回的记录条数，最大不超过100，默认为20。
 *	@param	page        返回结果的页码，默认为1。
 *	@param	feature     过滤类型ID，0：全部、1：原创、2：图片、3：视频、4：音乐，默认为0。
 *	@param	trimUser	返回值中user字段开关，0：返回完整user字段、1：user字段仅返回user_id，默认为0。
 *  @param  isSuccess   block           请求成功的回调
 *                      BOOL            请求是否成功 YES or NO
 *                      NSMutableArray  返回的微博信息数组
 */
+ (void)getBilateralStatusesWithSinceId:(int)sinceId
                                  maxId:(int)maxId
                                  count:(int)count
                                   page:(int)page
                                feature:(int)feature
                               trimUser:(int)trimUser
                                success:(void (^) (BOOL isSuccess, NSMutableArray *array))isSuccess;


#pragma mark -
#pragma mark 关于微博的接口

/**
 *  发送微博
 *
 *  @param  aContent    微博的文字内容
 *  @param  picData     如果同时要上传的图片，传入图片的NSData对象。仅支持JPEG、GIF、PNG格式，图片大小小于5M。如果只发送文字微博，则传入nil。
 *  @param  latFloat    纬度，有效范围：-90.0到+90.0，+表示北纬，默认为0.0。
 *  @param  longFloat   经度，有效范围：-180.0到+180.0，+表示东经，默认为0.0。
 *  @param  visible     微博的可见性，0：所有人能看，1：仅自己可见，2：密友可见，3：指定分组可见，默认为0。
 *  @param  listId      微博的保护投递指定分组ID，只有当visible参数为3时生效且必选。
 *  @param  isSuccess   block   请求成功的回调
 *                      BOOL    请求是否成功 YES or NO
 *                      Status  当前发送的微博内容
 */
+ (void)sendStatus:(NSString *)aContent
           picData:(NSData *)picData
          latFloat:(float)latFloat
         longFloat:(float)longFloat
           visible:(int)visible
            listId:(NSString *)listId
           success:(void (^) (BOOL isSuccess, Status *aStatus))isSuccess;

/**
 *	根据一个微博ID获取该微博内容
 *
 *	@param	Id     微博id
 *  @param  isSuccess   block           请求成功的回调
 *                      BOOL            请求是否成功 YES or NO
 */
+ (void)getOneStatusWithId:(int)Id
                   success:(void (^) (BOOL isSuccess, Status *aStatus))isSuccess;


/**
 *	获取用户最新微博的id
 *
 *	@param	sinceId     若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
 *	@param	maxId       若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
 *	@param	count       单页返回的记录条数，最大不超过100，默认为20。
 *	@param	page        返回结果的页码，默认为1。
 *	@param	feature     过滤类型ID，0：全部、1：原创、2：图片、3：视频、4：音乐，默认为0。
 *	@param	base_app	是否只获取当前应用的数据。0为否（所有数据），1为是（仅当前应用），默认为0。
 *  @param  isSuccess   block           请求成功的回调
 *                      BOOL            请求是否成功 YES or NO
 *                      NSMutableArray  返回的微博id数组
 */
+ (void)getUserNewestWeiboWithId:(NSString *)uid
                         sinceId:(int)sinceId
                           maxId:(int)maxId
                           count:(int)count
                            page:(int)page
                         feature:(int)feature
                         baseApp:(int)baseApp
                        trimUser:(int)trimUser
                         success:(void (^) (BOOL isSuccess, NSMutableArray *array))isSuccess;


/**
 *	添加一条微博到收藏 或者 取消收藏一条微博
 *
 *	@param	statusId	要收藏的微博ID。
 *	@param	flag        标示是添加收藏还是取消收藏 0:添加收藏 1：取消收藏
 *  @param  isSuccess   block   请求成功的回调
 *                      BOOL    请求是否成功 YES or NO
 *                      Status  当前收藏的微博内容
 */
+ (void)creatOrDestroyFavoriteWithStatusId:(NSString *)statusId
                                      flag:(int)flag
                                   success:(void (^) (BOOL isSuccess, Favorite *aFavorite))isSuccess;


/**
 *  转发一条微博
 *
 *  @param  statusId    要转发的微博ID。
 *  @param  aContent    添加的转发文本，必须做URLencode，内容不超过140个汉字，不填则默认为“转发微博”。
 *  @param  isComment   是否在转发的同时发表评论，0：否、1：评论给当前微博、2：评论给原微博、3：都评论，默认为0 。
 *  @param  isSuccess   block   请求成功的回调
 *                      BOOL    请求是否成功 YES or NO
 *                      Status  转发后的微博内容
 */
+ (void)repostStatusWithStatusId:(NSString *)statusId
                         content:(NSString *)aContent
                       isComment:(int)isComment
                         success:(void (^) (BOOL isSuccess, Status *aStatus))isSuccess;

/**
 *	对一条微博进行评论
 *
 *	@param	comment     评论内容,内容不超过140个汉字。
 *	@param	statusId	需要评论的微博ID。
 *	@param	commentOri	是否评论给原微博，0：否、1：是，默认为0。
 *  @param  isSuccess   block       请求成功的回调
 *                      BOOL        请求是否成功 YES or NO
 *                      Comment     返回的用户信息对象
 */
+ (void)creatComment:(NSString *)comment
            statusId:(NSString *)statusId
          commentOri:(int)commentOri
             success:(void (^) (BOOL isSuccess, Comment *aComment))isSuccess;


/**
 *	获取用户自己的最新微博
 *
 *	@param	sinceId     若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
 *	@param	maxId       若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
 *	@param	count       单页返回的记录条数，最大不超过100，默认为20。
 *	@param	page        返回结果的页码，默认为1。
 *	@param	feature     过滤类型ID，0：全部、1：原创、2：图片、3：视频、4：音乐，默认为0。
 *	@param	trimUser	返回值中user字段开关，0：返回完整user字段、1：user字段仅返回user_id，默认为0。
 *  @param  isSuccess   block           请求成功的回调
 *                      BOOL            请求是否成功 YES or NO
 *                      NSMutableArray  返回的微博信息数组
 */
//+ (void)getUserNewestWeibo:(int)sinceId
//                     maxId:(int)maxId
//                     count:(int)count
//                      page:(int)page
//                   feature:(int)feature
//                   baseApp:(int)baseApp
//                  trimUser:(int)trimUser
//                   success:(void (^) (BOOL isSuccess, NSMutableArray *array))isSuccess;

@end
