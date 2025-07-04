# [GitLab Runner 使用指南](https://www.baeldung.com/ops/gitlab-runner-guide)

DevOps  Git

Git基础

1. 概述
    [GitLab Runner](https://docs.gitlab.com/runner/) 是一个强大的工具，与 GitLab CI/CD 协同工作，用于运行任务并将结果返回给 GitLab。换句话说，它是 GitLab 持续集成和部署流水线的关键组成部分。

    作为一个在独立机器或容器上运行的代理，GitLab Runner 的主要目的是执行来自 GitLab CI/CD 配置的任务。当我们向 GitLab 仓库推送代码时，Runner 会接收任务，运行指定命令，并将结果报告回 GitLab。

    因此，使用 GitLab Runner 可以自动化构建、测试和部署流程，节省时间并降低人为错误的风险。

    在本教程中，我们将学习如何设置和配置 GitLab Runner，以及它的各种功能和能力。

2. 入门指南

    在使用 GitLab Runner 之前，我们需要先进行安装和配置，使其能够与 GitLab 实例协同工作。在本节中，我们将逐步介绍安装 GitLab Runner、将其注册到 GitLab 以及根据当前需求定制配置的过程。

    1. 安装 GitLab Runner

        首先，我们需在目标机器上安装 GitLab Runner。GitLab Runner 支持多种操作系统，包括 Linux、macOS 和 Windows，不同系统上的安装过程略有差异。

        例如，在基于 Debian 的 Linux 系统上，我们可以通过添加官方 GitLab 仓库并使用 [`apt`](https://www.baeldung.com/linux/debian-installing-packages-url#1-apt-advanced-packaging-tool) 包管理器安装 `gitlab-runner` 软件包：

        ```bash
        # 添加 GitLab Runner 仓库
        curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
        # 保持 Runner 主版本与 GitLab 一致（如 17.x 配 17.x）
        sudo apt-get install gitlab-runner
        ```

        yum：

        ```bash
        # 添加 GitLab Runner 仓库
        curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash
        # 保持 Runner 主版本与 GitLab 一致（如 17.x 配 17.x）
        sudo yum install gitlab-runner
        ```

        Anolis 8环境安装：

        ```bash
        # os=centos 表示使用 CentOS 兼容仓库，dist=8 对应 Anolis 8
        sudo curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/config_file.repo?os=centos&dist=8&source=script" \
            --header 'User-Agent: Mozilla/5.0' \
            -o /etc/yum.repos.d/runner_gitlab-runner.repo
        # 安装特定版本（如 17.11.3）
        sudo yum install gitlab-runner-17.11.3-1
        # 设置开机自启
        sudo systemctl enable --now gitlab-runner
        # 检查版本
        gitlab-runner --version
        # 查看运行状态
        gitlab-runner status
        ```

        这段脚本会下载 GitLab Runner 的安装脚本，并以超级用户权限执行它。它将配置仓库并添加必要的系统设置。

        此外，GitLab Runner 文档中也提供了适用于其他操作系统的[安装说明](https://docs.gitlab.com/ee/install/)。

    2. 注册 Runner

        安装完成后，下一步是将其注册到 GitLab 实例。Runner 的注册会在 Runner 与 GitLab 之间建立连接，使它们能够通信并执行任务。

        要注册 Runner，我们需要从 GitLab 项目的“设置”页面获取注册令牌（Registration Token）。具体来说，在 GitLab 中导航至项目或组的 **Settings > CI/CD** 页面，展开 **Runners** 部分即可找到该令牌。

        获得令牌后，我们可以使用以下命令注册 Runner：

        ```bash
        sudo gitlab-runner register
        ```

        此命令会提示输入多个信息，如 GitLab 实例的 URL、注册令牌、Runner 描述以及执行器类型（如 shell、Docker、Kubernetes）等。

        注册完成后，Runner 即可开始接收 GitLab 的任务。

        示例：

        ```sh
        sudo gitlab-runner register \
        --url "https://www.eastcomccmp.top/egitlab" \
        --registration-token "glrt-yPAW4Qy8sysQikxs54t7" \
        --description "shell-runner-shared" \
        --tag-list "shell,anolis" \
        --executor "shell" \
        --non-interactive
        ```

        ```sh
        # 检查Runner连接状态
        gitlab-runner verify
        # 查看已注册Runner  
        gitlab-runner list
        ```

    3. 配置 Runner

        注册完 Runner 后，我们可能需要进一步配置以满足特定项目的需求。Runner 的配置文件通常位于 Linux 系统的 `/etc/gitlab-runner/config.toml` 中。

        在配置文件中，我们可以指定并发任务限制、缓存设置和环境变量等选项。

        例如，如果我们想限制 Runner 可同时处理的任务数量，可以添加 `concurrent` 参数：

        ```toml
        concurrent = 4
        ```

        此外，我们还可以定义供任务使用的自定义环境变量：

        ```toml
        [[runners]]
        environment = ["MY_VARIABLE=value"]
        ```

        这些只是可用配置选项中的几个示例。

        完成安装、注册和配置后，我们就可以开始在 `.gitlab-ci.yml` 文件中定义任务，让 GitLab Runner 自动执行任务了。

3. GitLab CI/CD 配置

    现在我们已经完成了 GitLab Runner 的安装和配置，接下来我们深入探讨如何配置 GitLab CI/CD 流水线。在本节中，我们将学习如何创建 `.gitlab-ci.yml` 文件、定义任务和阶段，并使用变量和密钥来定制流水线。

    1. 创建 `.gitlab-ci.yml` 文件

        `.gitlab-ci.yml` 文件是 GitLab CI/CD 配置的核心。它位于仓库根目录中，包含 GitLab Runner 执行任务所需的指令。

        让我们从在项目根目录下创建一个新的 `.gitlab-ci.yml` 文件开始。

    2. 定义任务和阶段

        在 `.gitlab-ci.yml` 文件中，我们定义任务（jobs）和阶段（stages）。任务代表我们要运行的特定操作或命令，而阶段则定义任务的执行顺序。

        来看一个简单的 `.gitlab-ci.yml` 示例，其中包含两个阶段和两个任务：

        ```yaml
        stages:
        - build
        - test

        build-job:
        stage: build
        script:
            - echo "Building the project..."
            - npm install
            - npm run build

        test-job:
        stage: test
        script:
            - echo "Running tests..."
            - npm run test
        ```

        在这个例子中，我们有两个阶段：

        - `build`
        - `test`

        `build-job` 属于 `build` 阶段，负责安装依赖并构建项目；`test-job` 属于 `test` 阶段，负责运行项目测试。

    3. 使用变量和密钥

        GitLab CI/CD 允许我们使用变量和密钥来存储敏感信息或配置流水线的不同部分。变量可以在项目、群组或实例级别定义，并可在 `.gitlab-ci.yml` 文件的任意任务脚本中访问。

        要定义变量，我们可以进入项目的 **Settings > CI/CD > Variables** 页面，添加键值对。

        例如，假设我们有一个名为 `API_URL` 的变量，用于保存 API 服务器的地址。我们可以在 `.gitlab-ci.yml` 文件中通过 `$API_URL` 来访问它：

        ```yaml
        test-job:
        script:
            - echo "Running tests against $API_URL"
            - npm run test --api-url $API_URL
        ```

        密钥则用于存储密码或 API 令牌等敏感信息。它们被安全地存储并在日志中屏蔽。使用方式与变量相同，只需通过 `$SECRET_VARIABLE` 访问即可。

        借助变量和密钥，我们的流水线更加灵活和安全，便于配置不同环境或传递敏感数据。

        完成 `.gitlab-ci.yml` 文件的设置以及变量和密钥的定义后，就可以让 GitLab Runner 开始执行任务了。

4. 使用 GitLab Runner 运行任务

    现在我们已配置好 GitLab CI/CD 流水线，是时候看看 GitLab Runner 如何实际运行任务了。在本节中，我们将了解 GitLab Runner 如何执行任务、如何在任务中运行 Shell 命令，以及如何利用 Docker 构建隔离且可复现的任务环境。

    1. 理解 Runner 的执行过程

        当我们向仓库推送更改或创建合并请求时，GitLab 会触发 `.gitlab-ci.yml` 文件中定义的流水线。GitLab Runner 会持续轮询 GitLab 获取新任务，并根据定义的阶段和任务配置执行任务。

        Runner 的执行流程主要包括以下几个步骤：

        1. 克隆仓库：在指定提交或分支上克隆仓库；
        2. 准备环境：根据执行器（如 shell、Docker）设置任务环境；
        3. 执行任务：运行任务脚本中定义的命令；
        4. 报告结果：将任务状态（成功、失败或取消）返回给 GitLab。

        这就是 Runner 的完整执行过程。

    2. 执行 Shell 命令

        定义任务步骤最常见的方法之一就是使用 Shell 命令。GitLab Runner 在任务环境中执行这些命令，使我们能够运行脚本、构建工具和测试套件。

        来看一个执行 Shell 命令的任务示例：

        ```yaml
        test-job:
        script:
            - echo "Running tests..."
            - npm install
            - npm run test
        ```

        上面的任务执行了三个 Shell 命令：

        - 打印一条消息；
        - 使用 `npm install` 安装依赖；
        - 使用 `npm run test` 运行测试。

        GitLab Runner 会按顺序执行这些命令，如果任何命令执行失败（返回非零退出码），任务将标记为失败。

    3. 在 GitLab Runner 中使用 Docker

        Docker 是运行任务的流行选择，因为它可以在隔离和可复现的环境中执行任务。GitLab Runner 内置支持 Docker，允许我们在 Docker 容器中运行任务。

        要在 GitLab Runner 中使用 Docker，只需在任务定义中指定 `image` 关键字：

        ```yaml
        test-job:
        image: node:14
        script:
            - npm install
            - npm run test
        ```

        在这个示例中，`test-job` 将在一个基于 `node:14` 镜像的 Docker 容器中运行。GitLab Runner 会自动拉取指定镜像，并为每次任务执行启动一个新容器。

5. 总结

    在本文中，我们深入了解了 GitLab Runner 的强大功能及其在 CI/CD 流水线中的作用。从安装配置到任务执行，GitLab Runner 显著提升了自动化构建、测试和部署的能力。

    总结如下：

    - 我们学习了如何安装 GitLab Runner 并将其集成到现有的 CI/CD 环境中；
    - 学习了如何定义 `.gitlab-ci.yml` 文件；
    - 探索了任务执行、Shell 命令和 Docker 容器的使用。
