---
title: 博客搭建（二）-- 使用next主题配置博客基本信息
date: 2018-03-02 09:36:14
tags: [hexo, next]
categories: [技术]
---


> 在上篇文章中提到了如何免费通过github和hexo创建一个自己的博客，在此将通过next为例，演示一遍配置的过程（喜欢其他主题的可以在此绕过了）

##  一、前言

#### 常用命令及文件地址：
	
	部署到本地预览查看三部曲：
	hexo clean （清除缓存）
	hexo g (生成静态网页)
	hexo s (本地启动预览查看)

	部署到git服务器上：
	hexo deploy 

	博客配置文件地址：
	~/blog/_config.yml
	主题配置文件地址
	~/blog/themes/next/_config.yml


后面不再重复解释

##  二、next主题的安装和基本配置
	
	
### （一）安装
	
首先从github上clone到本地，在终端cd 到blog文件夹（即你通过Hexo init生成的根目录），然后在终端输入命令：
	
	git clone https://github.com/iissnan/hexo-theme-next themes/next
	
进入blog的全局配置文件：_config.yml （在blog文件夹下 /blog/_config.yml）

找到theme字段：设置为

	theme: next
	
此时可以查看下主题是否配置成功，执行上面提到的三部曲（ **终端cd到blog文件夹 执行 hexo clean , hexo g , hexo s** ）
然后访问[http://localhost:4000/](http://localhost:4000/),在本地查看效果，进行预览

### （二） 基本信息的配置

更多的博客和主题的配置可参考 [hexo官方文档](https://hexo.io/zh-cn/docs/index.html) 和 [next主题文档](http://theme-next.iissnan.com/)，如不想那么麻烦，可以继续往下看，下面就是我使用的一些常用的功能，足够自己使用了

#### 1、网站标题、作者、语言

**在博客配置文件_config.yml中进行如下配置**

	# Site
	title: 拾忆的技术博客
	subtitle: 小白的技术成长之路
	description: 小白的技术成长之路
	author: 拾忆
	language: zh-Hans
	timezone: Asia/Shanghai （如不填，则表示默认电脑的时区）

这里设置标题作者名字等信息，其中language一项最好配置成zh-Hans（简体中文），（查看next主题支持哪些语言 可查看~/blog/themes/next/languages文件夹）

#### 2、next主题的风格设置
	
**在主题配置文件_config.yml中进行如下配置**

next默认有四种风格，可根据自己喜欢的样式去设置查看

	# Schemes
	#scheme: Muse
	scheme: Mist
	#scheme: Pisces
	#scheme: Gemini

我这里使用的是Mist样式，其中#表示注释，使用哪种去掉前面的#即可，后不再说明

#### 3、设置菜单选项

打开主题配置文件：

先奉上我的配置方便大家去参考：
	
	menu:
	  home: / || home
	  categories: /categories || th
	  about: /about || user
	  archives: /archives || archive
	  tags: /tags || tags
	  #schedule: /schedule/ || calendar
	  #sitemap: /sitemap.xml || sitemap
	  #commonweal: /404/ || heartbeat
	
	# Enable/Disable menu icons.
	menu_icons:
	  enable: true
	  # Icon Mapping.
	  home: home
	  about: user
	  categories: th
	  tags: tags
	  archives: archive

其中menu表示配置菜单内容，menu_icons表示菜单图片，如需使用图片则在menu中设定值的后面加上 || 图片名

**（1）常用的默认菜单项，其中home和archives两页是系统默认的就有的，其他的需要自己创建，后面会讲到**

键值                 | 设定值                     |  显示文本（简体中文）     |
--------------------|---------------------------|------------------------|
home                | home: /                   | 主页                   |
archives            | archives: /               | 归档页                  |
categories          | categories: /categories   | 分类页                  |
tags                | tags: /tags               | 标签页                  |
about               | about: /about             | 关于页面                |


**（2）设置菜单项的显示文本。在第一步中设置的菜单的名称并不直接用于界面上的展示。Hexo 在生成的时候将使用 这个名称查找对应的语言翻译，并提取显示文本。这些翻译文本放置在 NexT 主题目录下的 languages/{language}.yml （{language} 为你所使用的语言）。**

**以简体中文为例，若你需要添加一个菜单项，比如 something。那么就需要修改简体中文对应的翻译文件 languages/zh-Hans.yml，在 menu 字段下添加一项：**

	menu:
	  home: 首页
	  archives: 归档
	  categories: 分类
	  tags: 标签
	  about: 关于

**（3）设定菜单项的图标，对应的字段是 menu_icons。 此设定格式是 item name: icon name，其中 item name 与上一步所配置的菜单名字对应，icon name 是 [Font Awesome](http://www.bootcss.com/p/font-awesome/#icons-web-app) 图标的 名字,去掉前缀icon-(或使用[图标库](https://fontawesome.com/icons?d=gallery)中的图片名称)。而 enable 可用于控制是否显示图标，你可以设置成 false 来去掉图标。next主题默认集成了识别[Font Awesome](http://www.bootcss.com/p/font-awesome/#icons-web-app)图片的方式，只需要在里面找到想要图标的名称，就可以拿过来使用**

	# Enable/Disable menu icons.
	menu_icons:
	  enable: true
	  # Icon Mapping.
	  home: home
	  about: user
	  categories: th
	  tags: tags
	  archives: archive
	  
> **请注意键值（如 home）的大小写要严格匹配**

#### 4、创建上述菜单选项中对应的页面

**（1）分类页面**

终端中cd 进入blog文件夹，执行 ` hexo new page "categories"` 然后在~/blog/source 文件夹中即可看到categories文件夹，打开里面的index.md文件，设置如下（注意：后面要加空格）：

	---
	title: 分类 （title可以自定义）
	type: categories （记住你写的type类型，后面分类文章需要使用）
	---
	
这时候上一步中菜单项的配置才会生效

	menu:
	    home: /
	    archives: /archives
	    categories: /categories
	    
这时候如运行本地查看会发现打开后没有任何东西，下面会告诉大家使用方法

**（2）标签页面**

同分类界面相同，终端中cd 进入blog文件夹，执行 ` hexo new page "tags"` 然后在~/blog/source 文件夹中即可看到tags文件夹，打开里面的index.md文件，设置如下（注意：后面要加空格）：

	---
	title: 标签 （title可以自定义）
	type: tags （记住你写的type类型，后面分类文章需要使用）
	---
	
运行打开后同样什么都不会有

**（3）关于页面**

同理，打开index.md文件后，只需要配置标题即可

	---
	title: 自我介绍
	date: 2018-02-28 17:11:54
	---
	
然后下面填写正文即可（这是我使用的方式，但是“关于”界面也可以使用其他方式配置，如配置个链接等，这里大家自行百度即可）

#### 5、给文章添加分类和标签

首先创建一个文章，上篇文章末尾有讲到，终端cd 进入blog文件夹，执行 `hexo new "文章名字"`，打开文章（在~/blog/source/_posts文件夹下）,然后进行如下配置：

	---
	title: 标题
	date: 2018-03-02 09:36:14
	tags: [blog] （注意：使用[]，将需要添加的标签写进去，多个标签用,分隔，categories同理）
	categories: [blog]
	---
	
保存，此时再去运行查看，点击分类和标签页面就会看到自己的文章了，不再是空的了

> 但是经过上述操作，发现每创建一篇文章都要在上面去加标签等字段，如果后期功能多的话，可能会要加很多字段，比较麻烦，这里有个比较相对容易的方式不用每次都去添加那些字段
> 首先打开文件 ~/blog/scaffolds/post.md ,进行如下配置：
> 
	---
	title: {{ title }}
	date: {{ date }}
	tags: {{ tags }}
	categories: 
	---
	
	你会发现，之后再创建文章时，文章上方会自动添加这些字段
	
#### 6.修改作者头像并旋转

打开主题配置文件，修改字段 avatar， 值设置成头像的链接地址

	
将头像放置主题目录下的 source/uploads/ （新建 uploads 目录若不存在） 
配置为：

`avatar: /uploads/avatar.png`

或者 放置在 source/images/ 目录下 
配置为：

`avatar: /images/avatar.png`

或直接放上链接，如：
`avatar: http://example.com/avatar.png`

此时头像设置完成，如需实现旋转效果则按如下过程：

打开~\blog\themes\next\source\css\_common\components\sidebar\sidebar-author.styl，在里面添加如下代码：

	.site-author-image {
	  display: block;
	  margin: 0 auto;
	  padding: $site-author-image-padding;
	  max-width: $site-author-image-width;
	  height: $site-author-image-height;
	  border: $site-author-image-border-width solid $site-author-image-border-color;
	
	  /* 头像圆形 */
	  border-radius: 80px;
	  -webkit-border-radius: 80px;
	  -moz-border-radius: 80px;
	  box-shadow: inset 0 -1px 0 #333sf;
	
	  /* 设置循环动画 [animation: (play)动画名称 (2s)动画播放时长单位秒或微秒 (ase-out)动画播放的速度曲线为以低速结束 
	    (1s)等待1秒然后开始动画 (1)动画播放次数(infinite为循环播放) ]*/
	 
	
	  /* 鼠标经过头像旋转360度 */
	  -webkit-transition: -webkit-transform 1.0s ease-out;
	  -moz-transition: -moz-transform 1.0s ease-out;
	  transition: transform 1.0s ease-out;
	}
	
	img:hover {
	  /* 鼠标经过停止头像旋转 
	  -webkit-animation-play-state:paused;
	  animation-play-state:paused;*/
	
	  /* 鼠标经过头像旋转360度 */
	  -webkit-transform: rotateZ(360deg);
	  -moz-transform: rotateZ(360deg);
	  transform: rotateZ(360deg);
	}
	
	/* Z 轴旋转动画 */
	@-webkit-keyframes play {
	  0% {
	    -webkit-transform: rotateZ(0deg);
	  }
	  100% {
	    -webkit-transform: rotateZ(-360deg);
	  }
	}
	@-moz-keyframes play {
	  0% {
	    -moz-transform: rotateZ(0deg);
	  }
	  100% {
	    -moz-transform: rotateZ(-360deg);
	  }
	}
	@keyframes play {
	  0% {
	    transform: rotateZ(0deg);
	  }
	  100% {
	    transform: rotateZ(-360deg);
	  }
	}

#### 7.头像下方添加自己的github等信息

打开主题配置文件，找到social字段，配置如下，大家可根据自己情况去配置，图片的使用方法同菜单栏一样

	social:
	  GitHub: https://github.com/username || github
	  #E-Mail: 
	  #Google: https://plus.google.com/yourname || google
	  #Twitter: https://twitter.com/yourname || twitter
	  #FB Page: https://www.facebook.com/yourname || facebook
	  #VK Group: https://vk.com/yourname || vk
	  #StackOverflow: https://stackoverflow.com/yourname || stack-overflow
	  #YouTube: https://youtube.com/yourname || youtube
	  #Instagram: https://instagram.com/yourname || instagram
	  #Skype: skype:yourname?call|chat || skype
	
	social_icons:
	  enable: true
	  #icons_only: false
	  #transition: false
	  GitHub: github
	  
#### 8.给站点添加友情链接功能

打开主题配置文件，进行如下配置：


	links_title: 友情链接
	links:
	    #百度: http://www.baidu.com/
	    #新浪: http://example.com/




##  三、next主题的高级配置和一些炫酷的效果

### （一） 增加评论系统
	
百度了一下最新的消息，当前版本的next主题中已经内置支持了各种各样的评论系统，但由于政策的原因（需要实名评论），导致大多数的评论插件都已经失效了，而国外的一些加载比较慢。

这里附上gitment的评论集成方式[集成流程](https://jingyan.baidu.com/article/2f9b480de2b5b341cb6cc2be.html)

**gitment**（依托于github issue，能够自己管理，而且被墙的概率小），不过兼容性不太好（需要chrome内核才行），本人使用的gitment，有一个小问题，就是每次发布文章时需要登录下自己的github账号去初始化一下评论，评论功能才能使用，否则会提示“未开放评论”

**Hypercomments** 是国外的一个第三方评论平台

**多说** 在2017年06月01日就关闭评论服务了

**网易云跟贴** 2017年08月01日也停止服务了

**来必力** (韩国人弄的)总是乱码

**DISQUS** 外国的，加载慢 

---

### （二） 隐藏网页底部powered By Hexo / 强力驱动


打开主题配置文件，找到如下图位置，将powered设置为 false，theme下的enable 设置为 false

![picture10](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/picture1/10.png)

---

### （三） 设置首页文章列表不显示全文(只显示预览)

* 进入hexo博客项目的themes/next目录
* 打开_config.yml文件
* 搜索"auto_excerpt",找到如下部分：


		# Automatically Excerpt. Not recommand.
		# Please use <!-- more --> in the post to control excerpt accurately.
		auto_excerpt:
		  enable: false
		  length: 150

	  
* 把enable改为对应的false改为true，length设置下，然后hexo d -g，再进主页，问题就解决了！

---

### （四） 增加本地搜索功能

#### 添加百度/谷歌/本地 自定义站点内容搜索

1. 安装 hexo-generator-searchdb，在站点的根目录下执行以下命令：

		npm install hexo-generator-searchdb --save
	
2. 编辑博客配置文件，新增以下内容到任意位置：

		search:
			  path: search.xml
			  field: post
			  format: html
			  limit: 10000
			  
3. 编辑主题配置文件，启用本地搜索功能：

		# Local search
		local_search:
		  enable: true


---

### （五） 给 hexo next 主题加上背景图片

给 hexo next 加上背景图片，只需要在 themes\next\source\css_custom\custom.styl 文件中添加几行代码：

```
@media screen and (min-width:1200px) {

    body {
    background-image:url(/images/background.jpg);
    background-repeat: no-repeat;
    background-attachment:fixed;
    background-position:50% 50%; 
    }

    #footer a {
        color:#eee;
    }
}
```

repeat、attachment、position就是调整图片的位置，不重复出现、不滚动等等。

完成这一步其实背景就会自动更换了，但是会出现一个问题，因为next主题的背景是纯透明的，这样子就造成背景图片的影响看不见文字，这对于博客来说肯定不行。

那么就需要调整背景的不透明度了。同样是修改themes\next\source\css\ _custom\custom.styl文件。在后面添加如下代码

```
.main-inner { 
    margin-top: 60px;
    padding: 60px 60px 60px 60px;
    background: #fff;
    opacity: 0.8;
    min-height: 500px;
}
```

background: #fff; 白色

opacity: 0.8;不透明度

### （六） 其他炫酷效果可参考 [hexo的next主题个性化教程:打造炫酷网站](https://www.jianshu.com/p/f054333ac9e6)


---