# Project-scope manifests

特定の repository の構成や規約に依存する skill は、`<repository名>.txt` に並べて project scope へ入れる。書式は `manifests/user.txt` と同じ。

インストール先 repository の root で実行する。

```bash
mise run --cd /path/to/my-ai-skill install:project -- <repository名>
```

Codex 向けは `.agents/skills/`、Claude Code 向けは `.claude/skills/` に入る。生成された差分は確認してから、その repository に commit する。
