# [使用 GitLab CI 在本地运行测试的指南](https://www.baeldung.com/ops/gitlab-execute-tests-locally)

DevOps

GitLab

1. 概述
    测试对于软件开发至关重要，它确保代码在部署到生产环境之前能按预期工作。虽然像 GitLab CI 这样的[持续集成](https://www.baeldung.com/cs/continuous-integration-deployment-delivery)（CI）平台通常用于在远程服务器环境中自动执行测试，但有时我们也希望在本地运行这些测试，以加快开发和调试过程。

    在本教程中，我们将学习如何使用 GitLab CI 在本地运行测试。

2. 使用 gitlab-ci-local
    顾名思义，[gitlab-ci-local](https://github.com/firecow/gitlab-ci-local) 工具使我们能够在本地运行 GitLab CI 的作业和流水线。让我们通过它来在本地运行我们的测试。

    1. 配置
        首先来看一个示例 unit_test 作业，在我们演示项目的 `.gitlab-ci.yml` CI/CD 配置文件中：

        ```bash
        $ cat demo/.gitlab-ci.yml
        unit_test:
        image: python:latest
        script:
            - echo "running tests ..."
        ```

        我们的作业设计得很简单，script 部分可以包含项目特定的必要命令来运行测试。我们在后续部分也会重复使用这个配置文件。

        接下来，按照[安装指南](https://github.com/firecow/gitlab-ci-local?tab=readme-ov-file#installation)在我们的机器上安装 gitlab-ci-local。例如，在 macOS 上，我们可以执行以下 brew 安装指令：

        ```bash
        brew install gitlab-ci-local
        ```

        然后，通过检查版本信息来验证安装是否成功：

        ```bash
        $ gitlab-ci-local --version
        4.56.2
        ```

        看起来一切正常。

    2. 运行测试
        我们可以进入我们的演示项目目录，并使用 gitlab-ci-local 查看 `.gitlab-ci.yml` 配置文件中定义的作业列表：

        ```bash
        $ gitlab-ci-local --list
        parsing and downloads finished in 108 ms.
        json schema validated in 80 ms
        name       description  stage   when        allow_failure  needs
        unit_test               test    on_success  false
        ```

        正如预期，我们可以在输出中看到 unit_test 作业。

        现在，我们来在本地运行 unit_test 作业并检查其结果：

        ```bash
        $ gitlab-ci-local unit_test
        parsing and downloads finished in 99 ms.
        json schema validated in 81 ms
        unit_test starting python:latest (test)
        unit_test copied to docker volumes in 395 ms
        unit_test $ echo "running tests ..."
        unit_test > running tests ...
        unit_test finished in 778 ms

        PASS  unit_test
        ```

        太棒了！看起来我们成功地运行了这个作业。我们可以看到 unit_test 作业已经成功执行。

3. 使用 GitLab Emulator
    GitLab Emulator 是另一个用于在本地模拟 GitLab CI/CD 作业的有趣工具。让我们用它来解决我们的使用场景。

    1. 安装 gle
        首先，gle 实用程序并未预安装，因此我们必须手动[安装它](https://gitlab.com/cunity/gitlab-emulator#emulator-installation)：

        ```bash
        $ git clone https://gitlab.com/cunity/gitlab-emulator.git && cd gitlab-emulator
        $ ./install-venv.sh
        $ source ~/.gle/venv/bin/activate
        ```

        我们已通过源码安装了该实用程序。

        现在，使用 `--version` 选项验证安装：

        ```bash
        $ gle --version
        16.3.2
        ```

        看起来我们安装正确。

    2. 运行测试
        现在我们可以将工作目录切换到演示项目，并使用 gle 列出可用的作业：

        ```bash
        $ cd demo && gle --list
        unit_test
        ```

        由于我们的 `.gitlab-ci.yml` 配置文件中只有一个作业，我们可以看到它被正确列出。

        接下来，运行 unit_test 作业并观察它的运行情况：

        ```bash
        $ gle unit_test
        >>> execute unit_test:
        2025-01-20 11:02:08,003 gitlab-emulator  allocating runner
        2025-01-20 11:02:08,003 gitlab-emulator  running docker job unit_test
        2025-01-20 11:02:08,003 gitlab-emulator  runner = docker-runner default-docker
        2025-01-20 11:02:08,003 gitlab-emulator  pulling docker image python:latest
        Pulling python:latest...
        2025-01-20 11:02:13,064 gitlab-emulator  launching image python:latest as container gle-docker-52712-ead51fb ..
        2025-01-20 11:02:13,337 gitlab-emulator  started container 49375beb611a029ffd524b2fbc4333e903495598f0c09adef77cb9e0f4f7da0c
        2025-01-20 11:02:13,337 gitlab-emulator  attempting to set git safe.directory..
        2025-01-20 11:02:13,337 gitlab-emulator  running command -v git 2>&1 >/dev/null && git config --system safe.directory '/Users/tavasthi/baeldung-gitlab/demo'
        2025-01-20 11:02:13,340 gitlab-emulator  Copying /var/folders/lf/j9rwr9p90bjf8_5cjchpgb380000gn/T/generated-gitlab-script.sh to container as /tmp/generated-gitlab-script.sh ..
        2025-01-20 11:02:13,381 gitlab-emulator  checking container for bash
        2025-01-20 11:02:13,433 gitlab-emulator  bash found
        2025-01-20 11:02:13,517 gitlab-emulator  Copying /var/folders/lf/j9rwr9p90bjf8_5cjchpgb380000gn/T/generated-gitlab-script.sh to container as /tmp/generated-gitlab-script.sh ..
        running tests ...
        gle-docker-52712-ead51fb
        Build complete!
        ```

        很好！我们可以从调试日志中看到我们的作业已经成功执行。

4. 使用 GitLab Runner
    在本节中，我们将学习如何使用 gitlab-runner 工具在本地运行测试。

    1. 配置
        我们安装 gitlab-runner 工具的 13.3.0 版本。我们可以根据操作系统的[安装指南](https://docs.gitlab.com/runner/install/)下载对应二进制文件，并将下载路径中的 latest 替换为 v13.3.0：

        ```bash
        sudo curl --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/v13.3.0/binaries/gitlab-runner-darwin-amd64
        ```

        需要注意的是，我们的使用场景是通过 GitLab Runner 在本地运行特定作业。由于[新版本不再支持 ](https://gitlab.com/gitlab-org/gitlab/-/issues/385235)`gitlab-runner exec` 命令，我们必须依赖旧版本。

    2. 运行测试
        首先，我们必须验证已安装的 gitlab-runner 实用程序的版本：

        ```bash
        $ gitlab-runner --version | grep Version
        Version:      13.3.0
        ```

        我们计划使用 13.3.0 支持的 `exec` 子命令。因此，我们现在可以继续执行。

        现在，我们可以在本地运行我们的 unit_test 作业：

        ```bash
        $ gitlab-runner exec docker unit_test
        Runtime platform                                    arch=amd64 os=darwin pid=21248 revision=86ad88ea version=13.3.0
        Running with gitlab-runner 13.3.0 (86ad88ea)
        Preparing the "docker" executor
        Using Docker executor with image python:latest ...
        Authenticating with credentials from /Users/tavasthi/.docker/config.json
        Pulling docker image python:latest ...
        Using docker image sha256:3eb60a97864f318f1522587ba7e097a4f39d715c8f8f5acb8933b30c711965a0 for python:latest ...
        Preparing environment
        Running on runner--project-0-concurrent-0 via Tapans-MacBook-Air.local...
        Getting source from Git repository
        Fetching changes...
        Initialized empty Git repository in /builds/project-0/.git/
        Created fresh repository.
        Checking out 2871d3b2 as main...

        Skipping Git submodules setup
        Executing "step_script" stage of the job script
        $ echo "running tests ..."
        running tests ...
        Job succeeded
        ```

        我们可以看到，gitlab-runner 下载了必要的 Docker 镜像并在本地执行了 unit_test 作业。此外，我们的作业也成功执行了。

5. 结论
    在本文中，我们学习了如何使用 GitLab CI 在本地运行测试。此外，我们还探索了不同的实用程序，如 GitLab CI Local、GitLab Emulator 和 GitLab Runner 来解决这一使用场景。
