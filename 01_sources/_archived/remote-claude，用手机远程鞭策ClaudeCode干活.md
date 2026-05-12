---
title: "remote-claude，用手机远程鞭策ClaudeCode干活"
source: "https://mp.weixin.qq.com/s/DrIgNNQSJWGqpSIGNOfewQ"
author:
  - "[[张彦飞allen]]"
published:
created: 2026-05-12
description:
tags:
  - "clippings"
---
张彦飞allen *2026年5月12日 09:00*

大家好，我是飞哥！

估计现在很多同学都在用 Claude Code 在替自己干活了，通过 VibeCoding 的方式，人只需要变成监工，指挥 AI 进行项目方案设计，以及具体的代码编写工作。

但是在使用 Claude Code 进行编程的时候，有一个最大的问题，那就是你人不能离开电脑。因为 AI 可能随时都需要你来确认一些信息才能继续。比如你在吃饭的时候，可能 AI 有一个设计方案需要你来确认。你下班前丢给它一个活，但是你刚上地铁，claude code 就因为某一个交互而卡住。

在这些特殊场景里，我们人不在电脑旁边的话，就会比较麻烦。那能不能通过手机端和和电脑上的 Claude 会话打通，通过手机就能查看 Claude 提交的结果，以及和它进行交互呢。

有，remote-claude 就是这样一个开源项目。这是我的一位同事在遇到这个痛点后开发出来。github 的地址是：https://github.com/yyzybb537/remote\_claude。

它实现了通过飞书来接收 Claude 会话的输出结果，也支持通过飞书直接远程给 Claude 发送下一步的指令。今天飞哥来给大家介绍下 remote-claude 这个项目。（虽然名为 remote-claude，但事实上 CodeX 也是支持的。）

## 1、remote-claude 使用姿势

我们先假设说已经安装好了 remote-claude，直接看下它是怎么样工作的。它的使用非常的简单，就是分如下几步

- 第一步：假设你已经电脑上使用 cla 命令创建了一个会话
- 第三步：在会话管理中通过“创建群聊”进入会话
![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

- 第四步：进入群聊后就可以通过手机飞书卡片直接和电脑上的 claude 交流了
![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

怎么样，使用起来是不是非常的简单？

## 2、remote-claude 环境配置

如果你也需要这样远程通过飞书驱动电脑上的 Claude 来干活，那就可以把 remote-claude 装上

### 1）remote-claude 安装

当然了，在安装 remote-claude 之前，你需要先安装好了 Claude Code。关于 Claude Code 怎么安装，咱们就不在这里赘述了。没有装过的童鞋可以自行搜索一下。

remote-claude 的安装非常简单，有两种方式

**第一种：npm安装**

```
npm install remote-claude
```

需要安装uv、tmux等依赖，第一次可能有点慢.

**第二种：源码安装**

```
git clone https://github.com/yyzybb537/remote_claude.git
cd remote_claude
./init.sh
```

### 2）配置飞书机器人

由于整个交互过程是通过飞书来交互的，因此还需要创建一个飞书机器人。remote-claude 提供了向导可以完成这个事情。直接执行下面的命令即可。

```
remote-claude lark init
```

然后向导会通过浏览器，直接跳转到飞书的智能体应用创建页面。根据向导的指示来进行操作，一步步完成扫码创建企业自建应用、开通所需权限、配置事件回调、写入本地配置等。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

记得创建版本后要记并发布。只有发布后的机器人才能在飞书中搜索到。比如我用个人飞书创建的这个助手名字叫「alllen的智能助手」

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

### 3）初次启动

执行 cla 就可以启动飞书客户端 + 以当前目录路径为会话名启动 Claude。

```
cla
```

### 4）查看会话

remote-claude 提供了 list 命令可以查看所有已经和飞书打通的本地会话

```
remote-claude list
```
![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

### 5）飞书远程指挥 Claude

然后，你就可以通过机器人打开会话，就可以远程鞭策 Claude Code 干活了。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

另外你也可以在项目的的 Readme 中获取更多的安装和使用技巧。项目地址：https://github.com/yyzybb537/remote\_claude

## 3、后话

值得一提的是，该项目本身也是通过 AI 开发出来的。作者和我聊，他前前后后大概也就花了一周的时间。

- 第一个周末：给项目写了个迭代prompt，让claude和openclaw配合测试、根据测试结果自行迭代，周末2天整个项目流程跑通可用。
- 第二个周末：坐在电脑前，和claude对话、讨论，给remote-claude重新设计顶层架构和核心组件的架构，规避掉AI自行迭代容易陷入casebycase解决问题的误区，经过2天时间的几十次迭代，最终产出了第一个可用的版本

后面又经过几轮的优化和迭代后，我进行了试用，感觉体验还是非常不错的。重要的是也确实解决了我远程操作 Claude 的一个痛点。所以今天我也把它分享给大家。当然也欢迎对该项目感兴趣的同学一起来参与共建。

最后说句题外话，进入 AI 编程时代以后，编程本身已经不是大问题了。发掘需求，构思产品的能力会变得越来越重要。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

收录于AI技术应用

继续滑动看下一个

开发内功修炼

向上滑动看下一个