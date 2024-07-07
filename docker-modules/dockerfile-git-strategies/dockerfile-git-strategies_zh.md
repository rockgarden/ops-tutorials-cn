# [针对Git的Dockerfile策略](https://www.baeldung.com/ops/dockerfile-git-strategies)

1. 简介

    Git是软件开发领域领先的版本控制系统。另一方面，Dockerfile包含了自动构建我们应用程序的镜像的所有命令。这两个产品对于任何寻求采用[DevOps](https://www.baeldung.com/ops/devops-overview)的人来说都是完美的组合。

    在本教程中，我们将学习一些解决方案来结合这两种技术。我们将深入了解每个解决方案的细节，并介绍其优点和缺点。

2. Git仓库内的Dockerfile

    要想在Dockerfile中随时访问Git仓库，最简单的办法是将Dockerfile直接放在Git仓库中：

    ```txt
    ProjectFolder/
    .git/
    src/
    pom.xml
    Dockerfile
    ...
    ```

    上面的设置将使我们能够访问整个项目的源代码目录。接下来，我们可以用[ADD命令](https://www.baeldung.com/ops/docker-copy-add)将其包含在我们的容器中，比如说：

    `ADD . /project/`

    当然，我们可以将复制的范围限制在构建目录中：

    `ADD /build/ /project/`

    或一个构建输出，如.jar文件：

    `ADD /output/project.jar /project/`

    这个方案最大的优点是，我们可以测试任何代码的修改，而不需要提交到版本库中。所有的东西都将live在同一个本地目录中。

    这里需要记住的一点是，要创建一个[.dockerignore](https://docs.docker.com/engine/reference/builder/#dockerignore-file)文件。它类似于.gitignore文件，但在这种情况下，它从Docker上下文中排除符合模式的文件和目录。这有助于我们避免不必要地将大的或敏感的文件和目录发送到Docker构建过程中，并可能将它们添加到镜像中。

3. 克隆 Git 仓库

    另一个简单的解决方案是在镜像构建过程中直接获取我们的git仓库。我们可以通过简单地将[SSH密钥](https://www.baeldung.com/linux/generating-ssh-keys-in-linux)添加到本地仓库并调用git clone命令来实现：

    ```zsh
    ADD ssh-private-key /root/.ssh/id_rsa
    RUN git clone git@github.com:eugenp/tutorials.git
    ```

    上述命令将获取整个仓库并将其放在我们容器中的./tutorials目录下。

    不幸的是，这个解决方案也有一些弊端。

    首先，我们将在Docker镜像中存储我们的私人SSH密钥，这可能带来潜在的安全问题。我们可以通过使用git仓库的用户名和密码来应用一个变通方法：

    ```bash
    ARG username=$GIT_USERNAME
    ARG password=$GIT_PASSWORD
    RUN git clone https://username:password@github.com:eugenp/tutorials.git
    ```

    并把它们作为[环境变量](https://www.baeldung.com/ops/docker-container-environment-variables)从我们的机器上传过去。这样我们就可以把git证书留在我们的镜像之外。

    其次，这一步将在以后的构建中被缓存，即使我们的仓库发生变化。这是因为有RUN命令的那一行是不变的，除非你破坏了早期步骤的缓存。虽然，我们可以通过在docker build命令中加入-no-cache参数来解决这个问题。

    另一个小缺点是，我们必须在容器中安装git包。

4. 卷映射

    我们可以使用的第三个解决方案是[卷映射](https://www.baeldung.com/ops/docker-volumes)。它给我们带来了将目录从我们的机器挂载到Docker容器中的能力。这是一种用于存储Docker容器所使用的数据的首选机制。

    我们可以通过在我们的Docker文件中添加以下一行来做到这一点：

    `VOLUME /build/ /project/`

    这将在容器上创建/project目录，并将其挂载到我们机器上的/build目录。

    当我们的Git仓库只是用于构建过程时，卷映射将是最好的选择。通过将仓库放在容器之外，我们不会增加它的大小，并允许仓库的内容在特定容器的生命周期之外。

    我们需要记住的一点是，卷映射给了Docker容器对挂载目录的写入权限。不正确地使用这个功能可能会导致git仓库目录发生一些不必要的变化。

5. Git子模块

    当我们把Docker文件和源代码保存在不同的仓库中，或者我们的Docker构建需要多个源代码仓库时，我们可以考虑使用Git子模块。

    首先，我们必须创建一个新的Git仓库，并将我们的Docker文件放在那里。接下来，我们可以通过添加到.gitmodules文件中来定义我们的子模块：

    ```txt
    [submodule "project"]
    path = project
    url = https://github.com/eugenp/tutorials.git
    branch = master
    ```

    现在，我们可以像一个标准的目录一样使用这个子模块。例如，我们可以将其内容复制到我们的容器中：

    `ADD /build/ /project/`

    记住，子模块不会自动更新。我们需要运行下面的git命令来获取最新的变化：

    `git submodule update --init --recursive`

6. 概述

    在本教程中，我们已经学会了在Docker文件中使用Git仓库的几种方法。
