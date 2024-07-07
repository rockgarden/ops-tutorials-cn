# [Docker Compose简介](https://www.baeldung.com/ops/docker-compose)

1. 概述
    当广泛使用Docker时，对几个不同的容器的管理很快就会变得很麻烦。
    Docker Compose是一个帮助我们克服这个问题的工具，它可以轻松地同时处理多个容器。
    在本教程中，我们将研究它的主要功能和强大的机制。
2. 解释YAML配置
    简而言之，Docker Compose的工作方式是应用在单个docker-compose.yml配置文件中声明的许多规则。
    这些[YAML](https://en.wikipedia.org/wiki/YAML)规则，既是人类可读的，也是机器优化的，提供了一种有效的方式，可以在几行中从万丈高楼平地起，对整个项目进行快照。

    几乎每条规则都取代了一个特定的Docker命令，所以最后我们只需要运行：
    `docker-compose up`

    我们可以在引擎盖下得到几十个由Compose应用的配置。这将使我们省去用Bash或其他东西编写脚本的麻烦。
    在这个文件中，我们需要指定Compose文件格式的版本，至少一个服务，以及可选的卷和网络：

    ```yml
    version: "3.7"
    services:
    ...
    volumes:
    ...
    networks:
    ...
    ```

    让我们看看这些元素到底是什么。

    1. 服务

        首先，服务指的是容器的配置。
        例如，让我们来看看一个由前端、后端和数据库组成的docker化网络应用。我们可能会把这些组件分成三个镜像，并在配置中把它们定义为三个不同的服务：

        ```yml
        services:
        frontend:
            image: my-vue-app
            ...
        backend:
            image: my-springboot-app
            ...
        db:
            image: postgres
            ...
        ```

        有多种设置我们可以应用于服务，我们将在后面详细探讨。
    2. 卷和网络

        另一方面，Volumes是主机和容器之间，甚至是容器之间共享的磁盘空间的物理区域。换句话说，卷是主机中的一个共享目录，从一些或所有的容器中可见。
        同样地，Networks定义了容器之间以及容器和主机之间的通信规则。公共网络区域将使容器的服务可以被对方发现，而私有区域将把它们隔离在虚拟沙盒中。
        同样，我们将在下一节中进一步了解它们。

3. 剖析一个服务

    现在让我们开始检查一个服务的主要设置。
    1. 拉取一个图像

        有时，我们的服务需要的镜像已经在Docker Hub或其他Docker注册中心发布（由我们或其他人发布）。
        如果是这种情况，那么我们通过指定镜像名称和标签，用镜像属性来引用它：

        ```yml
        services: 
        my-service:
            image: ubuntu:latest
            ...
        ```

    2. 构建一个镜像

        另外，我们可能需要通过读取Docker文件从源代码中构建一个镜像。
        这一次，我们将使用[build](https://docs.docker.com/compose/compose-file/#build)关键字，将Dockerfile的路径作为值传递：

        ```yml
        services: 
        my-custom-app:
            build: /path/to/dockerfile/
            ...
        ```

        我们也可以用一个URL来代替路径：

        ```yml
        services: 
        my-custom-app:
            build: https://github.com/my-company/my-project.git
            ...
        ```

        此外，我们可以在build属性中指定一个镜像名称，一旦创建了镜像，它就会被命名，使其[可被其他服务使用](https://stackoverflow.com/a/35662191/1654265)：

        ```yml
        services: 
        my-custom-app:
            build: https://github.com/my-company/my-project.git
            image: my-project-image
            ...
        ```

    3. 配置网络

        Docker容器通过Docker Compose隐含地或通过配置创建的网络在它们之间进行通信。一个服务可以与同一网络中的另一个服务进行通信，只需通过容器名称和端口来引用它（例如network-example-service:80），前提是我们已经通过expose关键字使端口可以访问：

        ```yml
        services:
        network-example-service:
            image: karthequian/helloworld:latest
            expose:
            - "80"
        ```

        在这种情况下，不用暴露它也可以工作，因为暴露指令已经在镜像的[Docker文件](https://github.com/karthequian/docker-helloworld/blob/master/Dockerfile#L45)中了。
        要从主机上到达一个容器，必须通过ports关键字声明性地暴露端口，这也允许我们选择是否在主机上以不同的方式暴露端口：

        ```yml
        services:
        network-example-service:
            image: karthequian/helloworld:latest
            ports:
            - "80:80"
            ...
        my-custom-app:
            image: myapp:latest
            ports:
            - "8080:3000"
            ...
        my-custom-app-replica:
            image: myapp:latest
            ports:
            - "8081:3000"
            ...
        ```

        80端口现在将从主机中可见，而另外两个容器的3000端口将在主机中的8080和8081端口上可用。这个强大的机制让我们可以运行不同的容器，暴露相同的端口而不发生碰撞。
        最后，我们可以定义额外的虚拟网络来隔离我们的容器：

        ```yml
        services:
        network-example-service:
            image: karthequian/helloworld:latest
            networks: 
            - my-shared-network
            ...
        another-service-in-the-same-network:
            image: alpine:latest
            networks: 
            - my-shared-network
            ...
        another-service-in-its-own-network:
            image: alpine:latest
            networks: 
            - my-private-network
            ...
        networks:
        my-shared-network: {}
        my-private-network: {}
        ```

        在这最后一个例子中，我们可以看到，同一网络中的另一个服务将能够ping到网络-示例服务的80端口，而它自己网络中的另一个服务则不能。
    4. 设置卷

        有三种类型的卷：[匿名anonymous、命名named和主机host](https://success.docker.com/article/different-types-of-volumes)。
        Docker同时管理匿名卷和命名卷，自动将它们挂载到主机中自行生成的目录中。虽然匿名卷对旧版本的Docker（1.9之前）很有用，但现在建议使用命名卷。主机卷也允许我们在主机中指定一个现有的文件夹。
        我们可以在服务层面上配置主机卷，在配置的外部层面上配置命名卷，以便使后者对其他容器可见，而不是只对它们所属的容器：

        ```yml
        services:
        volumes-example-service:
            image: alpine:latest
            volumes: 
            - my-named-global-volume:/my-volumes/named-global-volume
            - /tmp:/my-volumes/host-volume
            - /home:/my-volumes/readonly-host-volume:ro
            ...
        another-volumes-example-service:
            image: alpine:latest
            volumes:
            - my-named-global-volume:/another-path/the-same-named-global-volume
            ...
        volumes:
            my-named-global-volume: 
        ```

        在这里，两个容器都将有对my-named-global-volume共享文件夹的读/写访问权，不管他们把它映射到哪个路径。相反，这两个主机卷将只对volumes-example-service可用。
        主机文件系统的/tmp文件夹被映射到容器的/my-volumes/host-volume文件夹。文件系统的这一部分是可写的，这意味着容器可以读取也可以写入（和删除）主机中的文件。
        我们可以通过在规则中添加`:ro`来挂载一个只读模式的卷，就像对/home文件夹一样（我们不希望Docker容器错误地删除我们的用户）。
    5. 声明依赖关系

        通常情况下，我们需要在服务之间创建一个依赖链，以便一些服务在其他服务之前（或之后）被加载。我们可以通过 depends_on 关键字实现这个结果：

        ```yml
        services:
        kafka:
            image: wurstmeister/kafka:2.11-0.11.0.3
            depends_on:
            - zookeeper
            ...
        zookeeper:
            image: wurstmeister/zookeeper
            ...
        ```

        但是我们应该注意，在启动kafka服务之前，Compose不会等待zookeeper服务完成加载；它只会等待它启动。如果我们需要一个服务在启动另一个服务之前被完全加载，我们需要在Compose中更[深入地控制启动和关闭的顺序](https://docs.docker.com/compose/startup-order/)。
4. 管理环境变量

    在 Compose 中，使用环境变量是很容易的。我们可以用 ${} 符号来定义静态环境变量和动态变量：

    ```yml
    services:
    database: 
        image: "postgres:${POSTGRES_VERSION}"
        environment:
        DB: mydb
        USER: "${USER}"
    ```

    有不同的方法来提供这些值给 Compose。
    例如，一种方法是将它们设置在同一目录下的.env 文件中，结构类似于.properties 文件，key=value：

    ```properties
    POSTGRES_VERSION=alpine
    USER=foo
    ```

    否则，我们可以在调用命令之前在操作系统中设置它们：

    ```properties
    export POSTGRES_VERSION=alpine
    export USER=foo
    docker-compose up
    ```

    最后，我们可能会发现在shell中使用一个简单的单行代码很容易：

    `POSTGRES_VERSION=alpine USER=foo docker-compose up`

    我们可以混合使用这些方法，但是我们要记住，Compose使用以下的优先级顺序，用较高的优先级覆盖不太重要的内容：
    1.Compose file
    2.Shell environment variables
    3.Environment file
    4.Dockerfile
    5.Variable not defined

5. 缩放和复制

    在旧的Compose版本中，我们可以通过docker-compose scale命令来扩展容器的实例。新版本取消了这一功能，取而代之的是--scale选项。
    我们可以利用[Docker Swarm](https://docs.docker.com/engine/swarm/)，一个Docker引擎的集群，通过部署部分的replicas属性声明性地自动缩放我们的容器：

    ```yml
    services:
    worker:
        image: dockersamples/examplevotingapp_worker
        networks:
        - frontend
        - backend
        deploy:
        mode: replicated
        replicas: 6
        resources:
            limits:
            cpus: '0.50'
            memory: 50M
            reservations:
            cpus: '0.25'
            memory: 20M
        ...
    ```

    在deploy下，我们还可以指定许多其他选项，比如资源阈值。然而，Compose只在部署到Swarm时才考虑整个deploy部分，而在其他情况下则忽略它。
6. 一个现实世界的例子：Spring Cloud数据流

    虽然小的实验可以帮助我们理解单一的齿轮，但看到真实世界的代码在运行，肯定会揭开大幕。
    Spring Cloud Data Flow是一个复杂的项目，但简单到足以让人理解。让我们下载其[YAML](https://dataflow.spring.io/docs/installation/local/docker/)文件并运行：

    `DATAFLOW_VERSION=2.1.0.RELEASE SKIPPER_VERSION=2.0.2.RELEASE docker-compose up`

    Compose将下载、配置和启动每一个组件，然后将容器的日志交叉到当前终端的一个流中。
    它还会给每个人应用独特的颜色，以获得良好的用户体验。

    我们在运行一个全新的Docker Compose安装时可能会遇到以下错误：
    `lookup registry-1.docker.io: no such host`
    虽然对这个常见的陷阱有不同的[解决方案](https://stackoverflow.com/questions/46036152/lookup-registry-1-docker-io-no-such-host)，但使用8.8.8.8作为DNS可能是最简单的。
7. 生命周期管理

    现在让我们仔细看看Docker Compose的语法：
    `docker-compose [-f <arg>...] [options] [COMMAND] [ARGS...]`

    虽然有[很多选项和命令可用](https://docs.docker.com/compose/reference/overview/)，但我们至少需要知道那些选项和命令才能正确激活和停用整个系统。
    1. 启动

        我们已经看到，我们可以用up创建和启动容器、网络和配置中定义的卷：
        `docker-compose up`

        然而，在第一次之后，我们可以简单地使用start来启动服务：

        `docker-compose start`

        如果我们的文件与默认文件（docker-compose.yml）的名字不同，我们可以利用-f和--file标志来指定一个替代的文件名：
        `docker-compose -f custom-compose-file.yml start`

        当使用-d选项启动时，Compose也可以作为一个守护程序在后台运行：
        `docker-compose up -d`

    2. 关机

        为了安全地停止活动服务，我们可以使用stop，它将保留容器、卷和网络，以及对它们的每一次修改：
        `docker-compose stop`

        要重置我们项目的状态，我们可以简单地运行down，它将销毁除外部卷之外的一切：
        `docker-compose down`

8. 总结

    在这篇文章中，我们了解了Docker Compose以及它是如何工作的。

## Code

像往常一样，我们可以在GitHub上找到源码docker-compose.yml文件，以及以下图片中立即提供的一组有用的测试：

```bash
[19:03] ~/git/tutorials/docker $ docker-compose up
[19:03] ~/git/tutorials/docker $ docker exec -it volumes-example-service sh
[19:05] -/git/tutorials/docker $ docker exec -it another-volumes-example-service sh
[19:05] ~/git/tutorials/docker $ docker exec -it another-service-in-its-own-network sh
[19:11] ~/git/tutorials/docker $ docker exec -it another-service-in-the-same-network sh
[19:11] ~/git/tutorials/docker $ curl -I localhost:1337
```
