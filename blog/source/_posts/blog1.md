---
title: 使用Hexo&GitHub免费快速搭建博客教程
date: 2018-03-01 10:18:46
tags: [github, hexo, next]
categories: [技术]
---

> 经过两天的折腾，终于搞定了属于自己的第一个博客的搭建，在此期间踩了许多坑，现总结一下帮助各位能够更方便去搭建自己的博客。先贴上成果 [**拾忆的博客**](https://lishibo-ios.github.io/)

> 百度参考了各路大神的博客文章最后进行的总结，望各路大神不要介意哦~

> 因为本人长期使用mac电脑，故本篇文章只在mac系统的基础上去实现功能，使用Windows系统需要自行参考，其原理是一样的。

> 这是本人写的第一篇文章，可能会看到和其他的许多文章有相似之处，请大家自动忽略(￣▽￣)~* ，全文纯手打，**旨在帮助大家更方便的实现搭建过程**，大家不喜勿喷哦~

## 一、引子

### 1.搭建博客的原因
- 曾经用过印象笔记，有道笔记等工具来记录文章，但用起来总是感觉有或多或少的问题，不如用博客看的更直观
- 可以随心发表，改造外观，功能
- 拥有一个自己的博客网站，感觉更爽
- 希望更多的人可以看到自己写的文章

### 2.整个过程使用的时间

- 最开始百度参考了各路大神的文章，每篇文章都会有或多或少的缺陷，自己又踩了许多坑才完成
- 用了大概两天的时间，完成了博客的搭建和主题的修改

### 3.环境配置
- mac系统，sublime编辑器 （暂时使用到的）
- github账号，hexo框架配置，next主题 （下面会提供配置方式）

### 4.搭建方式
- 使用hexo框架进行网站的构建，然后部署到免费的github上

## 二、GitHub配置

1. 登陆 [https://github.com/](https://github.com/) ，没有账号的就去注册一个，记住自己的用户名

2. 主页中点击右上角自己的图标，点击your profile

	![picture1](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/picture1/1.png)
	
3. 点击repositories，新建一个

	![picture2](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/picture1/2.png)
	
4. Repository name （填自己的名字） http://yourname.github.io(yourname与你的注册用户名一致,这个就是你博客的域名了),下图中报错是因为我已经用过了这个名字，大家填写自己的名字不会遇到这个问题，然后点击create repository进行下一步
	![picture3](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/picture1/3.png)
	
5. 点击自己的这个repository，然后找到settings

	![pictures4](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/picture1/4.png)
	
6. 下拉找到GitHub Pages, 其中上面红框中的即为你的博客地址，下面红色框中可以进去选择自己的主题样式, 此时github中的基本配置已经完成 

	![picture5](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/picture1/5.png)
	
	如第一次进入，可能会不显示博客地址，如下图，则可以先选择github自带的主题样式，Choose a theme 按钮，再回来后就能够看到了(**注意：在save按钮左边那项要显示为master branch才表示正确**)
	
	![picture7](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/picture1/7.png)

## 三、环境配置

1. 安装 [Node.js](http://nodejs.cn/download/)
	安装完成后终端输入 
	
	`node -v`
	
	 `npm -v`
	 
	 查看版本号，如存在则表明配置成功
	 
2. mac系统自带Git环境，Windows用户需要自行下载[Git](https://github.com/waylau/git-for-win)

3. 安装完成后，通过git命令查看自己的用户名和邮箱是否和自己github中的一致，如不一致请自行更改，如查询到多个用户名须删除没用的用户名，如查询后没有任何反应则表明还没有配置用户名，用下面的修改或者添加用户名命令即可，如提示其他之类的可先执行命令 `git config`，然后再执行以下命令即可成功,附查看和更改命令（其他命令可自行百度查找）：

	**查看用户名：** `git config --global user.name`
	
	**查看邮箱：** `git config --global user.email`
	
	**删除用户名** `git config --global --unset user.name 要删的用户名`
	
	**增加用户名** `git config —global —add user.name 新加的用户名`
	
	**修改用户名** `git config --global user.name 用户名`
	
	**修改邮箱** `git config --global user.email 邮箱`
	
4. 终端中输入 `npm install -g hexo-cli`(如提示无权限即下图红色框中permission denied，则输入`sudo npm install -g hexo-cli`,后输入电脑密码enter即可)
	
	![picture8](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/picture1/8.png)

5.	这个过程会比较久，如果出现WARN错误可以忽略。我记得当时，每次都会出现说有一个依赖包已经不更新，这个不影响。执行完成后，使用 `hexo -v` 查看是否安装成功，如下图所示，即表明已经成功安装上
	
	![picture9](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/picture1/9.png) 

## 四、网站代码以及设置

1. 在桌面上创建一个文件夹，名字自定义如：hexo,终端cd 进入hexo文件夹

2. 输入hexo init blog (如出现warn错误可忽略，不影响)

	* _config.yml, 网站的配置信息，可以在此配置中配置大部分的参数
	* source，资源文件夹是存放用户资源的地方。除 posts 文件夹之外，开头命名为 (下划线)的文件 / 文件夹和隐藏的文件将会被忽略。Markdown 和 HTML 文件会被解析并放到 public 文件夹，而其他文件会被拷贝过去 
	* themes，主题 文件夹。Hexo 会根据主题来生成静态页面。

3. 等待提示Start blogging with Hexo，就是安装成功了

4. 文件夹中自带一篇文章“Hello World”

5. 命令行cd进入blog目录下

6. 输入hexo g，生存静态文件

7. 输入hexo s，启动服务器。默认情况下，访问网址为： [http://localhost:4000/](http://localhost:4000/)
	此时服务开启，如需关闭Ctrl+ C
	
	> 注：hexo s 命令开启的是本地服务，开启后，则可以使用上述地址访问，如关闭，则上述地址访问不到，本功能旨在用来检查修改的配置是否成功，如打开查看后发现没有问题则可以部署到服务器上，之后再用你的博客地址访问即可看到最新的设置效果。

	> 如上传服务器之后立即查看博客可能没有立即变化，可尝试多刷新几次或重新打开浏览器即可

8. 新打开一个终端，输入：ssh-keygen -t rsa -C "Github的注册邮箱地址"

	一路enter过来，中间有的问题是选y/n的，选y即可，最后得到信息中找到这句话：
	`Your public key has been saved in /Users/zjjk/.ssh/id_rsa.pub.	`
	
	找到该文件(上句中in 后面即为该文件的地址)，打开（使用sublime text或其他编辑器）,Ctrl + a复制里面的所有内容，然后进入Sign in to GitHub：[github.com/settings/ssh](https://github.com/settings/keys)
	
	一步步操作：New SSH key ——Title：blog —— Key：输入刚才复制的—— Add SSH key
	
	> 注：此过程是生成ssh key，如后续再次执行此命令时，则需要把新生成的SSH key再配置到github中，因为新生成的SSH key会覆盖之前的，如不去github中替换会导致后续上传git服务器过程中失败
	
## 五、博客网站配置信息

1. 进入blog文件夹，用sublime打开_config.yml文件，此文件为博客的配置信息，在此修改参数。（**特别注意：每个参数的后面都要加个空格**）

2. 按照自己的信息进行基础设置

	`title: 拾忆的博客 `
	
	`subtitle: 小白的技术成长之路 ` 
	
	`description: 小白的技术成长之路 `
	
	`author: 拾忆`
	
	`language: zh-CN`
	
	`timezone: Asia/Shanghai `
	
3. 在_config.yml文件中找到 `deploy`配置处（一般在最下面，默认的显示可能不全，需按照下方示例自己添加）, username替换成你自己的username, repository的地址为你在github中创建的那个项目的地址，可去github中复制
	
	![gif1](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/picture1/luzhi4.gif)

		deploy: 

  			type: git
  
  			repository: git@github.com:username/username.github.io.git
  
  			branch: master
	 
	 保存完毕。
	 
4. 各类主题的配置信息，要在主题文件夹内的_config.yml上进行配置！后续会以next主题为例进行示范，此处可忽略。
	
## 六、发表文章

1. 终端 `cd` 进入blog文件夹下，输入`hexo new "Hello blog" `(Hello blog为你的文章名，可自定义)

2.  打开返回的文件地址，打开文件（也可在blog文件夹下 source/_posts/Hello blog.md 中找到你刚才创建的文件）

3. 文章内容采用Markdown语法进行编辑，需要用相关软件才能打开这个文件，本人使用的软件为[MacDown mac版](http://macdown.uranusjr.com), 大家可根据自己习惯下载喜欢的工具(**附：[Markdown语法使用说明](http://note.youdao.com/iyoudao/?p=2411&vendor=unsilent14)**)

4. 打开文件编辑
	
		---
		title: Hello blog
	
		date: 
	
		---
	只输入title字段即可，后续其他字段可根据主题再添加（**注意：title后面需加空格**）
	
5. 打开终端执行以下步骤:
	
		cd 进入blog 文件夹
		
		$ hexo clean
		INFO  Deleted database.
		INFO  Deleted public folder.
		
		$ hexo generate
		INFO  Start processing
		INFO  Files loaded in 1.48 s
		...
		INFO  29 files generated in 4.27 s
		
		$ hexo server
		INFO  Start processing
		INFO  Hexo is running at http://localhost:4000/. Press Ctrl+C to stop.
		
	此处三步是进行本地配置完成后，在本地打开查看刚刚修改的配置是否修改成功，三处命令也可这样写 `hexo clean` `hexo g` `hexo s` 
	
6. 打开 [http://localhost:4000/](http://localhost:4000/)后检查，如没有任何问题可以部署到服务器上

		 $ hexo deploy
		INFO  Deploying: git
		
	此时可能会出现 `error deployer not found:git` 的错误，输入以下代码 
	
	`npm install hexo-deployer-git --save`(如提示无权限错误则输入`sudo npm install hexo-deployer-git –-save`，后输入电脑密码enter即可)
	
	再次执行 `hexo deploy`
	
	其中，可能会出现github登录界面，正常填写就行(这里我一直登陆着github，暂时没有遇到)
	
	完成，终端可Ctrl+C关闭本地服务，然后打开 username.github.io 即可访问自己的博客（username为自己的github的用户名）
	
## 七、主题设置


主题设置中，最好玩的就是尝试各式各样的主题啦！因本人喜欢next主题的风格，所以会在下篇文章中以next主题为例，走一遍发布文章和配置博客各种信息的流程，下面是其他的一些主题，大家可根据自己喜欢的样式去选择主题下载配置，一般的主题配置都会在其相应的github中说明


[官方hexo主题大全](https://hexo.io/themes/)，里面有许多主题都能尝试一下。
	
在这里推荐几个主题：
	
* [next官网,Git](http://theme-next.iissnan.com/getting-started.html)(我用的就是这个啦，十分推荐！）
* [Material官网，Git](https://mt.viosey.com/)
	1. 主题配置，首先要下载主题，到相应的Git链接
	2. 下载完以后将文件解压缩后放到blog中的themes文件夹中
	3. 修改主题文件夹名称，将其改为 next(名称为你的主题的名称，可自定义，无硬性要求，下以next为例) 。 然后打开配置文件（/blog/_config.yml），找到 theme 字段，并将其值更改为 next(你刚才自定义的名称, 注意theme后加空格)，保存关闭
	
		![picture6](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/picture1/6.png)
		
	4. 接下来，打开主题相应的博客中的文档说明，对比“主题”中的_config.yml（ /blog/themes/next/_config.yml ），针对自己需要的功能进行相关设置
	5. 有关设置中的图片，统一放到主题文件夹(/next/)内\source\img。在设置中，用”/img/xigua.png”类似格式进行图片设置。
	6. 设置时切记 : 后面要加一个空格。这个坑有点恼人~
	7. 最后再重新进行一次，hexo clean,hexo g,hexo s,hexo deploy 整个博客就完成主题修改啦

## 八、总结
	
* 用了两天的时间，完成的博客的搭建，又花了一天时间来编写此篇文章，全文纯手打，写到这里真的好累啊~

* 看着别人的文章一路搭建下来中间还是会遇到很多问题，于是各种百度解决，故在此奉上此文，我遇到的坑这里都明确的解决了，大家也一样，可能会遇到各种不同的问题，百度去一个一个的解决就好了（万能的百度啊~~~）

* 编写文章用了一遍Markdown的语法，感觉还可以

* [拾忆的博客](https://lishibo-ios.github.io/) 

* 后续会陆续编写更多的文章，欢迎大家订阅哦~
