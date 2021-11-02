# GWU_CSCI_6221 Advanced Software Paradigms
Group members: Tianheng Wu, Jenny Fisher, Yiming Liang, Wen Liu

first presentation slide：https://docs.google.com/presentation/d/10fPzRJKapS7T-0VcfcUySRjqKje9DJozMasQeG2W-CA/edit#slide=id.gf4a2de055e_12_0
second presentation slide：https://docs.google.com/presentation/d/1eUYHv9UQpJ4d9GBfFFpgmSqsrwC0Bcr2fbo9pE9ACi8/edit#slide=id.gc6f75fceb_0_0



If don’t know how to use Git, you can visit this website first. Basically there is introduction.：https://git-scm.com/book/zh/v2/

```
1.Initialize the repo in an existing directory
$ cd /c/user/my_project
$ git init

2.If you are versioning in a folder with existing files (not an empty folder), you should start tracking these files and make the initial commit. You can use the git add command to specify the required files for tracking, and then execute git commit：
$ git add *.c
$ git add LICENSE
$ git commit -m 'initial project version

3.Clone an existing repo
The command to clone a repository is git clone <url>. For example, to clone the Git link library libgit2, you can use the following command:
$ git clone https://github.com/libgit2/libgit2

If you want to customize the name of the local repo when cloning a remote repo, you can specify a new directory name with additional parameters:
$ git clone https://github.com/libgit2/libgit2 mylibgit

4.each change updates to the repo
Check current file status:
$ git status

Track new files
$ git add README

Submit an update
$ git commit -m "comment..."

5.Push to remote repo
$ git push origin master
```



