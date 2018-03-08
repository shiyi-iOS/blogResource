---
title: Mac电脑利用命令行上传本地项目到github
date: 2018-03-05 16:11:59
tags: [hexo,cube]
categories: [技术]
---

## 一、准备工作
>注：如果是第一次上传文件，就乖乖的按照下面的步骤，如果不是首次，就看文章最后面的步骤（那就简单多了！！）

1、在github上创建项目的仓库
进入github官网，登陆账号后，可以看到右上角的头像。点击头像左侧的加号按钮，选择new repository，创建仓库。

![如图](https://raw.githubusercontent.com/gegewu-iOS/image/master/Mac%E7%94%B5%E8%84%91%E5%88%A9%E7%94%A8%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%B8%8A%E4%BC%A0%E6%9C%AC%E5%9C%B0%E9%A1%B9%E7%9B%AE/%E5%88%9B%E5%BB%BA%E4%BB%93%E5%BA%93.png)

2、填写项目工程的基本信息

(1)填写你需要上传工程的名称。(和打算上传的项目文件夹名称可以不一致)。

(2)勾选上“Initialize this repository with a README”选项。 

(3)点击“create repository”。

![如图](https://raw.githubusercontent.com/gegewu-iOS/image/master/Mac%E7%94%B5%E8%84%91%E5%88%A9%E7%94%A8%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%B8%8A%E4%BC%A0%E6%9C%AC%E5%9C%B0%E9%A1%B9%E7%9B%AE/%E5%B7%A5%E7%A8%8B%E4%BF%A1%E6%81%AF.png)

--
## 二、前言

1、在https://github.com/网站上创建自己的项目，如图：

![如图](https://raw.githubusercontent.com/gegewu-iOS/image/master/Mac%E7%94%B5%E8%84%91%E5%88%A9%E7%94%A8%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%B8%8A%E4%BC%A0%E6%9C%AC%E5%9C%B0%E9%A1%B9%E7%9B%AE/%E5%9B%BE%E4%B8%80.png)

2、安装git（mac电脑只要安装了Xcode，就可以直接使用git了），在终端输入命令：git version测试，如果正常显示git版本号就说明已经安装好了。

3、创建一个文件夹，cd到此文件夹下（可以将文件拖入终端获取文件路径）例如：cd /Users/gegewu/Desktop/test。

4、初始化：git init

5、配置ssh（若是根据上篇文章搭建博客，则ssh已创建好，可省略此步骤）输入：ssh-keygen -t rsa -c "117@qq.com"(邮箱替换成你登录github的邮箱)，一路enter过来（中间有的问题是选y/n的，选y即可，要是让你输入密码，直接回车则是不设置密码，直接回车就可以),最后显示:

![如图](https://raw.githubusercontent.com/gegewu-iOS/image/master/Mac%E7%94%B5%E8%84%91%E5%88%A9%E7%94%A8%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%B8%8A%E4%BC%A0%E6%9C%AC%E5%9C%B0%E9%A1%B9%E7%9B%AE/%E5%9B%BE%E4%BA%8C%20.jpg)

找到上图红框圈住的文件（in 后面即为该文件地址，前往文件夹赋值路径可找到),用sublime text或其他编辑器打开（不要用mac自带的文本编辑器，最后会出现乱码，本人已踩坑），Ctrl + a赋值里面的所有内容，然后进入Sign in to GitHub：[github.com/settings/ssh](https://github.com/settings/keys)

一步步操作：
New SSH key ——Title：blog(blog替换成你的标题) —— Key：输入刚才复制的—— Add SSH key

>注：此过程是生成ssh key，如后续再次执行此命令时，则需要把新生成SSH key再配置到github中，因为新生成的SSH key会覆盖之前的，如不去github中替换会导致后续上传git服务器过程中失败。

6、再次打开终端，验证一下是否添加ssh成功，输入：ssh -T git@github.com,中间有的问题是选y/n的，选y继续回车，当终端显示：
![如图](https://raw.githubusercontent.com/gegewu-iOS/image/master/Mac%E7%94%B5%E8%84%91%E5%88%A9%E7%94%A8%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%B8%8A%E4%BC%A0%E6%9C%AC%E5%9C%B0%E9%A1%B9%E7%9B%AE/ssh%E6%B7%BB%E5%8A%A0%E6%88%90%E5%8A%9F.png)

则添加成功，若显示permission denied，再执行命令：ssh-add ~/.ssh/id_test_rsa，再次输入ssh -T git@github.com,提示成功了就可以继续，要是还没有成功，就google一下报什么错。

7、(若是根据上篇文章搭建博客，则ssh已创建好，可省略此步骤),在git config里设置你的github登录名和登录邮箱，双引号内的内容替换成你的信息就可以了。

>git config --global user.name "your name"  

>git config --global user.email "your_email@youremail.com" 

## 三、现在就开始上传项目啦！！
8、将你的项目拉倒这个文件夹中，执行命令：git status，这个时候，你会看到所有的改动。

![rutu](https://raw.githubusercontent.com/gegewu-iOS/image/master/Mac%E7%94%B5%E8%84%91%E5%88%A9%E7%94%A8%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%B8%8A%E4%BC%A0%E6%9C%AC%E5%9C%B0%E9%A1%B9%E7%9B%AE/gitStatus%E6%95%88%E6%9E%9C%E5%9B%BE.png)


9、然后执行 git add . (别忘了这个点哦，这个点表示所有的改动)。

10、然后执行命令 git commit -m "第一次更新"  (双引号里的内容随意写，是github中项目后面的备注)

![rutu](https://raw.githubusercontent.com/gegewu-iOS/image/master/Mac%E7%94%B5%E8%84%91%E5%88%A9%E7%94%A8%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%B8%8A%E4%BC%A0%E6%9C%AC%E5%9C%B0%E9%A1%B9%E7%9B%AE/gitAdd%E6%95%88%E6%9E%9C%E5%9B%BE.png)

11、然后执行命令：git remote add github https://github.com/你的用户名/github项目名.git（后面的地址可以从下面标注的地方找到）
![rutu](https://raw.githubusercontent.com/gegewu-iOS/image/master/Mac%E7%94%B5%E8%84%91%E5%88%A9%E7%94%A8%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%B8%8A%E4%BC%A0%E6%9C%AC%E5%9C%B0%E9%A1%B9%E7%9B%AE/%E7%94%A8%E6%88%B7%E5%90%8D%E5%9C%B0%E5%9D%80.png)
12、之后执行命令：git push -f github
提交到github上
现在回到你的github页面，刷新一下（服务器反应需要时间，我的电脑等了好久才看到），看看

![rutu](https://raw.githubusercontent.com/gegewu-iOS/image/master/Mac%E7%94%B5%E8%84%91%E5%88%A9%E7%94%A8%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%B8%8A%E4%BC%A0%E6%9C%AC%E5%9C%B0%E9%A1%B9%E7%9B%AE/%E4%B8%8A%E4%BC%A0%E5%90%8E%E6%95%88%E6%9E%9C%E5%9B%BE.png)
>注：本地文件如有继续改动，从第8步开始重新执行。

---
## 接下来就说说非首次上传文件的步骤啦！
1、
![rutu](https://raw.githubusercontent.com/gegewu-iOS/image/master/Mac%E7%94%B5%E8%84%91%E5%88%A9%E7%94%A8%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%B8%8A%E4%BC%A0%E6%9C%AC%E5%9C%B0%E9%A1%B9%E7%9B%AE/uploadFile.png)

2、把文件直接拖拽到图中1处的框框里
![rutu](https://raw.githubusercontent.com/gegewu-iOS/image/master/Mac%E7%94%B5%E8%84%91%E5%88%A9%E7%94%A8%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%B8%8A%E4%BC%A0%E6%9C%AC%E5%9C%B0%E9%A1%B9%E7%9B%AE/%E6%8F%90%E4%BA%A4%E9%9D%9E%E9%A6%96%E6%AC%A1%E6%96%87%E4%BB%B6.png)