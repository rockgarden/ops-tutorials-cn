# [依赖项扫描（Dependency Scanning）](https://docs.gitlab.com/17.11/user/application_security/dependency_scanning/)

层级：Ultimate

提供版本：GitLab.com、GitLab 自托管（Self-Managed）、GitLab 专用版（Dedicated）

基于 Gemnasium 分析器的“依赖项扫描”功能在 GitLab 17.9 中已被弃用，并将在 GitLab 18.0 中结束支持。该功能将由使用 SBOM 和新依赖项扫描分析器的功能取代。

依赖项扫描可在依赖项进入生产环境之前识别其中的安全漏洞，从而保护您的应用程序免受可能造成用户信任受损和企业声誉损失的潜在攻击。当流水线运行过程中发现漏洞时，它们会直接显示在合并请求中，让您在代码提交前即可立即看到相关的安全问题。

在流水线执行期间，您代码中的所有依赖项（包括间接依赖或嵌套依赖）都会被自动分析。这种分析能够发现人工审查流程可能遗漏的安全隐患。依赖项扫描只需对现有 CI/CD 工作流进行最小程度的配置更改即可集成，使您可以从第一天起就轻松实施安全开发实践。

也可以通过持续漏洞扫描（Continuous Vulnerability Scanning）在流水线之外识别漏洞。

GitLab 提供了依赖项扫描和容器扫描（Container Scanning），以覆盖各类依赖项的安全风险。为了尽可能全面地降低风险区域，我们建议您使用 GitLab 提供的所有安全扫描工具。

## 配置（Configuration）

启用依赖项扫描分析器，以确保其对应用程序的依赖项进行已知漏洞的扫描。随后，您可以通过使用 CI/CD 变量来调整其行为。

### 启用分析器

前提条件：

- `.gitlab-ci.yml` 文件中必须包含 `test` 阶段。
- 如果使用自托管的 GitLab Runner，则需要一个使用 Docker 或 Kubernetes 执行器的 Runner。
- 如果在 GitLab.com 上使用 SaaS Runner，则此功能默认已启用。

要启用该分析器，您可以选择以下任意一种方式：

1. **启用 Auto DevOps**：其中包含依赖项扫描功能。
2. **使用预配置的合并请求（Merge Request）**
3. **创建一条扫描执行策略（Scan Execution Policy）**，强制启用依赖项扫描。
4. **手动编辑 `.gitlab-ci.yml` 文件**
5. **使用 CI/CD 组件**

---

#### 使用预配置的合并请求

此方法会自动准备一个合并请求，将依赖项扫描模板添加到 `.gitlab-ci.yml` 文件中。随后您只需合并该合并请求即可启用依赖项扫描。

此方法最适合没有现有 `.gitlab-ci.yml` 文件，或文件内容非常简单的项目。如果您已有复杂的 GitLab 配置文件，可能无法成功解析，导致错误。在这种情况下，请改用**手动方法**。

**启用步骤：**

1. 在左侧边栏中，选择 **Search** 或直接导航至您的项目。
2. 选择 **Secure > Security configuration**。
3. 在 **Dependency Scanning** 行中，选择 **Configure with a merge request**。
4. 点击 **Create merge request**。
5. 查看合并请求后，点击 **Merge**。

现在，流水线中将包含一个 **Dependency Scanning job**。

---

#### 手动编辑 `.gitlab-ci.yml` 文件

此方法要求您手动编辑现有的 `.gitlab-ci.yml` 文件，适用于 GitLab CI/CD 配置较复杂的情况。

**启用步骤：**

1. 在左侧边栏中，选择 **Search** 或直接导航至您的项目。
2. 选择 **Build > Pipeline editor**。
3. 如果当前没有 `.gitlab-ci.yml` 文件，点击 **Configure pipeline**，然后删除示例内容。
4. 将以下代码复制并粘贴到 `.gitlab-ci.yml` 文件末尾。如果文件中已有 `include` 行，请将模板行添加在其下方。

    ```yaml
    include:
    - template: Jobs/Dependency-Scanning.gitlab-ci.yml
    ```

    社区版：<https://gitlab.com/gitlab-org/gitlab-foss/-/blob/master/lib/gitlab/ci/templates/Jobs/Dependency-Scanning.gitlab-ci.yml>

5. 切换到 **Validate** 标签页，然后点击 **Validate pipeline**。  
   如果提示 **Simulation completed successfully**，表示文件格式有效。
6. 切换回 **Edit** 标签页。
7. 填写字段信息，**Branch 字段不要使用默认分支**。
8. 勾选 **Start a new merge request with these changes** 复选框，然后点击 **Commit changes**。
9. 按照标准流程填写字段，点击 **Create merge request**。
10. 按照标准流程审查和修改合并请求，最后点击 **Merge**。

现在，流水线中将包含一个 **Dependency Scanning job**。

---

#### 使用 CI/CD 组件

使用 CI/CD 组件对您的应用程序进行依赖项扫描。

#### 当前可用的 CI/CD 组件

查看：<https://gitlab.com/explore/catalog/components/dependency-scanning>

### 自定义分析器行为

要自定义依赖项扫描功能，请使用 CI/CD 变量。

在将更改合并到默认分支之前，请**先在合并请求中测试所有对 GitLab 分析器的自定义配置**。未进行测试可能导致意外结果，包括大量误报。

---

### 覆盖依赖项扫描作业

如需覆盖某个作业的定义（例如修改变量或依赖项等属性），请声明一个与目标作业**同名的新作业**。该新作业应放置在模板引入（`include`）语句之后，并在其下指定任何需要添加的配置项。

例如，以下配置会禁用 `gemnasium` 分析器的 `DS_REMEDIATE` 功能：

```yaml
include:
  - template: Jobs/Dependency-Scanning.gitlab-ci.yml

gemnasium-dependency_scanning:
  variables:
    DS_REMEDIATE: "false"
```

如需覆盖 `dependencies: []` 属性，请像上面一样添加一个针对该属性的覆盖作业：

```yaml
include:
  - template: Jobs/Dependency-Scanning.gitlab-ci.yml

gemnasium-dependency_scanning:
  dependencies: ["build"]
```

### 可用的 CI/CD 变量

您可以使用 CI/CD 变量来自定义依赖项扫描的行为。

---

#### 全局分析器设置

以下变量可用于配置全局依赖项扫描设置。

| **CI/CD 变量** | **描述** |
|----------------|----------|
| `ADDITIONAL_CA_CERT_BUNDLE` | 信任的 CA 证书包。此处提供的证书也将被扫描过程中使用的其他工具（如 git、yarn 或 npm）所使用。更多详情请参见 [自定义 TLS 证书颁发机构](https://docs.gitlab.com/ee/ci/ssl_rsa_certificate_bundles.html)。 |
| `DS_EXCLUDED_ANALYZERS` | 指定要从依赖项扫描中排除的分析器（按名称）。更多信息请参见 [Analyzers](https://docs.gitlab.com/ee/user/application_security/dependency_scanning/index.html#analyzers)。 |
| `DS_EXCLUDED_PATHS` | 根据路径排除扫描中的文件和目录。格式为逗号分隔的模式列表。支持通配符匹配（请参见 [doublestar.Match 支持的模式](https://pkg.go.dev/github.com/fsnotify/fsnotify#Match)），也支持具体文件或目录路径（例如：`doc`, `spec`）。父级目录也会匹配。这是在扫描执行前应用的预过滤规则。默认值：`"spec, test, tests, tmp"`。 |
| `DS_IMAGE_SUFFIX` | 添加到镜像名称的后缀。（GitLab 团队成员可在该[保密 issue](https://gitlab.com/gitlab-org/gitlab/-/issues/354796) 中查看更多信息。）启用 FIPS 模式时自动设为 `"-fips"`。 |
| `DS_MAX_DEPTH` | 定义分析器应搜索支持的扫描文件的最大目录深度。值为 `-1` 表示无限制地扫描所有目录。默认值：`2`。 |
| `SECURE_ANALYZERS_PREFIX` | 覆盖提供官方默认镜像的 Docker Registry 名称（代理）。 |

---

#### 分析器特定设置

以下变量用于配置特定依赖项扫描分析器的行为。

| **CI/CD 变量** | **分析器** | **默认值** | **描述** |
|----------------|------------|-------------|----------|
| `GEMNASIUM_DB_LOCAL_PATH` | gemnasium | `/gemnasium-db` | 本地 Gemnasium 数据库路径。 |
| `GEMNASIUM_DB_UPDATE_DISABLED` | gemnasium | `"false"` | 禁用 gemnasium-db 漏洞数据库的自动更新。使用方法请参见 [访问 GitLab Advisory Database](https://docs.gitlab.com/ee/user/application_security/dependency_scanning/index.html#access-to-the-gitlab-advisory-database)。 |
| `GEMNASIUM_DB_REMOTE_URL` | gemnasium | `https://gitlab.com/gitlab-org/security-products/gemnasium-db.git` | 获取 GitLab Advisory Database 的远程仓库 URL。 |
| `GEMNASIUM_DB_REF_NAME` | gemnasium | `master` | 远程数据库仓库的分支名。需配合 `GEMNASIUM_DB_REMOTE_URL` 使用。 |
| `DS_REMEDIATE` | gemnasium | `"true"`，FIPS 模式下为 `"false"` | 启用对存在漏洞依赖项的自动修复。FIPS 模式下不支持。 |
| `DS_REMEDIATE_TIMEOUT` | gemnasium | `5m` | 自动修复操作的超时时间。 |
| `GEMNASIUM_LIBRARY_SCAN_ENABLED` | gemnasium | `"true"` | 启用对 vendored JavaScript 库（非包管理器管理的库）中的漏洞检测。此功能要求提交中包含 JavaScript 锁文件，否则不会执行依赖项扫描且不会扫描 vendored 文件。 |
| `DS_INCLUDE_DEV_DEPENDENCIES` | gemnasium | `"true"` | 设置为 `"false"` 时，开发依赖项及其漏洞将不会被报告。仅适用于使用 Composer、Maven、npm、pnpm、Pipenv 或 Poetry 的项目。GitLab 15.1 引入。 |
| `GOOS` | gemnasium | `"linux"` | 编译 Go 代码的目标操作系统。 |
| `GOARCH` | gemnasium | `"amd64"` | 编译 Go 代码的目标处理器架构。 |
| `GOFLAGS` | gemnasium | （空） | 传递给 `go build` 工具的参数。 |
| `GOPRIVATE` | gemnasium | （空） | 需要从源码获取的模块的 glob 模式和前缀列表。更多信息请参见 [Go 私有模块文档](https://golang.org/ref/mod#private-modules)。 |
| `DS_JAVA_VERSION` | gemnasium-maven | `17` | Java 版本。可选版本：8、11、17、21。 |
| `MAVEN_CLI_OPTS` | gemnasium-maven | `"-DskipTests --batch-mode"` | 分析器传递给 Maven 的命令行参数列表。[示例](https://docs.gitlab.com/ee/user/application_security/dependency_scanning/#using-private-repositories-with-maven)：使用私有仓库。 |
| `GRADLE_CLI_OPTS` | gemnasium-maven | （空） | 分析器传递给 Gradle 的命令行参数列表。 |
| `GRADLE_PLUGIN_INIT_PATH` | gemnasium-maven | `"gemnasium-init.gradle"` | Gradle 初始化脚本路径。脚本内容必须包含 `allprojects { apply plugin: 'project-report' }` 以确保兼容性。 |
| `DS_GRADLE_RESOLUTION_POLICY` | gemnasium-maven | `"failed"` | 控制 Gradle 依赖解析的严格程度。接受 `"none"`（允许部分结果）或 `"failed"`（任何依赖解析失败都导致扫描失败）。 |
| `SBT_CLI_OPTS` | gemnasium-maven | （空） | 分析器传递给 sbt 的命令行参数列表。 |
| `PIP_INDEX_URL` | gemnasium-python | `https://pypi.org/simple` | Python 包索引的基本 URL。 |
| `PIP_EXTRA_INDEX_URL` | gemnasium-python | （空数组） | 额外的包索引 URL 数组，与 `PIP_INDEX_URL` 一起使用。逗号分隔。警告：使用此环境变量时，请阅读以下[安全注意事项](https://pip.pypa.io/en/stable/cli/pip_install/#cmdoption-extra-index-url)。 |
| `PIP_REQUIREMENTS_FILE` | gemnasium-python | （空） | 要扫描的 pip requirements 文件名（不是路径）。设置此变量后，只会扫描指定文件。 |
| `PIPENV_PYPI_MIRROR` | gemnasium-python | （空） | 如果设置，则使用镜像替代 Pipenv 默认使用的 PyPi 源。 |
| `DS_PIP_VERSION` | gemnasium-python | （空） | 强制安装指定版本的 pip（例如：`"19.3"`），否则使用 Docker 镜像中已安装的 pip。 |
| `DS_PIP_DEPENDENCY_PATH` | gemnasium-python | （空） | 加载 Python pip 依赖项的路径。 |

---

#### 其他变量

上述表格并未列出所有可用的变量。它们仅包含我们支持并测试的所有 GitLab 和分析器专用变量。实际上还有很多变量（例如环境变量）可以传入并生效。这是一个庞大的列表，其中很多我们可能并不了解，因此未在文档中说明。

例如，要将非 GitLab 环境变量 `HTTPS_PROXY` 传递给所有依赖项扫描作业，可以在 `.gitlab-ci.yml` 文件中这样设置为 CI/CD 变量：

```yaml
variables:
  HTTPS_PROXY: "https://squid-proxy:3128"
```

对于 Gradle 项目，还需额外配置代理变量。

或者，我们可以将其用于特定作业，比如依赖项扫描：

```yaml
dependency_scanning:
  variables:
    HTTPS_PROXY: $HTTPS_PROXY
```

## 警告（Warnings）

我们建议您使用所有容器的最新版本，以及所有包管理器和语言的**最新受支持版本**。使用旧版本会带来更高的安全风险，因为不受支持的版本可能不再享有主动的安全漏洞报告和安全补丁的回传支持。

---

### Gradle 项目

在为 Gradle 项目生成 HTML 格式的依赖项报告时，请**不要覆盖** `reports.html.destination` 或 `reports.html.outputLocation` 属性。这样做会导致依赖项扫描无法正常运行。

---

### Maven 项目

在隔离网络中，如果中央仓库被设置为私有仓库（通过 `<mirror>` 指令显式指定），Maven 构建可能会找不到 `gemnasium-maven-plugin` 插件依赖。这是因为 Maven 默认不会在本地仓库（`/root/.m2`）中查找插件，而是尝试从中央仓库获取。最终导致出现“找不到插件依赖”的错误。

---

#### 解决方法（Workaround）

要解决此问题，请在您的 `settings.xml` 文件中添加一个 `<pluginRepositories>` 配置节，以允许 Maven 在本地仓库中查找插件。

注意事项：

- 此解决方法仅适用于将默认 Maven 中央仓库镜像到私有仓库的环境。
- 应用此解决方法后，Maven 将从本地仓库加载插件，这在某些环境中可能存在安全隐患。请确保此举符合您所在组织的安全策略。

修改步骤：

1. 找到您的 Maven `settings.xml` 文件。通常位于以下路径之一：
   - `/root/.m2/settings.xml`（针对 root 用户）
   - `~/.m2/settings.xml`（针对普通用户）
   - `${maven.home}/conf/settings.xml`（全局配置）

2. 检查文件中是否已有 `<pluginRepositories>` 配置节：

   - 如果存在，则只需在其中添加以下 `<pluginRepository>` 元素；
   - 如果不存在，则添加完整的 `<pluginRepositories>` 配置节：

    ```xml
    <pluginRepositories>
    <pluginRepository>
        <id>local2</id>
        <name>local repository</name>
        <url>file:///root/.m2/repository/</url>
    </pluginRepository>
    </pluginRepositories>
    ```

3. 再次运行 Maven 构建或依赖项扫描流程。
