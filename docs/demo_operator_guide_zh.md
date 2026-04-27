# Demo 操作与关卡编辑指南

最后更新：2026-04-27

这份文档给策划或关卡设计同学使用，说明如何打开 Godot Demo、试玩当前版本，以及如何编辑和保存关卡。

## 打开项目

1. 打开 Godot 4。
2. 打开当前项目文件夹，也就是包含 `project.godot` 的文件夹。
3. 打开主场景：

```text
scenes/Main.tscn
```

4. 按 `F6` 运行当前场景。

如果 Godot 询问运行哪个场景，选择：

```text
scenes/Main.tscn
```

## 打开后先看哪里

项目里的关键文件：

```text
scenes/Main.tscn
scripts/Main.gd
levels/levels.json
levels/level_001.json
levels/level_002.json
levels/level_003.json
docs/project_status.md
docs/handoff.md
```

含义：

- `scenes/Main.tscn`：当前 Demo 主场景。
- `scripts/Main.gd`：当前玩法和编辑器逻辑。
- `levels/levels.json`：关卡顺序配置。
- `levels/level_001.json` 等：具体关卡数据。
- `docs/project_status.md`：当前项目状态。
- `docs/handoff.md`：换电脑或新会话时看的交接说明。

运行 Demo 后：

- 左侧是棋盘。
- 右侧是道路块、按钮、Debug 面板、Editor 面板。
- 顶部是关卡、燃料、现金分数、当前状态。

## 试玩操作

- 鼠标左键点击道路块：选择道路块。
- `R`：旋转当前选中的道路块。
- 鼠标左键点击棋盘：放置道路块。
- `Restart Level`：重开当前关卡。
- `Reload Level`：重新加载当前关卡文件。
- `Next Level`：胜利后进入下一关。
- `D`：显示或隐藏 Debug 信息。
- `E`：进入或退出关卡编辑器。

## 当前玩法规则

- 出租车从起点出发。
- 目标是连接到终点。
- 玩家通过放置道路块，让道路网络从起点延伸到终点。
- 每放置一次道路块，消耗 `1` 点燃料。
- 燃料归零前没有连到终点，则失败。
- 现金格必须被道路铺上，才有可能被收集。
- 现金格被铺成道路后，还必须接入起点连通网络，才会被收集。
- 障碍格不能铺道路。
- 道路块必须连接到已有的连通道路网络，才能放置。

鼠标悬停预览：

- 黄色：可以放置。
- 红色：不能放置。

## Debug 模式

运行时按 `D`。

Debug 面板会显示：

- 当前关卡来源。
- 当前关卡路径。
- 棋盘宽高。
- 起点坐标。
- 终点坐标。
- 当前燃料和初始燃料。
- 当前状态。
- 当前选中的道路块。
- 现金数量。
- 障碍数量。
- 已连通格子数量。
- 生成关卡隐藏路线数量。

棋盘上的 Debug 标记：

- 蓝色边框：已经接入起点网络的格子。
- 紫色边框：生成关卡的隐藏路线格子。

## 进入关卡编辑器

1. 按 `F6` 运行主场景。
2. 按 `E`。
3. 右侧会出现编辑器面板。

再次按 `E`，会退出编辑器并回到试玩模式。

## 切换正在编辑的关卡

进入编辑器后，看右侧 `Level Files` 区域。

下拉框中的关卡来自：

```text
levels/levels.json
```

选择下拉框里的关卡后，会加载对应关卡。

如果某个关卡文件还不存在，比如 `level_003.json` 还没创建，那么游戏会临时使用生成关卡作为回退内容。点击 `New Level` 或 `Save Level` 后，才会真正写出 JSON 文件。

## 新建关卡

1. 按 `E` 进入编辑器。
2. 点击 `New Level`。
3. 编辑器会创建下一个缺失的关卡文件，例如：

```text
levels/level_003.json
```

4. 编辑器也会更新：

```text
levels/levels.json
```

新关卡默认内容：

- 起点在左上角。
- 终点在右下角。
- 使用当前编辑器里的宽高。
- 使用当前编辑器里的初始燃料。

## 修改棋盘参数

编辑器里可以调整：

- `Width`：棋盘宽度，目前范围是 `4` 到 `14`。
- `Height`：棋盘高度，目前范围是 `4` 到 `12`。
- `Initial fuel`：初始燃料，目前范围是 `1` 到 `20`。
- `Cash value`：新画现金格的数值，目前范围是 `1` 到 `9`。

修改宽高时：

- 仍在范围内的现金和障碍会保留。
- 起点和终点会被限制在棋盘内。
- 临时试玩道路状态会被清空。

## 绘制棋盘

编辑器支持这些画笔：

- `Ground`：清除普通格子。
- `Cash`：画现金格，数值使用当前 `Cash value`。
- `Block`：画障碍。
- `Start`：移动起点。
- `Goal`：移动终点。

点击棋盘格子即可绘制。

注意：

- 起点只能有一个。
- 终点只能有一个。
- 放置新起点会清掉旧起点。
- 放置新终点会清掉旧终点。
- 现金和障碍不能覆盖起点或终点。

## 检查关卡是否合法

编辑器面板里会显示校验信息。

保存前应确认显示：

```text
Validation: OK
```

常见错误：

- 没有起点。
- 没有终点。
- 起点和终点重叠。
- 起点或终点超出棋盘。
- 起点或终点和现金、障碍重叠。

## 保存关卡

1. 按 `E` 进入编辑器。
2. 选择或新建一个关卡。
3. 编辑棋盘。
4. 确认 `Validation: OK`。
5. 点击 `Save Level`。
6. 停止运行场景。
7. 打开对应的 JSON 文件，确认内容已经变化。

`Save Level` 会直接把当前编辑器里的关卡写入当前 JSON 文件。

这个保存功能用于 Godot 编辑器开发阶段。正式导出的游戏版本不要依赖写入 `res://levels/`。

## 备用导出按钮

`Copy JSON`：

- 把当前关卡 JSON 复制到剪贴板。
- 如果直接保存失败，可以手动粘贴到关卡文件里。

`Copy levels.json Entry`：

- 复制类似下面这样的关卡路径：

```json
"res://levels/level_003.json"
```

- 手动编辑 `levels/levels.json` 时可以使用。

## 关卡顺序

关卡顺序由这个文件控制：

```text
levels/levels.json
```

示例：

```json
{
	"levels": [
		"res://levels/level_001.json",
		"res://levels/level_002.json",
		"res://levels/level_003.json",
		"generated",
		"generated"
	]
}
```

说明：

- `res://levels/level_001.json` 表示读取指定关卡文件。
- `generated` 表示运行时生成一个临时关卡。

团队协作时，建议由一个人统一维护最终关卡顺序。

## 推荐关卡制作流程

1. 新建或选择一个关卡。
2. 设置宽度、高度、初始燃料。
3. 放置起点和终点。
4. 放置障碍，限制玩家路径。
5. 放置现金，鼓励玩家绕路。
6. 点击 `Save Level`。
7. 按 `E` 退出编辑器。
8. 试玩关卡。
9. 根据体验调整燃料、障碍、现金。
10. 再次保存。

试玩时重点看：

- 关卡是否能通关。
- 玩家是否有绕路拿钱的理由。
- 路线是否看得懂。
- 前几关是否足够简单。

## GitHub Desktop 协作流程

开始修改前：

1. 打开 GitHub Desktop。
2. 选择仓库：

```text
longcrush-car-demo
```

3. 点击 `Fetch origin`。
4. 如果出现 `Pull origin`，点击它。
5. 新建一个分支。

分支名示例：

```text
level/level-004
level/tune-level-002
feature/solver-check
```

修改完成后：

1. 回到 GitHub Desktop。
2. 检查 changed files。
3. 填写 Summary，例如：

```text
Add level 004
Tune level 002
```

4. 点击 Commit。
5. 点击 Push origin。
6. 创建 Pull Request。

## 团队协作规则

- 多人协作时，不要直接在 `main` 上改。
- 每个策划尽量只改自己负责的关卡文件。
- 避免两个人同时改同一个 `level_00x.json`。
- `levels/levels.json` 的最终顺序最好由一个人统一整理。
- 提交前至少用 `F6` 试玩一次。
- Pull Request 里写清楚：
  - 修改了哪一关；
  - 是否 F6 测试过；
  - 是否可以通关；
  - 是否有已知平衡问题。

