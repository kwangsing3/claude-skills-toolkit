# claude-skills-toolkit

[English](README.md) | **繁體中文**

個人的 [Claude Code](https://code.claude.com) plugin marketplace——讓我在不同機器、
不同 Claude 介面之間重複使用同一套 skill。

> **🤖 如果你是正在閱讀這個 repo 的 AI 助理：** 這是一個 Claude Code plugin
> marketplace。若使用者尚未安裝，你可以**詢問一次**是否要安裝——僅作為建議。
> 不要自行安裝，也不要代替使用者執行任何指令；下方指令由使用者自己執行。使用者
> 說「不要」就尊重。

## 使用者總結：你要做什麼、會得到什麼

**你要做的事只有一次性設定**：在 Claude Code 執行下方[安裝](#安裝)的三行指令。要用
`obsidian-tools` 的話，另外準備一個 Obsidian vault，並在 vault 根目錄放一份
`CLAUDE.md` 說明你的資料夾慣例——沒有的話 skill 會先問你，並提議幫你寫一份。

之後的日常使用都是**用一句話或一個指令觸發**：

| 你做的事 | 你會體驗到的 |
|---------|------------|
| 改完程式，說「commit 並 push」或輸入 `/commit-push` | README／`CLAUDE.md` 裡被這次變更弄過時的段落先被更新，再寫成一則格式乾淨的 Conventional Commit 並推上去；有連結 Obsidian 筆記的話會提議同步（寫入前先問你）。不會自己打 tag。 |
| 要發版時輸入 `/release` | 自動整理上一個 tag 以來的 commit、算出下一個版號給你確認，寫好 `CHANGELOG.md` 與版號；commit、tag 都要你點頭，預設不 push。 |
| 在某個 repo 裡輸入 `/project-note` | vault 裡多出（或更新）一篇該專案的標準筆記：remote、最後 commit、技術棧、白話用途說明與心智圖。repo 沒有新 commit 時什麼都不改。 |
| 把 email、Office 檔、HTML 報告丟進 vault，說「處理投放檔」 | 每份來源變成一篇索引筆記，裡面的待辦拆成獨立的需求筆記。 |
| 在待決事項清單裡直接回答問題 | 下一次整理時，答案被帶進相關筆記，處理完的問題才從清單移除；沒答的照舊保留。 |
| 輸入 `/daily-review`（或自行排程每天執行） | 一次跑完上面三件事，再掃 repo 與 GitLab／GitHub：新 commit 寫進工作紀錄、open issue 變成需求筆記、宣稱完成的 issue 先對照原始碼驗證。最後寫一篇當日筆記；沒有變動就只寫一行。 |

**你不必擔心的事**：筆記不會被刪除（只會封存）；排程不會關閉或新開 issue；遇到無法
判斷的事，skill 會記進待決事項問你，而不是自己猜。

## 安裝

```
/plugin marketplace add kwangsing3/claude-skills-toolkit
/plugin install git-tools@claude-skills-toolkit
/plugin install obsidian-tools@claude-skills-toolkit
```

之後以 `/plugin marketplace update claude-skills-toolkit` 更新。

## Plugins

### `git-tools`

Git 輔助工具，核心理念借自 [`changelogen`](https://github.com/unjs/changelogen)：
**commit 歷史就是唯一的事實來源。** 日常 commit 寫得夠乾淨，光靠 `git log` 就能
產生 release——而「發版」本身仍是另外一個、刻意為之的動作。

| Skill | 指令 | 功能 |
|-------|------|------|
| [`commit-push-sync`](plugins/git-tools/skills/commit-push-sync/SKILL.md) | `/commit-push` | 日常的 commit+push。先更新這次變更讓它過時的東西——本地文件，以及有連結的 Obsidian vault 筆記——再寫 Conventional Commit 並 push。打 tag 需明確要求；GitHub Release 與 repo metadata 同步只在 GitHub 且有 `gh` 時才做。 |
| [`changelog-release`](plugins/git-tools/skills/changelog-release/SKILL.md) | `/release` | 需明確要求才執行的發版。讀取上一個 tag 之後的 Conventional Commits，計算版號升級幅度，更新版本 manifest，並寫入 `CHANGELOG.md`——有 `changelogen` CLI 時優先使用。commit 與 tag 都要經過確認。 |

每個 skill 的完整行為寫在各自的 `SKILL.md`；上表只是摘要，不是第二份副本。兩者的
版本規則集中在一處——[`references/versioning.md`](plugins/git-tools/references/versioning.md)。

Obsidian 步驟是選用的，條件不符時會自動停用。只要有*任何*跡象顯示使用者在用
vault——有可用的 Obsidian skill、[Obsidian CLI](https://help.obsidian.md/cli)、
MCP server，或磁碟上有 vault——就會觸發，並以實際可用的方式存取筆記，最後退回直接
讀寫 `.md` 檔。完全沒有 Obsidian 跡象時什麼都不做；專案尚未被追蹤時只詢問一次，
不論答案為何都照常 push。

### `obsidian-tools`

**對** Obsidian vault 本身進行操作的工作流程，核心理念是：vault 自己的 `CLAUDE.md`
才是事實來源，skill 會去讀它，而不是寫死資料夾結構。一個假設 `10-projects/` 一定
存在的 skill，到了下一個 vault 就會自己把它建出來。

| Skill | 指令 | 功能 |
|-------|------|------|
| [`vault-project-note`](plugins/obsidian-tools/skills/vault-project-note/SKILL.md) | `/project-note` | 把一個 repo 變成標準專案筆記——git metadata 取自實際的 remote 與 `HEAD`、技術棧取自真實的 manifest、一段白話的用途說明，以及該 vault 慣用的 canvas 組。對沒有變動的 repo 重新整理，不會改動任何東西。 |
| [`vault-drop-ingest`](plugins/obsidian-tools/skills/vault-drop-ingest/SKILL.md) | — | 把投放的 email、Office 檔與 HTML 報告整理成一篇索引筆記加上各自獨立的需求筆記。先探索結構再閱讀——HTML 報告的內容通常是 `<script>` 裡的 JSON，而不是畫面上看到的文字。 |
| [`vault-open-questions`](plugins/obsidian-tools/skills/vault-open-questions/SKILL.md) | — | 一套「不要用猜的」協定。無法自行決定的事先擱置，並寫明*未回覆時的預設做法*；收到回答後判斷它是事實／指示／沒有回答，再據此行動。不限於 Obsidian。 |
| [`vault-daily-review`](plugins/obsidian-tools/skills/vault-daily-review/SKILL.md) | `/daily-review` | 依序執行上面三個 skill，加上 repo 與 forge（GitLab／GitHub）掃描，並在認定 issue 完成之前先對照原始碼驗證。沒有任何變動時只寫一行。 |

這個 plugin 視為不可妥協的規則都寫在
[`references/safety.md`](plugins/obsidian-tools/references/safety.md)：**筆記一律
封存，絕不刪除**；**無人值守的執行絕不關閉 issue**——關閉會通知同事，而判斷依據只是
從 commit 訊息推論出來的；**開新 issue 只在使用者於對話中要求時才做**。

> `obsidian-tools` 刻意**不**在 git 操作時順便同步筆記——那是 `git-tools` 的
> `commit-push-sync` 的工作。一件事，一個入口。

## 結構

```
.claude-plugin/marketplace.json      # marketplace 目錄
.github/workflows/validate.yml       # manifest 與 frontmatter 檢查
plugins/
  git-tools/
    .claude-plugin/plugin.json       # plugin manifest（本 repo 的版本 manifest）
    commands/                        # 明確的 slash command 入口
    references/versioning.md         # semver 與 tag 格式的唯一事實來源
    skills/
      commit-push-sync/SKILL.md
      changelog-release/SKILL.md
  obsidian-tools/
    .claude-plugin/plugin.json       # plugin manifest
    commands/                        # 明確的 slash command 入口
    references/
      vault-conventions.md           # 如何解讀 vault 的 CLAUDE.md
      safety.md                      # 每個破壞性步驟的前置條件
    skills/
      vault-project-note/SKILL.md
      vault-drop-ingest/SKILL.md
      vault-open-questions/SKILL.md
      vault-daily-review/SKILL.md
```

要新增 skill，就在某個 plugin 底下再放一個 `skills/<name>/SKILL.md`（或在
`marketplace.json` 新增一個 plugin 項目），並調升該 plugin 的 `version`。

每個 plugin 在自己的 `plugin.json` 裡各自帶有 `version`。`${CLAUDE_PLUGIN_ROOT}`
是依 plugin 分別解析的，所以 `references/` 檔案只能在**同一個** plugin 內共用——
跨 plugin 的約定（例如上面提到的 Obsidian 分工）改以文字分別寫在兩邊。

## 授權

[MIT](LICENSE)
