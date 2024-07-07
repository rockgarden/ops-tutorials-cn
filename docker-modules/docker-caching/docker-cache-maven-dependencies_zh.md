# [使用 Docker 缓存 Maven 依赖项](https://www.baeldung.com/ops/docker-cache-maven-dependencies)

1. 简介

    在本教程中，我们将介绍如何在 Docker 中构建 Maven 项目。首先，我们将从一个简单的单模块 Java 项目开始，展示如何利用 Docker 中的多阶段构建功能，将构建过程 docker 化。接下来，我们将展示如何使用 Buildkit 在多个构建之间缓存依赖关系。最后，我们将介绍如何在多模块应用程序中利用层缓存。

2. 多阶段分层构建

    在本文中，我们将创建一个简单的 Java 应用程序，并将 [Guava](https://www.baeldung.com/guava-guide) 作为依赖项。我们将使用 [maven-assembly](https://www.baeldung.com/executable-jar-with-maven) 插件创建一个胖 JAR。由于代码和 Maven 配置不是本文的主要内容，因此将从本文中略去。

    多阶段构建是优化 Docker 构建过程的好方法。它能让我们将整个过程保存在单个文件中，还能帮助我们尽可能缩小 Docker 映像。在第一阶段，我们将运行 Maven 构建并创建胖 JAR，在第二阶段，我们将复制 JAR 并定义入口点：

    ```dockerfile
    FROM maven:alpine as build
    ENV HOME=/usr/app
    RUN mkdir -p $HOME
    WORKDIR $HOME
    ADD . $HOME
    RUN mvn package

    FROM openjdk:8-jdk-alpine
    COPY --from=build /usr/app/target/single-module-caching-1.0-SNAPSHOT-jar-with-dependencies.jar /app/runner.jar
    ENTRYPOINT java -jar /app/runner.jar
    ```

    由于 Docker 镜像不包含 Maven 可执行文件或我们的源代码，因此这种方法能让我们的最终 Docker 镜像更小。

    让我们创建 Docker 镜像：

    `docker build -t maven-caching .`

    接下来，让我们从映像中启动一个容器：

    `docker run maven-caching`

    当我们修改代码并重新运行构建时，我们会发现 Maven 包任务之前的所有命令都被缓存并立即执行。由于代码更改的频率比项目依赖关系更改的频率更高，因此我们可以使用 Docker 层缓存将依赖关系下载和代码编译分开，以缩短构建时间：

    ```dockerfile
    FROM maven:alpine as build
    ENV HOME=/usr/app
    RUN mkdir -p $HOME
    WORKDIR $HOME
    ADD pom.xml $HOME
    RUN mvn verify --fail-never
    ADD . $HOME
    RUN mvn package

    FROM openjdk:8-jdk-alpine 
    COPY --from=build /usr/app/target/single-module-caching-1.0-SNAPSHOT-jar-with-dependencies.jar /app/runner.jar
    ENTRYPOINT java -jar /app/runner.jar
    ```

    由于 Docker 会从缓存中获取层，因此当我们只更改代码时，运行后续构建会更快。

3. 使用 BuildKit 进行缓存

    Docker 18.09 版引入了 BuildKit，对现有的构建系统进行了全面改造。大修背后的理念是提高性能、存储管理和安全性。我们可以利用 BuildKit 保留多个构建之间的状态。这样，Maven 就不会每次都下载依赖项，因为我们有永久存储。要在 Docker 安装中启用 BuildKit，我们需要编辑 daemon.json 文件：

    ```yml
    ...
    {
        "features": {
            "buildkit": true
        }
    }
    ...
    ```

    启用 BuildKit 后，我们可以将 Dockerfile 改为

    ```dockerfile
    FROM maven:alpine as build
    ENV HOME=/usr/app
    RUN mkdir -p $HOME
    WORKDIR $HOME
    ADD . $HOME
    RUN --mount=type=cache,target=/root/.m2 mvn -f $HOME/pom.xml clean package

    FROM openjdk:8-jdk-alpine
    COPY --from=build /usr/app/target/single-module-caching-1.0-SNAPSHOT-jar-with-dependencies.jar /app/runner.jar
    ENTRYPOINT java -jar /app/runner.jar
    ```

    当我们更改代码或 pom.xml 文件时，Docker 将始终执行 ADD 和 RUN Maven 命令。第一次运行时的构建时间最长，因为 Maven 需要下载依赖项。随后的运行将使用本地依赖项，执行速度会快很多。

    这种方法需要维护 Docker 卷，作为依赖项的存储空间。有时，我们必须使用 Dockerfile 中的 -U 标志强制 Maven 更新依赖项。

4. 多模块 Maven 项目的缓存

    在前面的章节中，我们展示了如何利用不同的方法来加快单模块 Maven 项目的 Docker 镜像构建时间。对于更复杂的应用，这些方法并非最佳选择。多模块 Maven 项目通常有一个模块作为应用程序的入口。一个或多个模块包含我们的逻辑，并被列为依赖项。

    由于子模块被列为依赖项，它们会阻止 Docker 进行层缓存，并触发 Maven 重新下载所有依赖项。这种使用 BuildKit 的解决方案在大多数情况下都不错，但正如我们所说，它可能需要不时强制更新，以获取更新的子模块。为了避免这种情况，我们可以将项目分层，并使用 Maven 增量构建：

    ```dockerfile
    FROM maven:alpine as build
    ENV HOME=/usr/app
    RUN mkdir -p $HOME
    WORKDIR $HOME

    ADD pom.xml $HOME
    ADD core/pom.xml $HOME/core/pom.xml
    ADD runner/pom.xml $HOME/runner/pom.xml

    RUN mvn -pl core verify --fail-never
    ADD core $HOME/core
    RUN mvn -pl core install
    RUN mvn -pl runner verify --fail-never
    ADD runner $HOME/runner
    RUN mvn -pl core,runner package

    FROM openjdk:8-jdk-alpine
    COPY --from=build /usr/app/runner/target/runner-0.0.1-SNAPSHOT-jar-with-dependencies.jar /app/runner.jar
    ENTRYPOINT java -jar /app/runner.jar
    ```

    在这个 Dockerfile 中，我们复制了所有 pom.xml 文件并逐步构建每个子模块，最后打包整个应用程序。经验法则是，我们会在链中较后的位置构建变化更频繁的子模块。

5. 总结

    本文介绍了如何使用 Docker 构建 Maven 项目。首先，我们介绍了如何利用分层来缓存变化不频繁的部分。接着，我们介绍了如何使用 BuildKit 在两次构建之间保持状态。最后，我们展示了如何通过增量构建来构建多模块 Maven 项目。
