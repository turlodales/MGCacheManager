# MGCacheManager

-A tool to manage caches with expiry date.

Advantages : 
-Improves any Application performance requires caching content or Apps relaying on HTTP API.

*** NOTE ***

Recommened to implement this Class just with GET methods.

Response Timing Test

First Run Response Time 1.891051 sec

Second Run Response Time 0.025160 sec

**Workflow**

![Workflow](https://raw.githubusercontent.com/Mortgy/MGCacheManager/1.0.x/How-it-works.png)

#At App Delegate Implementation

```sh
 #import "MGCacheManager.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [MGCacheManager initializeExpiredCachesCleanerTimer];
    return YES;
}
```


#Example for Request ( Using AFNetworking )

```sh
 + (void)getPosts:(void (^)(id JSON))complete
{
	id cache = [MGCacheManager loadDataFromCacheFileNameKey:@"posts"];
	
	if (cache) {
		complete(cache);
		return;
	}
	
    [API sendGetPayload:nil toPath:@"posts" withLoadingMessage:nil complete:^(id JSON){
        
		complete([MGCacheManager saveAndReturnKeyResponse:JSON key:@"posts" cachePeriod:LONG_CACHE_DURATION]);

    }];
}
```

Any issues or recommendations , please contact me or open a new issue

