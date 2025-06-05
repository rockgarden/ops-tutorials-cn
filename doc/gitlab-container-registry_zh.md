# [启用和使用 GitLab 容器镜像仓库](https://www.baeldung.com/ops/gitlab-container-registry)

Git

GitLab

1. 概述
    GitLab 是一个领先的 DevOps 平台，不仅提供 Git 版本控制功能，还集成了多种特性以简化整个软件开发生命周期。其中，**GitLab Container Registry** 是一项强大的[功能](https://about.gitlab.com/features/?stage=package#container_registry)，允许团队在 GitLab 项目中直接管理容器镜像。结合 GitLab CI，它使 GitLab 成为自动化和加速 DevOps 流程的统一平台。

    在本教程中，我们将介绍如何在 **自托管（self-managed）GitLab 实例** 上启用 GitLab 容器镜像仓库，并演示如何在自托管环境和 SaaS 环境中使用该仓库。仓库的激活需要管理员在 [Omnibus GitLab 安装](https://docs.gitlab.com/omnibus/installation/)中进行配置。

2. GitLab 容器镜像仓库简介
    GitLab 在版本 8.8 中引入了 GitLab Container Registry，这是一个完全集成、安全且私有的容器镜像仓库。它允许团队将容器镜像直接存储和管理在 GitLab 的基础设施中。

    其主要特点包括：

    - 无需额外安装软件：设置简单快捷。
    - 用户与权限由 GitLab 全权管理：访问控制一致且易于维护。
    - 每个项目自动包含一个容器仓库：无需手动创建仓库。
    - 与 GitLab CI/CD 集成无缝：可直接通过流水线构建、推送和拉取镜像。

    GitLab 容器镜像仓库可以通过 GitLab 用户界面和 API 进行访问，是依赖 GitLab 进行版本控制和 CI/CD 自动化的团队的理想选择。它可以将所有操作集中在一个平台上，实现统一管理。

3. 为自托管 GitLab 配置容器仓库

    虽然 GitLab Container Registry 与 GitLab 完全集成，但在使用 Linux 包（Omnibus）安装的自托管实例中[可能需要额外配置](https://docs.gitlab.com/ee/administration/packages/container_registry.html?tab=Linux+package+%28Omnibus%29#linux-package-installations)。相比之下，GitLab.com（SaaS 版）默认已预配置好仓库，域名为 `registry.gitlab.com`。

    1. 启用 GitLab 容器仓库

        只需配置 GitLab 容器仓库监听的域名即可轻松启用它。在开始配置之前，建议先确认当前 `/etc/gitlab/gitlab.rb` 配置文件是否已修改过，可以将其与默认模板 `/opt/gitlab/etc/gitlab.rb.template` 进行对比：

        ```bash
        sudo gitlab-ctl diff-config
        ```

        此命令会显示两个文件之间的差异，有助于确认默认的仓库参数是否被更改。

        我们可以将 GitLab 容器镜像仓库配置在现有的 GitLab 域名下并使用一个独立的端口，或者为其分配一个独立的域名。在 `/etc/gitlab/gitlab.rb` 文件中，我们可以找到并取消注释 `registry_external_url` 参数，并根据所需的配置设置其值：

        我们可以将容器仓库配置在 GitLab 域名下，但使用不同的端口，以便复用现有的 GitLab TLS 证书。例如，如果 GitLab 的域名为 `gitlab.example.com`，我们可以在 `/etc/gitlab/gitlab.rb` 中按如下方式配置 `registry_external_url`：

        ```ruby
        registry_external_url 'https://gitlab.example.com:5050'
        ```

        此外，我们还需要配置防火墙设置，以允许流量通过指定的仓库端口，并确保避免使用端口 5000 。端口 5000 是 GitLab 的[默认端口](https://docs.gitlab.com/ee/administration/package_information/defaults.html)，保留用于仓库与其他 GitLab 组件之间的内部通信。

        或者，我们也可以通过如下方式设置 registry_external_url，为容器仓库配置一个独立的域名：

        ```ruby
        registry_external_url 'https://registry.gitlab.example.com'
        ```

        GitLab 默认推荐使用 HTTPS，当然也支持 HTTP。如果你的 TLS 证书和私钥不在 `/etc/gitlab/ssl/` 目录下，请取消注释并设置正确的路径：

        ```ruby
        registry_nginx['ssl_certificate'] = "/path/to/certificate.pem"
        registry_nginx['ssl_certificate_key'] = "/path/to/certificate.key"
        ```

        确保证书文件权限正确：

        ```bash
        chmod 600 /etc/gitlab/ssl/registry.domain.com.*
        ```

        通常，配置文件中的值默认是注释状态以表示默认设置。例如，不需要显式取消注释 `registry['enable'] = true` 来启用服务，因为它默认就是启用的。

    2. 管理容器仓库存储路径

        目前这些配置已经足够启用仓库。但你还可以进一步自定义设置。例如，若默认路径 `/var/opt/gitlab/gitlab-rails/shared/registry` 不符合你的需求，你可以指定一个新的存储路径：

        ```ruby
        gitlab_rails['registry_path'] = "/path/to/registry/storage"
        ```

        这指定了镜像的存储位置，默认使用的是本地文件系统。此外，GitLab 也支持对象存储（如 S3、Azure、GCS），相关配置可在 [GitLab 官方文档](https://docs.gitlab.com/ee/administration/packages/container_registry.html) 中查看。

    3. 应用配置变更

        最后，应用所做的配置更改：

        ```bash
        sudo gitlab-ctl reconfigure
        ```

        该命令将读取 `/etc/gitlab/gitlab.rb` 的新配置，并完成仓库的启用过程。

4. 使用 GitLab 容器镜像仓库

    一旦 GitLab 容器仓库启用，你就可以开始使用它来管理 Docker 镜像。

    1. 推送 Docker 镜像到 GitLab 容器仓库

        要推送 Docker 镜像到 GitLab 容器仓库，首先使用你的 GitLab 凭据[登录仓库](https://docs.gitlab.com/ee/user/packages/container_registry/#view-the-container-registry)：

        ```bash
        docker login registry.gitlab.example.com
        ```

        每个项目默认启用了容器仓库，可以在项目的界面上访问。

        在较新的 GitLab 版本中，点击左侧菜单栏的 **Deploy > Container Registry** 即可进入仓库页面。

        对于旧版本，可通过 **Packages and Registries > Container Registry** 访问。

        接下来，根据 GitLab 仓库[命名规范](https://docs.gitlab.com/ee/user/packages/container_registry/#naming-convention-for-your-container-images)对 Docker 镜像进行打标签。格式如下：

        ```xml
        <registry server>/<namespace>/<project>[/<optional path>]
        ```

        例如，项目地址为 `registry.gitlab.example.com/mynamespace/myproject`，则构建并打标签命令如下：

        ```bash
        docker build -t registry.gitlab.example.com/mynamespace/myproject/myimage:latest .
        ```

        最后，将打标签后的镜像推送到 GitLab 容器仓库：

        ```bash
        docker push registry.gitlab.example.com/mynamespace/myproject/myimage:latest
        ```

        这样，该镜像就可以在 GitLab 中用于部署和共享。

    2. 在 GitLab CI/CD 中使用容器仓库

        GitLab 容器仓库最强大的功能之一是与 [CI/CD](https://www.baeldung.com/ops/gitlab-runner-guide#gitlab-cicd-configuration) 流水线的集成。通过使用 GitLab 提供的[预定义 CI 变量](https://docs.gitlab.com/ee/ci/variables/predefined_variables.html)如 `CI_REGISTRY`、`CI_REGISTRY_USER` 和 `CI_REGISTRY_PASSWORD`，我们可以自动化认证和交互过程：

        ```yaml
        build:
        image: $CI_REGISTRY/mynamespace/myproject/ubuntu:20.10.16
        stage: build
        services:
            - $CI_REGISTRY/mynamespace/myproject/docker:20.10.16-dind
            - alias: docker
        script:
            - echo "$CI_REGISTRY_PASSWORD" | docker login $CI_REGISTRY -u $CI_REGISTRY_USER --password-stdin
            - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG .
            - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
        ```

        在这个示例中，我们使用 `$CI_REGISTRY` 引用 GitLab 仓库地址，使用 `$CI_REGISTRY_IMAGE` 设置镜像路径，并使用 `$CI_COMMIT_REF_SLUG` 作为标签。脚本会登录仓库、构建 Docker 镜像，并将其推送到 GitLab 容器仓库。此外，使用了 **[Docker-in-Docker (dind)](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#use-docker-in-docker)** 技术，使得在 CI 环境中也能运行 Docker，从而确保构建流程的一致性和隔离性。

5. 总结

    在本文中，我们介绍了 GitLab 容器镜像仓库，强调了其与 GitLab 的无缝集成，使其成为存储和管理 Docker 镜像的强大工具。

    通过启用仓库、配置存储路径以及与 GitLab CI/CD 流水线集成，我们可以显著简化容器管理流程。无论是管理少量容器还是跨多个项目管理大量镜像，GitLab 的容器仓库都提供了一个安全、可扩展的解决方案来满足你的容器化需求。
