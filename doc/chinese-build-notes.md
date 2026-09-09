# 中文版构建：问题记录与解决方案

记录《Linear Algebra》本地构建及中文版准备工作（2026-09）中遇到的问题、
定位方法和解决方案，供后续翻译工程参考。

## 构建环境

| 组件 | 版本 | 用途 |
|------|------|------|
| TeX Live | 2025（MacTeX） | pdflatex（英文版）/ xelatex（中文版） |
| MetaPost | 2.11 | 章节插图（`.mp` → `.1/.2/...`） |
| Asymptote | 3.01 | 3D/复杂插图（`.asy` → `.pdf`） |
| GhostScript | 10.04 | Asymptote 依赖 |
| latexmk | 4.86a | 未用，工作流走 `make` |

英文版工作流：`make book.pdf`（先构建 MetaPost/Asymptote 图形，
再 pdflatex ×2 + makeindex）。中文版：XeLaTeX + xeCJK。

## 问题 1：Asymptote 图形构建失败

**现象**：`make book.pdf` 在 `jc/asy/innerproduct000.pdf` 失败；asy 调用
latex 处理标签时崩溃，`texput.log` 出现上百个
`! Undefined control sequence \filename@simple`。

**根因**：`src/asy/jh.asy` 与 `src/asy/settexpreamble.asy` 用
`rfind(current_dir, "/linear-algebra/")` 硬编码上级目录名，再把
`"/linear-algebra/src/sty/..."` 拼回路径。本机目录名为
`linear-algebra-src`，`rfind` 返回 -1，路径拼接损坏，asy 的 latex
预导言失效。

**解决**：改为从当前路径动态推导 `src/` 目录（asy 总是在 `src/` 之下
运行），对任意上级目录名有效：

```asy
int src_dex = rfind(current_dir, "/src");
string src_dir = substr(current_dir, 0, src_dex) + "/src";
texpreamble("\usepackage{"+src_dir+"/sty/conc}\usepackage{"+src_dir+"/sty/linalgjh}");
```

## 问题 2：XeLaTeX 下 xdvipdfmx 拒绝 pfa 字体

**现象**：`xdvipdfmx:fatal: Sorry, pfa format not supported; please
convert the font to pfb`，无 PDF 输出。

**根因**：章首装饰字 `\fancyfont`（＝`\textbsi`）来自 `pbsi`
宏包（BrushScript），该字体只以 pfa 格式发布。pdflatex 可用，
但 XeLaTeX → xdvipdfmx 不支持 pfa；且该字体本身无中文字形。

**解决**：中文版在 `zhsetup.sty` 中重定义

```latex
\renewcommand{\fancyfont}[1]{{\sffamily\bfseries #1}}
```

（若一定要保留书法效果，可用 t1utils 的 `t1binary` 把 pfa 转 pfb
后装入本地 texmf 树。）

## 问题 3：Bad space factor (0)

**现象**：`\section{求解线性方程组}` 处报
`! Bad space factor (0). <recently read> \@savsf`。

**定位**：`\errorcontextlines=9999` 显示错误发生在
`\NR@sect → \Writetofile` 之后的 `\@esphack → \spacefactor\@savsf`；
再用最小文档（bookjh + xeCJK + `[single,write]` + 中文标题）逐项
二分确认。

**根因**：`answers.sty` 的 `\Writetofile` 用 `\@bsphack`/`\@esphack`
包裹纯文件写入。写入参数含中文时二者所见水平/竖直模式失配：
`\@bsphack` 侧未保存 `\spacefactor`（`\@savsf` 保持 `\newcount` 初值
0），`\@esphack` 侧在水平模式恢复 → 非法赋值。

**解决**：`zhsetup.sty` 重定义 `\Writetofile` 为不含间距保护的
内联写入版本（见 zhsetup.sty 注释）。

## 问题 4：正文排出字面 "\nobreak" 文本

**现象**：节标题正下方印出一个小号字面文本 `\nobreak`。

**定位**：`[single]`（不写答案文件）时消失 → 与写文件路径相关；
gs txtwrite 提取文本确认位置；给 `\protected@iwrite` 打补丁后消失。

**根因**：`answers.sty` 的 `\protected@iwrite` 末尾有一段
`\if@nobreak \ifvmode \nobreak \fi \fi`（本意是写文件后防止分页），
在 XeLaTeX + xeCJK 场景下该 `\nobreak` 被当作普通文本排出。

**解决**：并入问题 3 的方案——`zhsetup.sty` 的 `\Writetofile`
完全内联写入，不经过 `\protected@iwrite`。

## 问题 5：章号显示为「零」

**现象**：章首「Chapter 零」、页眉「第 零 章」，应为「一」。

**根因**：`\renewcommand{\Englishnumber}[1]{\zhnumber{#1}}`，
而调用方式是 `\Englishnumber{\value{chapter}}`；zhnumber 无法把
`\value{chapter}` 解析为整数，按 0 处理输出「零」。

**解决**：仿照原 `engnum.sty` 的 `\ifcase` 写法（`\ifcase` 可直接
展开 `\value`）：

```latex
\renewcommand{\Englishnumber}[1]{%
  \ifcase#1零\or 一\or 二\or ...\else \number#1\fi}
```

## 中文配置要点（src/zh/zhsetup.sty）

- **必须用 XeLaTeX 编译**，在 `bookjh` 之后加载 `zhsetup`；
  编译目录建议 `src/zh/`，`TEXINPUTS` 指向 `src//`（见 test-zh.tex
  头部注释或根 Makefile 的 `zh-test` target）。
- **字体链**（`\IfFontExistsTF` 逐级兜底，保证 macOS 与纯 TeX Live
  Linux 均可编译）：
  - 正文宋体：Songti SC → Noto Serif CJK SC → FandolSong（TeX Live 自带）
  - 标题黑体：Noto Sans CJK SC → Heiti SC → FandolHei
  - 楷体（替代斜体）：Kaiti SC → FandolKai
- **定理环境改名**：thmtools 把英文原名烘焙在 `\thmt@original@<env>`
  宏内（amsthm `\xdef`，无独立名字宏），需
  `\patchcmd{\thmt@original@theorem}{{Theorem}}{{定理}}{}{}`
  逐个改名。
- **Exercises 标题**：bookans.sty 硬编码，用
  `\patchcmd{\exercises}{\textbf{Exercises}}{\textbf{练习}}{}{}`。
- `\xeCJKsetup{CJKmath=true}` 允许数学模式中的中文。
- MetaPost 图形（`.1` 等 MPS 文件）在 XeLaTeX 下可正常包含
  （`\DeclareGraphicsRule{*}{mps}{*}{}` 兼容），已验证。

## 遗留事项（后续翻译工作清单）

- [ ] 索引：makeindex 不支持中文排序，全书翻译时需换 xindy 或自定义排序键
- [ ] 答案文件 `bookans.tex` 中的编号格式（如 `一.I.0.4`）需统一汉化规则
- [ ] 封面（covernew/covergraphic）、beamer slides、lab 手册未做中文适配
- [ ] `\topicsection` 的 Topic 装饰、contour 描边等排版细节在中文下需再核对
- [ ] 全书翻译后的分页/断字复查（中文断行由 xeCJK 自动处理）
