
Aria2GUI
===========

![UI](http://i.imgur.com/MEZqP9z.png)

## Features:

- 集成aria2c
- 多线程下载
- 未完成任务退出自动保存
- 支持网盘的aria2导出（需要浏览器插件支持）
- 支持PT/BT
- 在Badge显示整体下载速度
- 任务完成通知

## Usage:

- 解压后拖到应用里面运行即可

## Tips:

- 使用Chrome浏览器可配合[YAAW-for-Chrome](https://github.com/acgotaku/YAAW-for-Chrome)插件接管浏览器的所有下载到aria2
- 使用Safari浏览器可配合[safari2aria](https://github.com/miniers/safari2aria)插件接管浏览器的所有下载到aria2
- 导出插件：[百度网盘](https://github.com/acgotaku/BaiduExporter)，[115网盘](https://github.com/acgotaku/115)，~~[迅雷离线](https://github.com/binux/ThunderLixianExporter)~~
- 网盘插件里面的User-Agent优先级高于客户端，所以修改客户端里面User-Agent不会影响导出下载的速度，默认伪装成Transmission/2.77是为了支持BT/PT
- *max*-*connections*-*per*-server（线程数）初始值16，上限256，*split*初始值16，提高*max*-*connections*-*per*-server的值 split最好也相应的提高，如果是旧的苹果机型（机械硬盘），线程数请维持默认值，过高的线程数可能导致软件或者网络设置崩溃，如果是新的苹果机型（固态硬盘) ，可以尝试提高线程数以获取更理想的下载速度， 新加入*max-tries retry-wait*两个启动项
- 百度网盘对于插件进行了某些限制，不登陆的情况直接报header错误，登录后第一次会弹验证码之后就正常了，会员暂时没发现有什么限制，具体参考https://github.com/acgotaku/BaiduExporter/issues/547

## Download:

  [Releases](https://github.com/yangshun1029/aria2gui/releases)

## With special thanks to:  

- [Aria2](https://aria2.github.io)
- [YAAW](https://github.com/binux/yaaw)
- [MacGap](https://github.com/MacGapProject)
- [fakeThunder](https://github.com/MartianZ/fakeThunder)

## Contributors:  

  [Nick](https://github.com/yangshun1029)

## License

Aria2GUI is licensed under [MIT License](http://choosealicense.com/licenses/mit/) 

