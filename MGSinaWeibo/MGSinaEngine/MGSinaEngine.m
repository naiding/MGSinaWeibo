//
//  MGSinaEngine.m
//  mySinaWeibo
//
//  Created by LEON on 14/10/22.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import "MGSinaEngine.h"
#import "MGWeiboModel.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@implementation MGSinaEngine

/**
 *	授权地址
 *
 *	@return     UIWebView所要加载的url
 */
+ (NSURL *)authorizeURL
{
    NSString *authStr = [NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=%@&display=%@",SINA_AUTHORIZE_URL,SINA_APP_KEY,SINA_REDIRECT_URI,@"code",@"mobile"];
    return [NSURL URLWithString:authStr];
}

#pragma mark -
#pragma mark 关于登录和登出的接口

/**
 *	判断有没有登录过，并且获得到的token有没有过期
 *
 *	@return     YES 有可用的token ，并且没有过期; NO 没有可用的token
 */
+ (BOOL)isAuthorized
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_TOKEN_KEY];
    NSDate *expiresDate = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_EXPIRES_IN_KEY];
    
    if (expiresDate)
    {
        return  ( NSOrderedDescending == [expiresDate compare:[NSDate date]] && accessToken);
    }
    return NO;
}



/**
 *	保存登录信息
 *
 *	@param	aDic	字典中有access_token，exoires_in，uid等信息
 */
+ (void)saveLoginInfo:(NSDictionary *)aDic
{
    [[NSUserDefaults standardUserDefaults] setObject:[aDic objectForKey:@"access_token"] forKey:SINA_ACCESS_TOKEN_KEY];
    NSDate *expiresDate = [NSDate dateWithTimeIntervalSinceNow:[[aDic objectForKey:@"expires_in"] intValue]];
    [[NSUserDefaults standardUserDefaults] setObject:expiresDate forKey:SINA_ACCESS_EXPIRES_IN_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:[aDic objectForKey:@"uid"] forKey:SINA_USER_ID_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:[aDic objectForKey:@"screen_name"]forKey:@"SINA_USER_SCREEN_NAME"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    NSLog(@"%@",aDic);
    
}



/**
 *	登出，清除当前账号的信息
 */
+ (void)logout
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [storage cookiesForURL:[NSURL URLWithString:@"https://api.weibo.com"]];
    for (NSHTTPCookie *each in cookies)
        [storage deleteCookie:each];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINA_ACCESS_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINA_ACCESS_EXPIRES_IN_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINA_USER_ID_KEY];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINA_USER_HEAD_IMAGE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINA_USER_BACKGROUND_IMAGE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINA_USER_NAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINA_USER_FOLLOWER_COUNT];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINA_USER_FOLLOWING_COUNT];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINA_USER_STATUS_COUNT];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINA_USER_DESCRIPTION];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINA_USER_LOCATION];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    
}

/**
 *	根据用户ID获取用户信息
 *
 *	@param	uid         用户ID
 *  @param  isSuccess   block   请求成功的回调
 *                      BOOL    请求是否成功 YES or NO
 *                      User    返回的用户信息对象
 */
+ (void)getUserInfo:(NSString *)uid
            success:(void (^) (BOOL isSuccess, User *aUser))isSuccess
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_TOKEN_KEY];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:uid forKey:@"uid"];
    [dic setObject:accessToken forKey:@"access_token"];
    
    NSString *URL = [[NSString alloc] initWithFormat:@"%@/2/users/show.json",HOSTURL];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:URL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *doubi = responseObject;

        NSError *error;
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:doubi options:NSJSONReadingMutableLeaves error:&error];
    
        User *user = [User getUserFromJsonDic:userInfo];
        isSuccess(YES, user);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"!!Error: %@", error);
    }];
}



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
                       success:(void (^) (BOOL isSuccess, NSMutableArray *array))isSuccess
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_TOKEN_KEY];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:accessToken forKey:@"access_token"];
    [dic setObject:[NSString stringWithFormat:@"%d",sinceId]  forKey:@"since_id"];
    [dic setObject:[NSString stringWithFormat:@"%d",maxId] forKey:@"max_id"];
    [dic setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
    [dic setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
    [dic setObject:[NSString stringWithFormat:@"%d",feature] forKey:@"feature"];
    [dic setObject:[NSString stringWithFormat:@"%d",trimUser] forKey:@"trim_user"];
    
    NSString *URL = [[NSString alloc] initWithFormat:@"%@/2/statuses/home_timeline.json",HOSTURL];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:URL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *doubi = responseObject;
        
        NSError *error;
        NSDictionary *user = [NSJSONSerialization JSONObjectWithData:doubi options:NSJSONReadingMutableLeaves error:&error];
        //NSLog(@"%@",user);
        
        NSArray *array = [user objectForKey:@"statuses"];
        NSMutableArray *statusArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSDictionary *dic in array) {
            Status *status = [Status getStatusFromJsonDic:dic];
            [statusArray addObject:status];
        }
        isSuccess(YES, statusArray);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"!!Error: %@", error);
        isSuccess(NO,nil);
    }];
}


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
                                success:(void (^) (BOOL isSuccess, NSMutableArray *array))isSuccess
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_TOKEN_KEY];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:accessToken forKey:@"access_token"];
    [dic setObject:[NSString stringWithFormat:@"%d",sinceId] forKey:@"since_id"];
    [dic setObject:[NSString stringWithFormat:@"%d",maxId] forKey:@"max_id"];
    [dic setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
    [dic setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
    [dic setObject:[NSString stringWithFormat:@"%d",feature] forKey:@"feature"];
    [dic setObject:[NSString stringWithFormat:@"%d",trimUser] forKey:@"trim_user"];
    
    NSString *URL = [[NSString alloc] initWithFormat:@"%@/2/statuses/bilateral_timeline.json",HOSTURL];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:URL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *doubi = responseObject;
        
        NSError *error;
        NSDictionary *user = [NSJSONSerialization JSONObjectWithData:doubi options:NSJSONReadingMutableLeaves error:&error];
        
        //NSLog(@"%@",user);
        NSArray *array = [user objectForKey:@"statuses"];
        NSMutableArray *statusArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSDictionary *dic in array) {
            Status *status = [Status getStatusFromJsonDic:dic];
            [statusArray addObject:status];
        }
        
        isSuccess(YES, statusArray);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        isSuccess(NO,nil);
        NSLog(@"!!Error: %@", error);
    }];
}

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
+ (void)getUserNewestWeiboWithId:(NSString *)uid
                         sinceId:(int)sinceId
                           maxId:(int)maxId
                           count:(int)count
                            page:(int)page
                         feature:(int)feature
                         baseApp:(int)baseApp
                        trimUser:(int)trimUser
                         success:(void (^) (BOOL isSuccess, NSMutableArray *array))isSuccess
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_TOKEN_KEY];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:accessToken forKey:@"access_token"];
    [dic setObject:uid forKey:@"uid"];
    [dic setObject:[NSString stringWithFormat:@"%d",sinceId] forKey:@"since_id"];
    [dic setObject:[NSString stringWithFormat:@"%d",maxId] forKey:@"max_id"];
    [dic setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
    [dic setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
    [dic setObject:[NSString stringWithFormat:@"%d",feature] forKey:@"feature"];
    [dic setObject:[NSString stringWithFormat:@"%d",trimUser] forKey:@"trim_user"];
    [dic setObject:[NSString stringWithFormat:@"%d",baseApp] forKey:@"base_app"];
    
    NSString *URL = [[NSString alloc] initWithFormat:@"%@/2/statuses/user_timeline.json",HOSTURL];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:URL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *doubi = responseObject;
        
        NSError *error;
        NSDictionary *user = [NSJSONSerialization JSONObjectWithData:doubi options:NSJSONReadingMutableLeaves error:&error];
        
        //NSLog(@"%@",user);
        NSArray *array = [user objectForKey:@"statuses"];
        NSMutableArray *statusArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSDictionary *dic in array) {
            Status *status = [Status getStatusFromJsonDic:dic];
            [statusArray addObject:status];
        }
        
        isSuccess(YES, statusArray);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        isSuccess(NO,nil);
        NSLog(@"!!Error: %@", error);
    }];
}



/**
 *	根据一个微博ID获取该微博内容
 *
 *	@param	Id     微博id
 *  @param  isSuccess   block           请求成功的回调
 *                      BOOL            请求是否成功 YES or NO
 */
+ (void)getOneStatusWithId:(NSString *)Id
                   success:(void (^) (BOOL isSuccess, Status *aStatus))isSuccess
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_TOKEN_KEY];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:accessToken forKey:@"access_token"];
    [dic setObject:Id forKey:@"id"];
    
    NSString *URL = [[NSString alloc] initWithFormat:@"%@/2/statuses/show.json",HOSTURL];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:URL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *doubi = responseObject;
        
        NSError *error;
        NSDictionary *user = [NSJSONSerialization JSONObjectWithData:doubi options:NSJSONReadingMutableLeaves error:&error];
        //NSLog(@"%@",user);
        Status *status = [Status getStatusFromJsonDic:user];
        isSuccess(YES,status);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"!!Error: %@", error);
        isSuccess(NO,nil);
    }];
}

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
+ (void)getUserStatusesId:(int)sinceId
                    maxId:(int)maxId
                    count:(int)count
                     page:(int)page
                  feature:(int)feature
                  baseApp:(int)baseApp
                  success:(void (^) (BOOL isSuccess, NSMutableArray *array))isSuccess
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_TOKEN_KEY];
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_USER_ID_KEY];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:accessToken forKey:@"access_token"];
    [dic setObject:uid forKey:@"uid"];
    //[dic setObject:screenName forKey:@"screen_name"];
    [dic setObject:[NSString stringWithFormat:@"%d",sinceId] forKey:@"since_id"];
    [dic setObject:[NSString stringWithFormat:@"%d",maxId] forKey:@"max_id"];
    [dic setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
    [dic setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
    [dic setObject:[NSString stringWithFormat:@"%d",feature] forKey:@"feature"];
    [dic setObject:[NSString stringWithFormat:@"%d",baseApp] forKey:@"base_app"];
    
    NSString *URL = [[NSString alloc] initWithFormat:@"%@/2/statuses/user_timeline/ids.json",HOSTURL];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:URL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *doubi = responseObject;
        
        NSError *error;
        NSDictionary *user = [NSJSONSerialization JSONObjectWithData:doubi options:NSJSONReadingMutableLeaves error:&error];

        NSMutableArray *IdArray = [[NSMutableArray alloc] init];
        for (NSString *ID in [user objectForKey:@"statuses"])
        {
            [IdArray addObject:ID];
        }
        isSuccess(YES,IdArray);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        isSuccess(NO,nil);
        NSLog(@"!!Error: %@", error);
    }];
}


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
           success:(void (^) (BOOL isSuccess, Status *aStatus))isSuccess
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_TOKEN_KEY];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:accessToken forKey:@"access_token"];
    [dic setObject:aContent forKey:@"status"];
    if (latFloat != 0 && longFloat != 0) {
        [dic setObject:[NSString stringWithFormat:@"%f",latFloat] forKey:@"lat"];
        [dic setObject:[NSString stringWithFormat:@"%f",longFloat] forKey:@"long"];
    }
    [dic setObject:[NSString stringWithFormat:@"%d",visible] forKey:@"visible"];
    if (visible == 3) {
        [dic setObject:listId forKey:@"list_id"];
    }
    if (picData != nil) {
        [dic setObject:picData forKey:@"pic"];
    }
    
    if (picData == nil) {
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];

        
        NSString *URL = [[NSString alloc] initWithFormat:@"%@/2/statuses/update.json",HOSTURL];
        
        [manager POST:URL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
           
            NSData *doubi = responseObject;
            NSError *error;
            NSDictionary *user = [NSJSONSerialization JSONObjectWithData:doubi options:NSJSONReadingMutableLeaves error:&error];
            
            NSLog(@"%@",user);

            Status *status = [Status getStatusFromJsonDic:user];
            isSuccess(YES, status);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            isSuccess(NO,nil);
            NSLog(@"!!Error: %@", error);
        }];
    }
    else
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        manager.requestSerializer.timeoutInterval = 60;
        
        NSString *URL = [[NSString alloc] initWithFormat:@"https://upload.api.weibo.com/2/statuses/upload.json"];
        
        [manager POST:URL parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            NSData *data = picData;
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            
            // 设置时间格式
            
            formatter.dateFormat = @"yyyyMMddHHmmss";
            
            NSString *str = [formatter stringFromDate:[NSDate date]];
            
            NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
            
            [formData appendPartWithFileData:data name:@"logo_img" fileName:fileName mimeType:@"image/png"];
            
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        
//        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
//        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//        
//        NSString *URL = [[NSString alloc] initWithFormat:@"https://upload.api.weibo.com/2/statuses/upload.json"];
//        
//        [manager POST:URL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            
//            NSData *doubi = responseObject;
//            NSError *error;
//            NSDictionary *user = [NSJSONSerialization JSONObjectWithData:doubi options:NSJSONReadingMutableLeaves error:&error];
//            
//            Status *status = [Status getStatusFromJsonDic:user];
//            isSuccess(YES, status);
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            isSuccess(NO,nil);
//            NSLog(@"!!Error: %@", error);
//        }];
    }
}


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
                                   success:(void (^) (BOOL isSuccess, Favorite *aFavorite))isSuccess
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_TOKEN_KEY];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:accessToken forKey:@"access_token"];
    [dic setObject:statusId forKey:@"id"];
    
    NSString *URL = [[NSString alloc]init];
    if (flag) {
        URL = @"https://api.weibo.com/2/favorites/create.json";
    }
    else
    {
        URL = @"https://api.weibo.com/2/favorites/destroy.json";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:URL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *doubi = responseObject;
        
        NSError *error;
        NSDictionary *user = [NSJSONSerialization JSONObjectWithData:doubi options:NSJSONReadingMutableLeaves error:&error];
        
        Favorite *favorite = [Favorite getFavoriteFromJsonDic:user];
        isSuccess(YES,favorite);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        isSuccess(NO,nil);
        NSLog(@"!!Error: %@", error);
    }];
}



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
                         success:(void (^) (BOOL isSuccess, Status *aStatus))isSuccess
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_TOKEN_KEY];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:accessToken forKey:@"access_token"];
    [dic setObject:statusId forKey:@"id"];
    [dic setObject:aContent forKey:@"status"];
    [dic setObject:[NSString stringWithFormat:@"%d",isComment] forKey:@"is_comment"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
    NSString *URL = [[NSString alloc] initWithFormat:@"%@/2/statuses/repost.json",HOSTURL];
    
    [manager POST:URL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData *doubi = responseObject;
        NSError *error;
        NSDictionary *user = [NSJSONSerialization JSONObjectWithData:doubi options:NSJSONReadingMutableLeaves error:&error];
        
        Status *status = [Status getStatusFromJsonDic:user];
        isSuccess(YES, status);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        isSuccess(NO,nil);
        NSLog(@"!!Error: %@", error);
    }];
}


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
             success:(void (^) (BOOL isSuccess, Comment *aComment))isSuccess
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_TOKEN_KEY];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:accessToken forKey:@"access_token"];
    [dic setObject:comment forKey:@"comment"];
    [dic setObject:statusId forKey:@"id"];
    [dic setObject:[NSString stringWithFormat:@"%d",commentOri] forKey:@"comment_ori"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
    NSString *URL = [[NSString alloc] initWithFormat:@"%@/2/comments/create.json",HOSTURL];
    
    [manager POST:URL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData *doubi = responseObject;
        NSError *error;
        NSDictionary *user = [NSJSONSerialization JSONObjectWithData:doubi options:NSJSONReadingMutableLeaves error:&error];
        
        Comment *comment = [Comment getCommentFromJsonDic:user];
        isSuccess(YES, comment);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        isSuccess(NO,nil);
        NSLog(@"!!Error: %@", error);
    }];
}



///**
// *  根据微博ID删除指定微博
// *
// *  @param  statusId    需要删除的微博ID。
// *  @param  isSuccess   block   请求成功的回调
// *                      BOOL    请求是否成功 YES or NO
// *                      Status  当前收藏的微博内容
// */
//+ (void)destroyStatusWithStatusId:(NSString *)statusId
//                          success:(void (^) (BOOL isSuccess, Status *aStatus))isSuccess
//{
//    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_TOKEN_KEY];
//    
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setObject:accessToken forKey:@"access_token"];
//    [dic setObject:statusId forKey:@"id"];
//    
//    [HttpBaseModel getDataResponseHostName:HOSTURL Path:@"2/statuses/destroy.json" params:dic httpMethod:@"POST" onCompletion:^(NSData *responseData){
//        
//        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"responseString = %@", responseString);
//        
//        SBJSON *json = [[SBJSON alloc] init];
//        NSError *error = nil;
//        NSDictionary *jsonDic = [json objectWithString:responseString error:&error];
//        
//        Status *aStatus = [Status getStatusFromJsonDic:jsonDic];
//        isSuccess(YES, aStatus);
//        
//        [json release];
//        [responseString release];
//    } onError:^(NSError *error){
//        isSuccess(NO, nil);
//    }];
//}
//
//
//
///**
// *  获取某个用户最新发表的微博列表
// *
// *  @param  uid         需要查询的用户ID。参数uid与screen_name二者必选其一，且只能选其一；
// *  @param  screenName  需要查询的用户昵称。
// *  @param  sinceId     若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
// *  @param  maxId       若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
// *  @param  count       单页返回的记录条数，最大不超过100，默认为20。
// *  @param  page        返回结果的页码，默认为1。
// *  @param  feature     过滤类型ID，0：全部、1：原创、2：图片、3：视频、4：音乐，默认为0。
// *  @param  trimUser    返回值中user字段开关，0：返回完整user字段、1：user字段仅返回user_id，默认为0。
// *  @param  isSuccess   block           请求成功的回调
// *                      BOOL            请求是否成功 YES or NO
// *                      NSMutableArray  返回的微博信息数组
// */
//+ (void)getStatusesWithUId:(NSString *)uId
//              orScreenName:(NSString *)screenName
//                   sinceId:(int)sinceId
//                     maxId:(int)maxId
//                     count:(int)count
//                      page:(int)page
//                   feature:(int)feature
//                  trimUser:(int)trimUser
//                   success:(void (^) (BOOL isSuccess, NSMutableArray *array))isSuccess
//{
//    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_TOKEN_KEY];
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setObject:accessToken forKey:@"access_token"];
//    if (uId != nil && ![uId isEqualToString:@""]) {
//        [dic setObject:uId forKey:@"uid"];
//    }
//    else{
//        [dic setObject:screenName forKey:@"screen_name"];
//    }
//    [dic setObject:[NSString stringWithFormat:@"%d",sinceId] forKey:@"since_id"];
//    [dic setObject:[NSString stringWithFormat:@"%d",maxId] forKey:@"max_id"];
//    [dic setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
//    [dic setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
//    [dic setObject:[NSString stringWithFormat:@"%d",feature] forKey:@"feature"];
//    [dic setObject:[NSString stringWithFormat:@"%d",trimUser] forKey:@"trim_user"];
//    
//    [HttpBaseModel getDataResponseHostName:HOSTURL Path:@"2/statuses/user_timeline.json" params:dic httpMethod:@"GET" onCompletion:^(NSData *responseData){
//        
//        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"responseString = %@", responseString);
//        
//        SBJSON *json = [[SBJSON alloc] init];
//        NSError *error = nil;
//        NSDictionary *jsonDic = [json objectWithString:responseString error:&error];
//        
//        NSArray *array = [jsonDic objectForKey:@"statuses"];
//        NSMutableArray *statusArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
//        for (NSDictionary *dic in array) {
//            Status *status = [Status getStatusFromJsonDic:dic];
//            [statusArray addObject:status];
//        }
//        isSuccess(YES, statusArray);
//        
//        [json release];
//        [responseString release];
//    } onError:^(NSError *error){
//        isSuccess(NO, nil);
//    }];
//}
//
//
//
///**
// *  获取指定微博的转发微博列表
// *
// *  @param  statusId    需要查询的微博ID。
// *  @param  sinceId     若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
// *  @param  maxId       若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
// *  @param  count       单页返回的记录条数，最大不超过200，默认为20。
// *  @param  page        返回结果的页码，默认为1。
// *  @param  filter      作者筛选类型，0：全部、1：我关注的人、2：陌生人，默认为0。
// *  @param  isSuccess   block           请求成功的回调
// *                      BOOL            请求是否成功 YES or NO
// *                      NSMutableArray  返回的微博信息数组
// */
//+ (void)getRepostStatusesWithStatusId:(NSString *)statusId
//                              SinceId:(int)sinceId
//                                maxId:(int)maxId
//                                count:(int)count
//                                 page:(int)page
//                       filterByAuthor:(int)filter
//                              success:(void (^) (BOOL isSuccess, NSMutableArray *array))isSuccess
//{
//    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_TOKEN_KEY];
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setObject:accessToken forKey:@"access_token"];
//    [dic setObject:statusId forKey:@"id"];
//    [dic setObject:[NSString stringWithFormat:@"%d",sinceId] forKey:@"since_id"];
//    [dic setObject:[NSString stringWithFormat:@"%d",maxId] forKey:@"max_id"];
//    [dic setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
//    [dic setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
//    [dic setObject:[NSString stringWithFormat:@"%d",filter] forKey:@"filter_by_author"];
//    
//    [HttpBaseModel getDataResponseHostName:HOSTURL Path:@"2/statuses/repost_timeline.json" params:dic httpMethod:@"GET" onCompletion:^(NSData *responseData){
//        
//        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"responseString = %@", responseString);
//        
//        SBJSON *json = [[SBJSON alloc] init];
//        NSError *error = nil;
//        NSDictionary *jsonDic = [json objectWithString:responseString error:&error];
//        
//        NSArray *array = [jsonDic objectForKey:@"reposts"];
//        NSMutableArray *statusArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
//        for (NSDictionary *dic in array) {
//            Status *status = [Status getStatusFromJsonDic:dic];
//            [statusArray addObject:status];
//        }
//        isSuccess(YES, statusArray);
//        
//        [json release];
//        [responseString release];
//    } onError:^(NSError *error){
//        isSuccess(NO, nil);
//    }];
//}
//
//
//
///**
// *  获取最新的提到登录用户的微博列表，即@我的微博
// *
// *  @param  sinceId             若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
// *  @param  maxId               若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
// *  @param  count               单页返回的记录条数，最大不超过100，默认为20。
// *  @param  page                返回结果的页码，默认为1。
// *  @param  filterByAuthor      作者筛选类型，0：全部、1：我关注的人、2：陌生人，默认为0。
// *  @param  filterBySource      来源筛选类型，0：全部、1：来自微博、2：来自微群，默认为0。
// *  @param  filterByType        原创筛选类型，0：全部微博、1：原创的微博，默认为0。
// *  @param  isSuccess           block           请求成功的回调
// *                              BOOL            请求是否成功 YES or NO
// *                              NSMutableArray  返回的微博信息数组
// */
//+ (void)getMentionsStatusesWithSinceId:(int)sinceId
//                                 maxId:(int)maxId
//                                 count:(int)count
//                                  page:(int)page
//                        filterByAuthor:(int)filterByAuthor
//                        filterBySource:(int)filterBySource
//                          filterByType:(int)filterByType
//                               success:(void (^) (BOOL isSuccess, NSMutableArray *array))isSuccess
//{
//    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_TOKEN_KEY];
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setObject:accessToken forKey:@"access_token"];
//    [dic setObject:[NSString stringWithFormat:@"%d",sinceId] forKey:@"since_id"];
//    [dic setObject:[NSString stringWithFormat:@"%d",maxId] forKey:@"max_id"];
//    [dic setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
//    [dic setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
//    [dic setObject:[NSString stringWithFormat:@"%d",filterByAuthor] forKey:@"filter_by_author"];
//    [dic setObject:[NSString stringWithFormat:@"%d",filterBySource] forKey:@"filter_by_source"];
//    [dic setObject:[NSString stringWithFormat:@"%d",filterByType] forKey:@"filter_by_type"];
//    
//    [HttpBaseModel getDataResponseHostName:HOSTURL Path:@"2/statuses/mentions.json" params:dic httpMethod:@"GET" onCompletion:^(NSData *responseData){
//        
//        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"responseString = %@", responseString);
//        
//        SBJSON *json = [[SBJSON alloc] init];
//        NSError *error = nil;
//        NSDictionary *jsonDic = [json objectWithString:responseString error:&error];
//        
//        NSArray *array = [jsonDic objectForKey:@"statuses"];
//        NSMutableArray *statusArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
//        for (NSDictionary *dic in array) {
//            Status *status = [Status getStatusFromJsonDic:dic];
//            [statusArray addObject:status];
//        }
//        isSuccess(YES, statusArray);
//        
//        [json release];
//        [responseString release];
//    } onError:^(NSError *error){
//        isSuccess(NO, nil);
//    }];
//}
//
//
//
///**
// *  获取微博官方表情的详细信息
// *
// *  @param  type            表情类别，face：普通表情、ani：魔法表情、cartoon：动漫表情，默认为face。
// *  @param  language        语言类别，cnname：简体、twname：繁体，默认为cnname。
// *  @param  isSuccess       block           请求成功的回调
// *                          BOOL            请求是否成功 YES or NO
// *                          NSMutableArray  返回的表情数组
// */
//+ (void)getEmotionsWithType:(NSString *)type
//                   language:(NSString *)language
//                    success:(void (^) (BOOL isSuccess, NSMutableArray *array))isSuccess
//{
//    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_ACCESS_TOKEN_KEY];
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setObject:accessToken forKey:@"access_token"];
//    [dic setObject:type forKey:@"type"];
//    [dic setObject:language forKey:@"language"];
//    
//    [HttpBaseModel getDataResponseHostName:HOSTURL Path:@"2/emotions.json" params:dic httpMethod:@"GET" onCompletion:^(NSData *responseData){
//        
//        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"responseString = %@", responseString);
//        
//        SBJSON *json = [[SBJSON alloc] init];
//        NSError *error = nil;
//        NSArray *jsonArray = [json objectWithString:responseString error:&error];
//        
//        NSMutableArray *emotionsArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
//        for (NSDictionary *dic in jsonArray) {
//            Emotion *emotion = [Emotion getEmotionFromJsonDic:dic];
//            [emotionsArray addObject:emotion];
//        }
//        isSuccess(YES, emotionsArray);
//        
//        [json release];
//        [responseString release];
//    } onError:^(NSError *error){
//        isSuccess(NO, nil);
//    }];
//}







@end
