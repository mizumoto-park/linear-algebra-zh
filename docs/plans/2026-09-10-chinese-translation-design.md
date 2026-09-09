# 中文翻译版设计方案

日期：2026-09-10
状态：已确认

## 决策摘要

| 决策点 | 结论 |
|--------|------|
| 架构 | 平行目录树（方案 B）：`src/zh/` 镜像原书结构，原文一行不动 |
| 范围 | 主书全文：pref + 五章正文 + Topics + 附录；不含 jhanswer、slides、lab |
| 执行方式 | AI 初翻 + 人工校对，逐章循环 |
| 回退机制 | 同名回退：编译时 CWD=`src/zh/`，kpathsea 先查 `zh/<同名文件>`，无则落到英文原文 |
| 引擎 | XeLaTeX + xeCJK（`zhsetup.sty`）；英文版继续 pdflatex，互不影响 |

## 目录结构

```
src/
  gr/ vs/ map/ det/ jc/ pref/ appen/ bib/ sty/ ...   ← 原文（不动）
  zh/
    zhsetup.sty          语言层：字体、定理改名、answers.sty 补丁等
    book-zh.tex          中文主文件，include 清单复刻 book.tex
    GLOSSARY.md          术语表（AI 初翻硬约束 + 校对裁决依据）
    TRANSLATOR-GUIDE.md  翻译规范
    gr/gr1.tex ...       译文文件，与原文同名一一对应
    cover/covernew.tex   中文封面
    pref/pref.tex  appen/appen.tex ...
```

### 同名回退

`\include{gr/gr1}` 的解析顺序：`src/zh/gr/gr1.tex`（已翻译）→
`src/gr/gr1.tex`（英文原文，经 TEXINPUTS）。因此任何时刻
`make zh-book` 都能产出一本完整的书：已翻章节为中文，未翻章节为
英文原样。翻译进度 = 译文文件存在性，可精确统计。

### 共享资源

sty、MetaPost/Asymptote 图形、答案写出机制全部复用原树，零复制。
MPS 图形在 XeLaTeX 下可正常包含（已验证）。

## 翻译工作流（单章循环）

1. 指定章节（如 gr/gr1）→ AI 产出 `zh/gr/gr1.tex`
2. `make zh-book` 编译验证 + 页面渲染抽查
3. 人工校对：直接改 zh 文件，或告知 AI 改动点
4. 定稿；`make zh-progress` 查看进度

翻译中改动的术语回写 GLOSSARY.md。

## 翻译规范（详见 TRANSLATOR-GUIDE.md）

- 只译文字；LaTeX 命令、数学环境、`\label`/`\ref`/锚点原样保留
- `\index{}` 条目第一阶段保留英文
- 全角标点；`\label` 命名不变；定义/定理名由 zhsetup 统一处理
- 图形不重做；`bib` 参考书目第一阶段保留英文
- 索引第一阶段保留 makeindex + 英文条目（中文索引用 xindy，见遗留）

## 上游同步

原书为第四版最终版，上游仅修 bug。同步后 `git diff` 上游文件，
对照同名 zh 文件人工评估，必要时复核译文。

## Makefile targets

- `make zh-test`：字体/兼容性小样（已有）
- `make zh-book`：全书编译（xelatex ×3 + makeindex）→ `zh/book-zh.pdf`
- `make zh-progress`：翻译进度清单
- `make clean` / `clean-zh`：清理

## 遗留事项

- 中文索引（xindy 或排序键方案）
- 答案文件编号格式汉化（`一.I.0.4` 类）
- 封面中文版式、hyperref PDF 元数据汉化
- jhanswer 答案书、slides、lab 的中文版（本期不做）
