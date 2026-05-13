---
title: AI+安全｜让你的AI"看懂"网络流量——使用Trae+Wireshark MCP挑战2025 CISCN
tags: [wechat, AI安全, Wireshark, MCP, Trae, CISCN, 网络安全, AI_Coding]
source: https://mp.weixin.qq.com/s/pB7nrFq-vro8zDCIiMMRxg
author: 司徒Kni9ht
crawled: 2026-05-13
---

<!--
  Source: https://mp.weixin.qq.com/s/pB7nrFq-vro8zDCIiMMRxg
  Crawled: 2026-05-13T17:57:58.431989
  Author: 司徒Kni9ht
-->

# AI+安全｜让你的 AI “看懂”网络流量 —— 使用Trae+Wireshark mcp挑战2025 CISCN 流量分析题

> 免责声明由于传播、利用本公众号藏剑安全所提供的信息而造成的任何直接或者间接的后果及损失，均由使用者本人负责，公

免责声明  

| 由于传播、利用本公众号藏剑安全所提供的信息而造成的任何直接或者间接的后果及损失，均由使用者本人负责，公众号藏剑安全及作者不为此承担任何责任，一旦造成后果请自行承担！如有侵权烦请告知，我们会立即删除并致歉，谢谢！ |

朋友们现在只对常读和星标的公众号才展示大图推送，建议大家把**藏剑安全**“**设为星标**”，否则可能就看不到了啦！

  
![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640.png)

## 一、前言

叠个甲，作者本人没有参加今年CISCN，正式比赛也是禁止使用网络大模型解题的，本次实验是在赛后使用其他师傅提供的赛题附件来测试的。

本文会首先带大家配置一下**Trae + WireMCP**，然后使用**2025 CISCN**流量分析题实战看一下效果

## 二、Trae + WireMCP配置

### 1.什么是 WireMCP？

**WireMCP** 是一个基于 **Model Context Protocol（MCP）** 的服务器插件，它将网络抓包与协议分析能力暴露出来，使支持 MCP 的大模型能够像安全分析师一样：

- 实时捕获网络流量数据
- 抽取协议统计信息
- 分析主机会话（TCP/UDP 流量）
- 通过威胁情报检测可疑 IP
- 分析已有 PCAP 文件
- 从数据流中提取可能的凭据 以上功能均以结构化 JSON 形式返回，极大提升 LLM 解读与推理网络数据的能力。![Wire-MCP Banner](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_1.png)Wire-MCP Banner

换句话说，它是 **Wireshark（tshark）与 LLM 之间的桥梁** —— 把原始网络流量变成 AI 可理解的“语言”。

关注公众号“藏剑安全”，后台回复“WireMCP”获得下载链接

### 2.WireMCP 适合哪些场景？

如果你希望用大模型完成以下任务，它就是合适的工具：

**安全类**

- 实时威胁追踪与异常流量发现
- 利用威胁情报自动标记可疑 IP
- 安全审计与网络隐患提示

**运维类**

- 网络性能瓶颈诊断
- 多服务间连接行为解析
- 大模型自动生成网络分析报告

**辅助类**

- 将 PCAP 分析转换为自然语言解释
- 作为智能助手提升 Wireshark 的解释能力

### 3.Trae 下快速部署 WireMCP

为了让 Trae一个支持 MCP 的智能 IDE/Agent 平台）调用 WireMCP，需要完成以下步骤：

#### 3.1 环境准备

确保以下软件已经安装并可正常运行：

- **Wireshark + tshark**其中 *tshark* 必须能够在命令行下调用。
- **Node.js + npm**推荐 Node.js v16+,自行安装node环境，https://nodejs.org/en/download。
- **Trae 客户端**已经安装并能进入设置页面。

#### 步骤 01｜下载安装Wireshark并配置tshark到系统环境变量

Wireshark可以直接搜索下载安装，这里不再赘述，主要讲一下Wireshark和tshark的关系

简单来说：

> 

WireMCP = 把 tshark（Wireshark 内核能力）封装成 MCP，让大模型可调用

**tshark 是什么？**

`tshark` 是：

- Wireshark 官方提供的 **命令行版本**
- **使用同一套协议解析引擎（dissector）**
- 能在无界面（服务器、容器、CI）环境运行

核心事实：

> 

**Wireshark = GUI + tshark/libwireshark 内核****tshark = 纯 CLI + 同一内核**

所以在能力层面：

| 能力 | Wireshark | tshark |
| 协议解析 | ✅ | ✅ |
| PCAP 分析 | ✅ | ✅ |
| 流重组 | ✅ | ✅ |
| 显示过滤器 | ✅ | ✅ |
| 自动化 | ❌ | ✅ |
| 适合 MCP / AI | ❌ | ✅ |

**为什么 MCP 一定选 tshark，而不是 Wireshark？**

**MCP 是“给程序用的”，不是给人点的。**

- MCP ≠ 插件
- MCP = **标准化进程通信协议**
- 必须：
- 无交互界面
- 可结构化输出
- 可被进程控制

Wireshark GUI ❌ tshark CLI ✅

安装完成Wireshark后，安装目录会自带一个`tshark.exe`文件

![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_2.png)

在 Windows 环境下使用，需要将Wireshark安装目录添加到系统环境变量中，能够在cmd中执行`tshark -h`命令即可

![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_3.png)

#### 步骤 02｜下载 WireMCP 项目

```
git clone https://github.com/0xKoda/WireMCP.gitcd WireMCP
```

#### 步骤 03｜安装依赖

```
npm install
```

确保目录下出现 node_modules 并安装成功。

#### 步骤 04｜测试启动 MCP 服务

在项目根目录执行：

```
node index.js
```

测试WireMCP 服务能在本机端口启动即可。

#### 步骤 05｜Trae 添加 MCP 服务

打开 **Trae 设置** → **MCP Servers** → 点击 “手动添加”。

填写配置内容如下：

```
{  "mcpServers": {    "wiremcp": {      "command": "node",      "args": [        "D:/你的文件路径/WireMCP/index.js"      ]    }  }}
```

**注意**

- `command` 填写 “node”
- `args` 中为 WireMCP项目的真实路径 Trae 将通过这个配置启动 WireMCP，并在后台建立通信通道。![image-20251231150303430](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_4.png)

#### 步骤 06｜验证是否正常工作

在 Trae 的交互区使用 MCP 调用试运行，比如：

```
使用WireMCP分析当前文件夹下xxxx.pcap数据包
```

如果有日志输出或返回网络分析结果，则代表部署成功。

## 三、使用Trae + WireMCP尝试做2025 CISCN 流量分析题

**原始题目——SnakeBackdoor：**

附件仅有一个`attack.pcap`

**题目描述：**

```
题目1：近期发现公司网络出口出现了异常的通信，现需要通过分析出口流量包，对失陷服务器进行定位。现在需要你从网络攻击数据包中找出漏洞攻击的会话，分析会话编写exp或数据包重放，查找服务器上安装的后门木马，然后分析木马外联地址和通信密钥以及木马启动项位置。攻击者爆破成功的后台密码是什么？，结果提交形式：flag{xxxxxxxxx}题目2：攻击者通过漏洞利用获取Flask应用的 `SECRET_KEY` 是什么，结果提交形式：flag{xxxxxxxxxx}题目3：攻击者植入的木马使用了加密算法来隐藏通讯内容。请分析注入Payload，给出该加密算法使用的**密钥字符串(Key)** ，结果提交形式：flag{xxxxxxxx}题目4：攻击者上传了一个二进制后门，请写出木马进程执行的本体文件的名称，结果提交形式：flag{xxxxx}，仅写文件名不加路径题目5：请提取驻留的木马本体文件，通过逆向分析找出木马样本通信使用的加密密钥（hex，小写字母），结果提交形式：flag{[0-9a-f]+}题目6：请提交攻击者获取服务器中的flag。结果提交形式：flag{xxxx}
```

开始测试：

![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_5.png)

中间的思考过程我就不截图了，展示一部分比较关键的部分。

![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_6.png)![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_7.png)

这是题目中一个核心点，一个31层嵌套的RC4 后门，AI通过调用wiremcp成功解码找到了key

![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_8.png)![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_9.png)

到这里其实我还没说具体的题目，这里只是AI自动分析的结果，下面把具体题目发给它。

![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_10.png)![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_11.png)![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_12.png)

可以看到AI通过前面获得到的RC4 key写脚本自动分析出了实际通信执行的命令，并且获取到了shell.zip的解压密码。

![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_13.png)

前面四个题通过wiremcp AI做的都比较容易，但是最后两个题，因为涉及到逆向分析，AI还是没办法直接解出的。

我一开始尝试让他使用ida pro mcp分析shell，但是似乎还是有点问题，开始钻入死胡同

![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_14.png)![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_15.png)

调试了几轮还是有问题，最终还是通过这位师傅的wp（https://www.dr0n.top/posts/22eff239/#web）强行更正了AI

![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_16.png)

整体时间上前面四个题几分钟就完全分析完了，主要是56题走入死胡同，导致后期AI一直在原地转圈，整体token消耗也是花在56题。

![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_17.png)

有点顶不住，不过Trae可以配置自己的模型，可以使用GLM的4.7，顺便推一下，最近GLM有活动，可以一起拼，不管是用在Trae上还是Claude code上都不错。扫码或者点击下方链接，或者点击阅读原文，可以拼个套餐。

https://www.bigmodel.cn/glm-coding?ic=SYMQYCJRLR

![BigmodelPoster (1)](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_18.png)![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_19.png)

测试完Trae，我也尝试使用Claude code +GLM 测试了一下，前面两题速度还是挺快的。

![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_20.png)![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_21.png)

可惜在第三关就卡了贼久，还是在人为介入的情况下，不然它连base嵌套都没识别到。

![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_22.png)

截止发文，还在原地转圈，时间已经过去1小时~

![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_23.png)

## 四、总结

整体来说，如果能够使用大模型工具参赛解题，简单题目已经能够在几分钟内全自动化解出，复杂题目也可以结合使用多个MCP工具尝试解题。

比如结合`WireMCP`+`ida-pro-mcp`+`ssh-mcp`+`mysql-mcp`，**AI的整体能力就已经超过了绝大多数普通安服仔**

能够一键全自动实现**流量分析、逆向分析、日志分析、系统基线排查、Linux应急响应、数据库取证**等等操作。

**未来可凄！**

**实习/校招/社招  
**

  
  
长期持续内推长亭、360、绿盟等安全大厂，已累计内推3000+人  
![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_24.png)26校招持续内推中~~~明年毕业的同学欢迎加我，1对1简历辅导，全程跟踪内推情况

| 安全服务工程师、安全攻防工程师、安全研发工程师、前后端开发工程师、测试工程师等等，所有岗位均可内推需要考CISP/CISP-PTE/PMP/OSCP/CISSP等证书也可以加我，市场低价！有折扣！ |

![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_25.png)  

![](AI安全让你的_AI_看懂网络流量_使用TraeWireshark_mcp挑战2025_CISCN_流量分析题_files/640_26.png)  

  

**推荐阅读**

**[内推|长亭科技2026届秋招开启，附内推码~](https://mp.weixin.qq.com/s?__biz=Mzg5MDA5NzUzNA==&mid=2247489528&idx=1&sn=59df3e485641fe43c68070e5f884479d&scene=21#wechat_redirect)**

  

**[你能拿她学校的shell，但永远拿不了她的shell](http://mp.weixin.qq.com/s?__biz=Mzg5MDA5NzUzNA==&mid=2247485510&idx=1&sn=292301d0bf6700f1e828f9b95fa454d5&chksm=cfe09257f8971b41b2c12e366c8ca19ec722e314c5f0f1767fc02644d2301ae0ba7229f0e142&scene=21#wechat_redirect)**********

  

**[渗透实战|记一次简单的Docker逃逸+反编译jar接管云主机](http://mp.weixin.qq.com/s?__biz=Mzg5MDA5NzUzNA==&mid=2247485356&idx=1&sn=8e6e955e5a93bac9de3ff428bc2f9e3a&chksm=cfe09dbdf89714abcda8ebf025f0db58833782a7beca9fe0fbd15d78aa3f78e9698525752d7c&scene=21#wechat_redirect)**  

  

**[渗透实战|NPS反制之绕过登陆验证](http://mp.weixin.qq.com/s?__biz=Mzg5MDA5NzUzNA==&mid=2247485174&idx=1&sn=93bfb002b917b33c43830d2d851403c7&chksm=cfe09ce7f89715f1f53bdcab44cd86040363970f6cff1fd555d428aee5c8e09c65ee506ea241&scene=21#wechat_redirect)**

  

**[渗透实战|记一次曲折的EDU通杀漏洞挖掘](http://mp.weixin.qq.com/s?__biz=Mzg5MDA5NzUzNA==&mid=2247485075&idx=1&sn=9a6074125bdefc9a4be8fe60ab38aadf&chksm=cfe09c82f897159447b0430475ace4f4a3bb7c31e69223521dea0f696ac0ed8f6f63572df48b&scene=21#wechat_redirect)**

  

**[渗透实战|记一次RCE+heapdump信息泄露引发的血案](http://mp.weixin.qq.com/s?__biz=Mzg5MDA5NzUzNA==&mid=2247484929&idx=1&sn=b6edbde5a73a4e4f812f1919cdf36307&chksm=cfe09c10f8971506fc924f59c0669aa3c7da8a836aad0dc582bbe25351a68c4b748891da5120&scene=21#wechat_redirect)**  

  

**免责声明**由于传播、利用本公众号**藏剑安全**所提供的信息而造成的任何直接或者间接的后果及损失，均由使用者本人负责，公众号**藏剑安全**及作者不为**此**承担任何责任，一旦造成后果请自行承担！如有侵权烦请告知，我们会立即删除并致歉。谢谢！好文分享收藏赞一下最美点在看哦