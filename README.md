# QQPlayer

## 仿QQ音乐播放器(本地音频文件) [ShenYj](https://github.com/ShenYj)

- [x] 支持歌词滚动/字号放大/当前播放歌词颜色变化
- [x] 支持后台播放/自动切歌
- [x] 支持锁屏处理
- [x] 支持打断处理

## 项目运行

项目通过 `CocoaPods` 集成依赖库，并使用了 `Bundler` 来对 CocoaPods 进行版本控制，所以需要本地环境安装 `Bundler`

进入项目 `scripts` 目录，执行 `bundle_exec_pod_install.sh` 脚本即可

> 如果需要权限，可以通过 `chmod +x bundle_exec_pod_install.sh` 为脚本文件增加执行权限

当然，如果你仅仅是本地调试，将来不会提交 PR，完全可以本地执行 `pod install`
