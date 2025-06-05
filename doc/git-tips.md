# 常用git组合操作

## fork冲突解决

在 Git 中同步 fork 仓库时，如果出现冲突或提示需要解决冲突的情况，通常是因为你的 fork 仓库与上游（upstream）仓库的代码存在差异。

- 如果需要保留本地提交历史，建议通过 `git merge` 解决冲突。
- 如果不需要保留本地提交历史，可以直接使用 `git reset --hard` 和 `git push --force` 强制同步。

以下是解决此问题的详细步骤：

1. 确认当前状态

   首先，确保你已经克隆了你的 fork 仓库，并且已经添加了上游仓库的远程地址。

   运行以下命令查看当前的远程仓库配置：

   ```bash
   git remote -v
   ```

   如果你没有添加上游仓库，可以使用以下命令添加：

   ```bash
   git remote add upstream <上游仓库的URL>
   ```

2. 获取上游仓库的最新代码

   从上游仓库拉取最新的代码到本地：

   ```bash
   git fetch upstream
   ```

3. 切换到主分支（或其他目标分支）

   确保你在本地的目标分支上操作。例如，如果你要同步的是 `main` 分支：

   ```bash
   git checkout main
   ```

4. 合并上游代码

   将上游仓库的代码合并到你的本地分支：

   ```bash
   git merge upstream/main
   ```

5. 如果出现冲突
   如果合并过程中出现冲突，Git 会提示哪些文件存在冲突。你需要手动解决这些冲突：

   使用以下命令查看冲突的文件：

   ```bash
   git status
   ```

6. 编辑冲突文件

   打开冲突文件，你会看到类似以下的标记：

   ```plaintext
   <<<<<<< HEAD
   你的代码
   =======
   上游仓库的代码
   >>>>>>>
   ```

   根据需求选择保留哪一部分代码，或者手动合并两部分代码。

7. 标记冲突已解决
   编辑完成后，使用以下命令标记冲突已解决：

   ```bash
   git add <冲突文件>
   ```

8. 完成合并
   所有冲突解决后，完成合并：

   ```bash
   git commit
   git push
   ```

9. 强制同步（可选）
   如果你不需要保留本地的提交历史，而是希望直接与上游仓库保持一致，可以通过以下方式强制同步：

   重置分支

   ```bash
   git reset --hard upstream/main
   ```

   这将丢弃本地的所有更改，并使分支与上游仓库完全一致。

   > **注意**：此操作会丢失本地未提交的更改和提交记录，请谨慎操作。

   完成合并或重置后，将更新推送到你的 fork 仓库：

   ```bash
   git push origin main
   ```

   如果之前进行了重置操作，可能需要强制推送：

   ```bash
   git push origin main --force
   ```

## 多个远程仓库源同步

在 Git 中，可以从多个远程仓库源同步代码。这种场景通常出现在需要从不同的代码托管平台（如 GitHub、GitLab、Bitbucket 等）拉取或推送代码的情况下。以下是详细的操作步骤和注意事项：

1. 查看当前的远程仓库

   首先，检查当前配置的远程仓库：

   ```bash
   git remote -v
   ```

2. 添加多个远程仓库源
   你可以为不同的远程仓库指定不同的简短名称（`shortname`）。例如：

   添加第一个远程仓库（如 GitHub）

   ```bash
   git remote add origin https://github.com/username/repo.git
   ```

   添加第二个远程仓库（如 GitLab）

   ```bash
   git remote add gitlab https://gitlab.com/username/repo.git
   ```

   每个远程仓库都有一个唯一的简短名称（如 `origin`、`gitlab`、`bitbucket`），用于区分不同的远程源。

3. 验证远程仓库配置

   再次运行以下命令，确认所有远程仓库已正确添加：

   ```bash
   git remote -v
   ```

   输出可能类似于：

   ```plaintxt
   origin    https://github.com/username/repo.git (fetch)
   origin    https://github.com/username/repo.git (push)
   gitlab    https://gitlab.com/username/repo.git (fetch)
   gitlab    https://gitlab.com/username/repo.git (push)
   ```

4. 从不同的远程仓库拉取代码

   使用 `git pull` 或 `git fetch` 命令，可以从不同的远程仓库同步代码。

   拉取特定远程仓库的代码

   ```bash
   git pull <remote_name> <branch_name>
   ```

   - `<remote_name>`：远程仓库的简短名称（如 `origin`、`gitlab`、`bitbucket`）。
   - `<branch_name>`：分支名称（如 `main` 或 `master`）。

5. 推送到不同的远程仓库

   同样地，可以将本地代码推送到不同的远程仓库。

   推送到特定远程仓库

   ```bash
   git push <remote_name> <branch_name>
   ```

   如果你需要同时推送到多个远程仓库，可以手动执行多次 `git push`，或者通过配置简化操作。

6. 合并来自不同远程仓库的更改

   如果从不同的远程仓库拉取了代码，可能会遇到冲突。解决冲突的步骤如下：

   1. **拉取代码**：

      ```bash
      git pull origin main
      git pull gitlab main
      ```

   2. **解决冲突**：
      如果出现冲突，Git 会提示冲突文件。编辑这些文件并解决冲突后，标记冲突已解决：

      ```bash
      git add <conflicted_file>
      ```

   3. **提交合并结果**：

      ```bash
      git commit -m "Merge changes from multiple remotes"
      ```

7. 配置同时推送到多个远程仓库

   如果你经常需要将代码推送到多个远程仓库，可以通过设置一个统一的远程源来简化操作。

   创建一个新的远程源

   编辑 `.git/config` 文件，添加如下配置：

   ```ini
   [remote "all"]
      url = https://github.com/username/repo.git
      url = https://gitlab.com/username/repo.git
      url = https://bitbucket.org/username/repo.git
   ```

   使用新的远程源

   现在，你可以通过以下命令一次推送到所有远程仓库：

   ```bash
   git push all main
   ```

8. 注意事项

   - **权限问题**：确保你对每个远程仓库都有相应的读写权限。如果没有权限，可能需要配置 SSH 密钥或个人访问令牌。
   - **分支管理**：不同远程仓库的分支可能不一致，建议在拉取或推送之前确认分支名称是否匹配。
   - **代码一致性**：从多个远程仓库同步代码时，可能会引入不一致的更改。建议定期合并和测试代码。

## SVN 2 GIT

<https://blog.51cto.com/u_11566683/6045704>