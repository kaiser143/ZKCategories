// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ZKCategories",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(
            name: "ZKCategories",
            targets: ["ZKCategories"]
        ),
    ],
    targets: [
        .target(
            name: "ZKCategories",
            path: "ZKCategories",
            sources: ["Classes"],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Classes"),
                .headerSearchPath("Classes/CALayer"),
                .headerSearchPath("Classes/NSArray"),
                .headerSearchPath("Classes/NSAttributedString"),
                .headerSearchPath("Classes/NSData"),
                .headerSearchPath("Classes/NSDate"),
                .headerSearchPath("Classes/NSDictionary"),
                .headerSearchPath("Classes/NSError"),
                .headerSearchPath("Classes/NSMethodSignature"),
                .headerSearchPath("Classes/NSNotificationCenter"),
                .headerSearchPath("Classes/NSNumber"),
                .headerSearchPath("Classes/NSObject"),
                .headerSearchPath("Classes/NSRunLoop"),
                .headerSearchPath("Classes/NSString"),
                .headerSearchPath("Classes/NSTimer"),
                .headerSearchPath("Classes/NSURL"),
                .headerSearchPath("Classes/NSUserDefaults"),
                .headerSearchPath("Classes/UIApplication"),
                .headerSearchPath("Classes/UIBarButtonItem"),
                .headerSearchPath("Classes/UIBlurEffect"),
                .headerSearchPath("Classes/UIButton"),
                .headerSearchPath("Classes/UIColor"),
                .headerSearchPath("Classes/UIControl"),
                .headerSearchPath("Classes/UIDevice"),
                .headerSearchPath("Classes/UIGestureRecognizer"),
                .headerSearchPath("Classes/UIImage"),
                .headerSearchPath("Classes/UIImagePickerController"),
                .headerSearchPath("Classes/UIImageView"),
                .headerSearchPath("Classes/UILabel"),
                .headerSearchPath("Classes/UINavigationBar"),
                .headerSearchPath("Classes/UINavigationController"),
                .headerSearchPath("Classes/UIResponder"),
                .headerSearchPath("Classes/UIScreen"),
                .headerSearchPath("Classes/UIScrollView"),
                .headerSearchPath("Classes/UITableView"),
                .headerSearchPath("Classes/UITableViewCell"),
                .headerSearchPath("Classes/UITextField"),
                .headerSearchPath("Classes/UITextView"),
                .headerSearchPath("Classes/UIView"),
                .headerSearchPath("Classes/UIViewController"),
                .headerSearchPath("Classes/UIVisualEffectView"),
                .headerSearchPath("Classes/UIWindow"),
                .headerSearchPath("Classes/WKWebView"),
            ],
            linkerSettings: [
                .linkedLibrary("z"),
                .linkedFramework("WebKit"),
            ]
        ),
    ]
)
