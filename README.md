# csci_6221（开发的话，尽量使用dev分支，我们所有的代码都先提交到dev分支上去，然后最后合并到master分支。）
GWU CSCI_6221 Advanced Software Paradigms：

仓库地址：https://github.com/WillSilent/csci_6221.git

不懂得git如何使用的，可以先看一下这个网站，基本上都有介绍：https://git-scm.com/book/zh/v2/

### 1.获取或建立repo

#### 1.1 在已存在目录中初始化仓库

- ​	进入已存在目录后初始化目录，

  ```
  $ cd /c/user/my_project
  $ git init
  ```

- 如果在一个已存在文件的文件夹（而非空文件夹）中进行版本控制，你应该开始追踪这些文件并进行初始提交。可以通过 git add 命令来指定所需的文件来进行追踪，然后执行 git commit ：

  ```
  $ git add *.c
  $ git add LICENSE
  $ git commit -m 'initial project version
  ```

#### 1.2 克隆现有的仓库

- 克隆仓库的命令是 git clone <url> 。 比如，要克隆 Git 的链接库 libgit2，可以用下面的命令：

  ```
  $ git clone https://github.com/libgit2/libgit2
  ```

- 如果你想在克隆远程仓库的时候，自定义本地仓库的名字，你可以通过额外的参数指定新的目录名：

  ```
  $ git clone https://github.com/libgit2/libgit2 mylibgit
  ```



