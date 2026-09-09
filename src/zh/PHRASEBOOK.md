# 第一章翻译短语表（PHRASEBOOK）

配合 `GLOSSARY.md`（术语硬约束）与 `TRANSLATOR-GUIDE.md`（规则）使用。
本表解决两处未覆盖的高频表述，各分片翻译必须统一采用。

## 章节与小节标题

| 英文 | 中文 |
|------|------|
| Linear Systems（章名） | 线性方程组 |
| Solving Linear Systems | 求解线性方程组 |
| Gauss's Method | 高斯消元法 |
| Describing the Solution Set | 解集的描述 |
| General = Particular + Homogeneous | 通解=特解+齐次解 |
| Linear Geometry | 线性几何 |
| Vectors in Space | 空间中的向量 |
| Length and Angle Measures | 长度与夹角的度量 |
| Reduced Echelon Form | 简化阶梯形 |
| Gauss-Jordan Reduction | 高斯–若尔当消元 |
| The Linear Combination Lemma | 线性组合引理 |
| Computer Algebra Systems | 计算机代数系统 |
| Input-Output Analysis | 投入产出分析 |
| Accuracy of Computations | 计算的精度 |
| Analyzing Networks | 网络分析 |

## 高频术语补充（GLOSSARY 未覆盖者）

| 英文 | 中文 |
|------|------|
| row operations / row reduction | 行变换 / 行化简 |
| swap (two rows) | 对换（两行） |
| row combination（kρ_i+ρ_j 型操作） | 倍加 |
| rescale / multiply a row by k | 倍乘 |
| leading entry | 首主元 |
| row equivalence / row-equivalent | 行等价 / 行等价的 |
| elementary reduction operations | 初等化简操作 |
| unique solution / no solution / infinitely many solutions | 唯一解 / 无解 / 无穷多解 |
| particular solution | 特解 |
| the prior example | 前面的例题 |
| the prior subsection | 前一小节 |
| leading coefficient | 首项系数 |
| contradictory equation | 矛盾方程 |
| dot product | 点积 |
| scalar multiplication | 标量乘法 |
| unit vector | 单位向量 |
| directed line segment | 有向线段 |
| tail / head（向量两端） | 起点 / 终点 |
| parallelogram rule | 平行四边形法则 |
| resultant | 合向量 |
| perpendicular / orthogonal | 垂直 / 正交 |
| trigonometric | 三角的 |
| Physics problem / Statics | 物理问题 / 静力学 |
| Chemistry problem | 化学问题 |
| toluene / nitric acid / trinitrotoluene (TNT) | 甲苯 / 硝酸 / 三硝基甲苯（TNT） |
| balance point | 支点 |
| meter stick | 米尺 |
| Network analysis | 网络分析 |

## 习题与解答常用句式

| 英文 | 中文 |
|------|------|
| Use Gauss's Method to ... | 用高斯消元法…… |
| Solve this system. | 求解该方程组。 |
| Solve the associated homogeneous system. | 求解相应的齐次方程组。 |
| Find the ... | 求…… |
| Show that ... | 证明…… |
| if it is defined | （若它有定义） |
| In the exercises here, and in the rest of the book, you must justify all of your answers. | 在这里的练习以及全书其余练习中，你必须对每个答案给出理由。 |
| Unique solution / Infinitely many solutions / No solution（答案条目） | 唯一解 / 无穷多解 / 无解 |
| \recommended | 命令原样保留 |

## 结构处理细则

- `\chapter{Linear Systems}\leavevmode` → `\chapter{线性方程组}\leavevmode`（注释保留）
- `\hypertarget{ex:Statics}{Statics}` → `\hypertarget{ex:Statics}{静力学}`（锚名不动，仅译显示文字）
- `\definend{...}` 参数翻译；`\index{...}` 参数保留英文
- 数学内 `\text{...}`/`\hbox{...}` 为英文文字者翻译，如
  `\text{swap row 1 with row 3}` → `\text{对换第1行与第3行}`；
  `\grstep{-(1/2)\rho_1+\rho_2}` 等纯记号保留
- 单位：`2~kg` → `$2$~千克`；`~` 照抄
- `Topic` → 专题；`This subsection is optional.` → 本小节为选读内容。
- 引用编号 `One.I.1`、`Lemma One.II.2` 等原样保留
- `lstlisting` 代码块、`picture` 环境、`tabular` 中纯数字/记号保留；
  `tabular` 内的英文表头文字翻译
- 图形文件名 `\includegraphics{...}` 不动
- `\Dash`、`\absval{}`、`\colvec`、`\amat`、`\zero`、`\suchthat`、`\set{}{}` 等宏原样保留，仅译其参数中的英文文字
