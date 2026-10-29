# QcSdkShare

QC 海外 iOS SDK 的基础分享模块，以预编译静态 XCFramework 通过 Swift Package Manager（SPM）分发，不提供业务实现源码。

## 环境要求

- iOS 17.0 或以上，使用支持 Swift 6.2 的完整 Xcode。
- 当前制品覆盖 iOS 真机 arm64 和模拟器 arm64，不包含 Intel 模拟器 x86_64。
- App / Unity 实际链接 SDK 的 Target 必须满足相同最低系统要求。

## 模块依赖

| 类型 | 自动带入的产品 |
|---|---|
| 自有模块 | `QcSdkCore` |
| 官方第三方 | 无 |

依赖关系和版本以分发 `Package.swift` 为准。无需手动重复添加这些产品；多个功能包使用同一 Core 仓库和兼容的 Core exact 版本。不要把各模块的版本号相同理解为可以忽略依赖约束。

## 在 Xcode 中集成

1. 选择 **File → Add Package Dependencies…**，输入：

   ```text
   https://github.com/YuFengChen77/QcSdkShare.git
   ```

2. 在本仓库 Releases 中选择所需的已发布版本，Dependency Rule 使用 **Exact Version**。
3. 选择 **QcSdkShare** 产品，将 Add to Target 设为实际使用 SDK 的 App Target；Unity 通常为 `UnityFramework`。
4. 在该 Target 的 **Build Settings → Other Linker Flags** 保留原有值并添加：

   ```text
   $(inherited) -ObjC
   ```

5. 确认最低部署版本为 iOS 17.0 或以上，编译并运行。

SPM 自动下载 Release 中的 XCFramework ZIP、校验 checksum 并链接；不要再手动拖入同一 Framework。只有 README、尚无有效 tag / Package.swift / Release ZIP 的仓库还不能作为已发布 SDK 接入。

## 接入验证

下面仅验证模块可导入、反射类保留，不发起真实业务：

```swift
import Foundation
import QcSdkCore
import QcSdkShare

precondition(NSClassFromString("QcSdkShare.ShareImp") != nil)
```

`-ObjC` 缺失可能使只通过类名访问的实现被裁掉。业务通过 SDK 公开入口调用，不直接依赖内部实现类；通过编译和反射检查后，仍需完成本模块配置及业务联调。

## 分享能力与调用

在已有启动转发和 SDK 初始化流程完成后，可通过公开入口打开分享面板：

```swift
@MainActor
func shareWithSDK(_ param: ShareParam, listener: ShareListener?) {
    QcShareSdkApi.shared.shareByDialog(shareParam: param, listener: listener)
}
```

`param` 由宿主按实际内容构造，`listener` 接收结果；不要用示例代替具体内容校验。

本模块提供分享管理、分享面板及系统分享、Line、Telegram、X 等实现；具体类型与内容支持以公开 `SharePlatform`、`ShareType` 和实现的支持矩阵为准，不依赖对应第三方渠道 SDK。

宿主应先转发 Core 的启动事件并完成 SDK 初始化，再通过 Core 的公开 `QcShareSdkApi.shared` 使用 `shareByDialog(shareParam:listener:)` 或 `share(platform:shareParam:listener:)`，并处理 `ShareListener` 的成功、失败和取消回调。

- 使用真实可访问的本地图片路径 / 分享参数，不把远程 URL 当成本地文件路径。
- 原生 App 和 Unity 均需有可展示的顶层页面；iPad 场景需检查弹出位置和交互。
- 分享目标 App 是否安装、是否支持指定内容、是否完成用户操作应分别处理，不把“成功拉起页面”等同于发布成功。
- 查询其他 App scheme 时按实际使用合并 `LSApplicationQueriesSchemes`；不能只根据查询失败推断用户一定无法分享。
- Facebook 图片分享由独立的 `QcSdkShareFacebook` 提供，只集成本模块不会带入 Facebook SDK。

真机联调覆盖目标 App 已安装 / 未安装、内容无效、用户取消与分享面板展示。

## 启动与生命周期

将 SDK 的启动事件合并进宿主已有 AppDelegate：`QcSdkApi.shared.application(_:didFinishLaunchingWithOptions:)`。它负责基础准备和插件发现，不能替代业务 `sdkInit`。沿用 `QcSdkApi.shared.sdkInit(...)` 及现有 delegate；初始化成功后再调用需要初始化结果的业务 API。

涉及 URL 回跳时，普通 App / Unity 转发 `QcSdkApi.shared.application(_:open:options:)`，Scene 宿主转发 `QcSdkApi.shared.scene(_:openURLContexts:)`。保留其他 SDK 的已有处理，按宿主实际入口转发，避免重复初始化和丢失回跳。Unity 宿主通过既有桥接管理器统一转发时，不要再重复调用同一条 Core 链路。

## 资源与分发目录

```text
Package.swift
README.md
QcSdkShare/
└── Sources/
    └── Dependencies.swift
```

`Sources/Dependencies.swift` 只组织导入，不包含业务实现；辅助 target 为 `QcSdkShareSupport`。接入方选择和导入的仍是 `QcSdkShare`，不需要额外选择 Support 产品。本模块没有独立资源声明；Core 的图片、字体、多语言和隐私资源由 Core 的资源 bundle 提供。

Xcode 左侧未显示 XCFramework 不代表下载失败，文件通常位于工程 DerivedData 的 `SourcePackages/artifacts`。以包解析、Target 产品链接、构建和运行结果确认接入；不要为显示节点重复手动集成。

## 更新版本

1. 在 **PROJECT → 工程名 → Package Dependencies** 找到 `QcSdkShare`，修改 Exact Version 为新的已发布版本。
2. 等待解析下载，必要时执行 **File → Packages → Resolve Package Versions**。
3. 核对其他模块的 Core exact 要求兼容，重新编译并联调。

无需删除依赖、手动替换 Framework 或改 import。已发布版本的 tag、提交、ZIP 和 checksum 固定；出现 `does not match previously recorded value` 或 checksum 冲突时联系维护者使用新版本，不关闭校验。

## 注意事项

- 自有 SDK 为静态链接，不重复同时集成手动 Framework 和 SPM 产品，不手工将自有静态 Framework 设置为 Embed & Sign。第三方若含动态依赖，由最终 App 正常嵌入和签名。
- 包解析与反射检查不代表业务验收完成；仍需验证分享面板展示、系统 / 目标 App 分享、取消和失败回调。
- SDK 的资源和公开 `.swiftinterface` / Objective-C 头文件可以查看，但不包含业务实现源码。
- 不将 Client Secret、服务端密钥、授权 token 或内部日志提交到公开仓库。
- Core 通用集成和业务配置另见 [QcSdkCore README](https://github.com/YuFengChen77/QcSdkCore#readme)。

本文件在开发仓库的 `QcSdkShare/README.md` 维护，生成分发包时自动复制；依赖声明仍以根 `Package.swift` 和本次发布清单为准。
