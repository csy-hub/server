1、平常修改代码，提交代码到dev环境推荐使用idea的图形化界面操作
2、代码合并dev合并到test,版本信息提交，推荐使用命令行操作
3、git submodule deinit -f <文件名>
    如在pass目录中使用git submodule deinit -f SPass-channel可以将你不接触到的代码在本地删除掉
    注：只是在本地删除了，实际没有删除，可以使用>git submodule update --init恢复代码（pass目录中）
4、git submodule 可以查看当前项目子模块的版本号
5、git status可以查看项目的提交信息
6、git reflog 可以查看项目日志信息
7、git log查看详细日志信息
8、git remote -v查看远程关联的服务器
9、git remote rm <远程服务器名>删除与远程服务器的名称
10、git remote add <远程服务器名> <服务器地址url> 建立与远程服务器的联系
11、git push -u <远程服务器名> --all 将代码推送至远程服务器
12、git branch -a查看所有分支
13、git branch -vv查看当前分支
14、git branch <分支名> 新建本地分支
15、git checkout <分支名> 切换分支
16、git add <文件名>将文件添加到git管理
    注：git add . 全部添加（建议不要在idea中使用，会把idea的多余文件添加进去)
17、git commit -m '注释的信息' 将代码添加到工作区
18、git push 将代码推送至远程服务器
19、git merge <分支名>将<分支名>与当前分支合并
