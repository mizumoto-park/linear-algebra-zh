# 《Linear Algebra》(Jim Hefferon) LaTeX 源码架构调查报告

> 调查范围：本仓库 `src/` 下的英文原版全部源码。目的：理解原书的 LaTeX 组织方式与写作技术，为翻译和写新书提供参照。
> 配套的可运行示例见 `sample/`（独立 git 仓库），本文提到的每个机制在那里都有最小可编译演示。

---

## 1. 总体架构：一棵"主控文件 + 按章分目录"的树

```
src/
├── book.tex            ← 主书主控文件（\documentclass + \usepackage + \includeonly + \include 顺序）
├── jhanswer.tex        ← 答案书主控文件（独立成册，读入 book.tex 编译时生成的答案）
├── bookans.tex         ← 【生成的文件】编译 book.tex 时自动写出的答案流（不要手编）
├── publicationdate.tex ← 出版日期（封面、答案书共用）
├── sty/                ← 15 个自定义宏包（本书全部"技术"都在这里）
│   ├── bookjh.sty          总入口，只做字体方案选择 → \input bookjhconcrete.sty
│   ├── bookjhconcrete.sty  核心样式：版面、页眉页脚、章标题、定理环境、Topic、hyperref（988 行）
│   ├── linalgjh.sty        线性代数专用数学宏（linsys/grstep/colvec/…，403 行）
│   ├── bookans.sty         习题-答案配对系统（基于 answers 包二次开发）
│   ├── answerjh.sty        答案书一侧的 ans 环境定义与样式
│   ├── engnum.sty          \Englishnumber：把章号变成 One/Two/…
│   ├── hrefout.sty         \ifhrefout 布尔：控制 PDF 链接输出
│   ├── examjh.cls          出考卷用的独立文档类（也能自动导出答案卷）
│   └── …（封面、幻灯片、字体等辅助包）
├── gr/  vs/  map/  det/  jc/   ← 五章，每章一个目录
│   ├── gr1.tex gr2.tex gr3.tex   每个正文小节一个文件（一节 = 一个 \section）
│   ├── cas.tex leontief.tex …    每个应用专题（Topic）一个文件
│   └── mp/ch1.1, ch1.2 …         MetaPost 图形源码与产物（按章子目录存放）
├── asy/                ← Asymptote 图形（新图的制作工具）+ 公共设置 jh.asy
├── cover/ pref/ appen/ bib/    ← 封面 / 前言 / 附录 / 手工文献（thebibliography）
├── homeworks/ exams/ question-bank/ slides/ lab/   ← 教学配套（作业、考卷、题库、幻灯片）
└── Makefile            ← 构建工作流（book / answers / slides …）
```

**关键设计思想**

1. **一章一个目录，一节一个文件**。`book.tex` 里用 `\includeonly{...}` 列出全部文件，正文按 `\include{gr/gr1} … \include{gr/cas}` 的顺序拼装。每个 `.tex` 文件都以注释头开头（`% Chapter 1, Section 1 ...`）并以 `\endinput` 结尾。
2. **正文与答案同源**：答案直接写在习题环境里（见 §4），由宏包自动"流"到答案文件，答案书不用手工同步。
3. **计数器跨文件连续**：虽然每章拆成多个文件，但 `\section` 计数器不重置，因此整章编号连续；`book.tex` 通过显式 `\pagestyle{bookbody}` / `\pagestyle{booktopic}` 的切换来区分正文页与 Topic 页（样式差异在页眉页脚）。

---

## 2. 独特的编号体系：One.I.1.17

`bookjhconcrete.sty` 重定义了三个层级的计数器表示（配合 `engnum.sty`）：

```latex
\renewcommand{\thechapter}{\Englishnumber{\value{chapter}}}  % One, Two, …
\renewcommand{\thesection}{\Roman{section}}                  % I, II, III
\renewcommand{\thesubsection}{\thesection.\arabic{subsection}} % I.1, I.2, …
```

因此全书引用格式为 `One.I.1.17`（第一章 / 第 I 节 / 第 1 小节 / 第 17 个定理或习题）。**定理与习题共享同一个计数器**（见 §5 的 sibling 机制），所以小节内定理、例子、习题统一顺序编号——这是本书最有个性的设计，答案的标签 `\begin{ans}{One.I.1.17}` 与习题编号一一对应。

---

## 3. 宏包三层架构：入口 → 样式 → 数学

| 层 | 文件 | 职责 |
|---|---|---|
| 入口 | `bookjh.sty` | 只有一句话：选择 Concrete/Euler 字体方案 `\input bookjhconcrete.sty`（备选 CM、ebook 方案被注释保留） |
| 版面样式 | `bookjhconcrete.sty` | geometry 页面、xcolor 调色板、fancyhdr 页眉页脚、章/节标题重绘、定理环境、Topic 机制、目录（tocloft）、hyperref 选项、listings 代码样式 |
| 数学 | `linalgjh.sty` | 全部线性代数数学宏（§6） |

外加横切的 `bookans.sty`（习题-答案系统）与 `answerjh.sty`（答案书一侧）。

**值得学习的习惯**
- 所有颜色集中定义（`darkcolor/boldcolor/lightcolor/bgcolor/flourishcolor`），全站引用色名而不写死色值，换主题只改一处。
- 用 `etoolbox` 的 `\newbool{hardcopybool}` 做"屏幕版 / 印刷版"开关：`pdflatex "\def\hardcopy{}\input{book}"` 一行命令切换链接颜色（屏幕深蓝、印刷全黑）、封面页等。
- `\DeclareGraphicsRule{*}{mps}{*}{}` 让 pdflatex 把无扩展名图形 `fig.1` 当 MetaPost 产物读入——所以正文 `\includegraphics{gr/mp/ch1.1}` 不带扩展名。

---

## 4. 核心：习题-答案配对系统（两遍编译 + 答案成书）

这是本书最精巧的机制，基于 `answers` 宏包二次开发（`bookans.sty`）。

### 4.1 写作侧（正文中）

```latex
\begin{exercises}
  \recommended \item                 % ✓ 边栏标记：推荐习题；答案进主答案文件
    Use Gauss's Method …
    \begin{exparts*} \partsitem … \end{exparts*}
    \begin{answer} … … \end{answer}  % 答案内嵌于此，但不印在正文页
  \item …                            % 普通习题
    \begin{answer} … \end{answer}
  \puzzle \item …                    % "?" 边栏标记：谜题
\end{exercises}
```

- `exercises` 环境基于 `list` + 专用计数器，习题号自动为 `\arabic{subsection}.N`；
- `\recommended` / `\puzzle` 通过重定义 `\@item` 在题号旁打出 ✓/? 边栏标记；
- `exparts` / `exparts*` 是小题环境：`*` 版横排 (a) xx (b) yy，非 `*` 版竖排；条目用 `\partsitem`；
- `\begin{answer}…\end{answer}` 的内容**不排版**，而是被 `\Writetofile` 逐字写入外部文件 `bookans.tex`，形如：

```latex
\begin{ans}{One.I.1.17}   % 参数 = 编号自动拼接（\ansparams）
  …答案内容…
\end{ans}
```

同时宏包自动往答案文件写 `\chapter`/`\section` 分隔（`announcesectioninginanswerfile`），保持答案书目录结构同步。

### 4.2 编译流程（重要：为什么编译两遍）

```
第一遍 pdflatex book.tex  → 排版正文 + 生成 bookans.tex（答案流）
makeindex book            → 生成 book.ind（索引）
第二遍 pdflatex book.tex  → \include{...} 时答案文件已被读入交叉信息；
                             同时 \include{bib} 等第二次才能解析的引用就位
pdflatex jhanswer.tex     → 答案书：\input{\ansfile} 即 bookans.tex，独立成册
```

### 4.3 答案书侧（jhanswer.tex + answerjh.sty）

- 答案书是独立文档，重定义 `ans` 环境为列表项：`\item[One.I.1.17]`，并放置 PDF 命名目标（anchor）；
- **跨文档超链接**：习题号是 `\hyperref{./jhanswer.pdf}{ans}{One.I.1.17}{…}`——点击书里的题号跳到答案书 PDF 的对应答案，反之亦然（依赖两 PDF 文件名固定：book.pdf / jhanswer.pdf）；
- `\answerasgiven`：印一句斜体"答案引自原始文献"，用于书末来源题。

---

## 5. 定理环境体系：thmtools + framed 三种样式

`bookjhconcrete.sty` 用 `\declaretheoremstyle` 定义三种观感，再派生环境：

| 样式 | 观感 | 环境 |
|---|---|---|
| `shadedtext` | 淡黄底纹（snugshade）+ 黑体标题 | **theorem, definition, lemma, corollary** |
| `text` | 无底纹 | example, exercise, remark |
| `pf` | 小型大写 "Proof"，结尾自动 QED 符号 | proof |

要点：
- `sibling=theorem` 让 definition/lemma/corollary/example/exercise/remark 与 theorem **共享计数器** → 同小节统一编号（§2）；
- `\renewcommand{\thetheorem}{\arabic{subsection}.\arabic{theorem}}` → 编号只显示"小节.序号"（如 1.17）；
- `preheadhook={\begin{savenotes}\begin{snugshade}}`：定理里的脚注用 `savenotes` 救出来，不被底纹环境吞掉；
- 定理可带名字：`\begin{theorem}[Gauss's Method]`，名字加粗进标题；
- 交叉引用用语义化宏：`\nearbytheorem{th:GaussMethod}` 自动输出 "Theorem 1.1"（还有 nearbydefinition / nearbyexample / nearbyexercise … 全家桶），写作时不用记环境类型。

---

## 6. 线性代数数学宏速查（linalgjh.sty）

**方程组与消元**（全书最高频）
```latex
\begin{linsys}{3}          % {列变量数}；把系数/变量/常数按 r c 对齐
  x  &+  &2y  &=  &5 \\
     &   &y   &=  &1
\end{linsys}
\grstep{-\rho_1+\rho_2}                  % 箭头上方写行变换
\grstep[\rho_1+\rho_3]{-2\rho_1+\rho_2}  % 可选参数 = 箭头下方第二步
\repeatedgrstep{-\rho_2+\rho_3}          % 连续箭头自动收紧间距
\swap                                    % \rho_1\swap\rho_2 行交换 ↔
\spaceforemptycolumn                     % 该列没有 +/- 号时补一个加号宽的空盒
```

**矩阵与向量**
```latex
\begin{amat}[r]{3}  1&2&3 \\ 4&5&6 \end{amat} % 增广矩阵：3 列 + 竖线 + 常数列；[r] 右对齐
\begin{mat}[r] … \end{mat}    \begin{vmat}…\end{vmat}  % 圆/竖线括号矩阵（mathtools 的 *-star 变体）
\colvec[r]{1 \\ 2}            % 列向量；[r] 数字右对齐
\rowvec{1 & 2 & 3}            % 行向量
\nbym{2}{3} \nbyn{2}          % 2×3、2×2（数学模式）
\deter{A}  \begin{detmat}…\end{detmat}  % 行列式 |·|
\trans{A}  \rep{\vec{v}}{B}   % A^T、Rep_B(v)
```

**集合、数系、常用记号**
```latex
\set{\colvec{1\\0}+t\colvec{-1\\1} \suchthat t\in\Re}  % {…|…} 解集惯用句式
\R \C \Q \Z \N \F        % 数域黑板体 / 花体 F
\spanof{…} \directsum     % 张成 [ ]、直和 ⊕
\innerprod{u}{v} \norm{v} \absval{a} \dotprod   % 内积、范数、绝对值、点积（特制小圆点）
\alignedvdots  \vdotswithin{=}   % 与 = 对齐的竖点（linsys 中大量使用）
```

**映射与算子**
```latex
\map{f}{V}{W}      % f: V→W（文本模式用）
\mapsvia{t}        % --t--> 箭头标注
\mapsunder{x}      % x ↦ 下方标注
\composed{g}{f}    % g∘f
\identity          % id 算子名
\trace \rank \nullity \sgn \adj   % DeclareMathOperator
```

** spaces 家族**：`\rangespace{h}` 𝓡(h)、`\nullspace{h}` 𝓝(h)（mathrsfs 花体），带 ∞ 下标的一般化版本 `\genrangespace`。

**文本侧**
```latex
\definend{term}      % 定义中的术语：斜体
\Dash                % 带空格的破折号 —（本书不直接打 ---）
\Maple \Sage         % 软件名斜体宏
\vcenteredhbox{…}    % 图形垂直居中
```

---

## 7. 版面与设计技术（bookjhconcrete.sty）

- **页面**：`geometry` 自定义 7.5in×9.25in 开本、`twoside`、bindingoffset 装订边距。
- **页眉页脚**：`fancyhdr` 定义四种页面样式——`bookfront`（前言无页眉）、`booktoc`、`bookbody`（正文：页眉外=页码、内=章节名斜体）、`booktopic`（Topic 页页脚三处页码）。`book.tex` 在正文与 Topic 之间显式切换 `\pagestyle`。
- **章标题重绘**：重定义 `\chapter`/`\@makechapterhead`——顶部一条 `flourishcolor` 细色条 + `\fancyfont`（手写体 pbsi）的 "Chapter One" + Bitstream Vera Sans Bold (`\usefont{T1}{fvs}{b}{n}`) 的大标题。**重定义 `\@chapter` 还顺带把章名写进答案文件**，保持答案书目录同步。
- **节标题**：`\@startsection` 重定义 `\section`/`\subsection`（fvs 字体、负 beforeskip 紧凑排版）；`\topicsection` 在标题左侧竖排一个 "Topic" 彩色标签。
- **Topic 机制**：`\topic{Name}` = 不编号的 star-section + 独立页样式 + 习题改从 1 编号（`\setcounter{theorem}{0}` + 改 `\exercise@deflabel`）+ 目录里记 "Topic: Name"。
- **可选小节**：`\subsectionoptional{Name}` = 标题带星号 `*`、目录也带星号（`\texorpdfstring` 保证书签不出错）；`book.tex` 目录页注明"星号小节可选"。
- **目录**：`tocloft`——章条目不印页码（`\cftpagenumbersoff{chapter}`）、`tocdepth=2`、点线缩进微调。
- **超链接**：hyperref 全局加载；`hardcopy` 布尔切换链接色（屏幕深蓝 / 印刷黑）；`hypertexnames=false` 解决跨章重名 anchor。
- **索引**：`\index{...}` 散布正文（含 `!` 层级、`|(}` 区间），`makeidx` + 自定义 `book.isty`（控制 theindex 前后注 + 页面样式）。
- **代码**：`listings`（Sage/Maple 会话，淡黄背景）；`upquote` 修正 verbatim 引号。
- **其他**：`microtype` 排版微调、`paralist` 紧凑列表、脚注用符号编号（`\fnsymbol` + footnpag）、`\clearemptydoublepage`（章从右页起、空白页全空）。

---

## 8. 图形：MetaPost + Asymptote 双轨

- **MetaPost**（老图，量大）：源码 `gr/mp/ch1.mp` 编译出 `ch1.1`、`ch1.2`…（编号即输出序号）；正文 `\includegraphics{gr/mp/ch1.1}` **不带扩展名**，靠 `\DeclareGraphicsRule{*}{mps}{*}{}` 让 pdftex 直接吃 MPS。
- **Asymptote**（新图，尤其 3D）：`asy/` 下共享 `jh.asy` 设置；Makefile 里用 `asy -nosafe` 编译。
- 教学含义：图与文分离，按章子目录管理，文件名即坐标（章.序号）。写新书如果想零依赖，可以用 TikZ 替代（见 sample 的做法）。

## 9. 文献、交叉文档、literate 标记

- 文献：手工 `thebibliography`（`bib/bib.tex`），`\cite{...}` 引用；`\answerasgiven` 常与之配套。
- `xr` 宏包 + `hrefout`：答案书要反向引用主书的内容（`\nearbytheorem` 在答案书里改写为跨 PDF 链接）。
- **noweb 风格标记**：正文中大量 `%<*df:linearcombination>` … `%</df:linearcombination>` 字面块——用于标记"这段是某某定义/定理的本体"，便于工具抽取（如生成幻灯片、web 版）。翻译与改写时**这些注释行应原样保留**。

## 10. 构建工作流（Makefile）

- `src/Makefile`：`book.pdf` 依赖所有章节目录，规则 = `pdflatex → makeindex → pdflatex`；`answers` 依赖 book（要等 bookans.tex 生成）；`slides`、`lab` 独立目标。
- `TEXINPUTS=$(SRC)//:` 让 `sty/`、`mp/`、`asy/` 全目录可被搜索（`//` = 递归）。
- 顶层 `Makefile` 只是便捷入口（`make book / answers / zh-book …`）。
- 翻译工作流（本仓库已有）：`src/zh/` 放中文文件，同名路径镜像英文目录，用 `TEXINPUTS` 叠加搜索路径 → 未翻译章节自动回退英文原文件。**这就是为什么翻译时保持文件名/路径/宏完全不变至关重要。**

## 11. 对"写新书"的最小建议

1. 复刻这套**骨架**而非照抄 988 行样式：主控文件 + 每节一文件 + 三层宏包（入口/样式/数学）。
2. 定理 sibling 共享计数器 + "小节.序号"编号 + 习题-答案两遍编译，是本书体验的核心三件套，值得全盘继承。
3. 颜色、字体、页眉全部收进一个样式文件集中管理；写作正文只许用语义宏（`\definend`、`\nearbytheorem`、`\Dash`），不许手写格式。
4. 图形用"目录 + 无扩展名引用"的约定；若不想依赖 MetaPost/Asymptote，用 TikZ 但保持同样的按章子目录习惯。
5. 翻译场景下：**只译文本，不动宏、不动结构注释（%<*…>）、不动图形文件名**。
