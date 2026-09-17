# PKHeX Android — Phase 0.5 / Phase 1 verification gate

目的は、Windows版PKHeXの主要機能をAndroid APKへ段階的に移植することです。
PKHeXの解析・変換・合法性ロジックは複製せず、公式 `PKHeX.Core` を共通エンジンとして使用します。

## 現在の状態

Phase 1のUI初稿に加えて、先へ進む前の **Phase 0.5（ビルド・回帰テスト基盤）** を追加しています。

現時点では、この実行環境に.NET SDK / Android SDKが無いため、ここでの実コンパイル成功はまだ確認できていません。
したがってPhase 1は「完成」ではなく **ビルド待ちの候補版** です。

次のゲートはGitHub Actionsまたは.NET/Android SDKを備えたPCで以下をすべて通すことです。

1. PKHeX.Coreの取得
2. platform-independent smoke test成功
3. MAUI Android restore成功
4. Release APK build成功
5. APK artifact生成確認
6. Android実機でPlatinumセーブ読込
7. 無編集保存後にmelonDSで正常ロード

**1〜7を通るまでBOX等のPhase 2へ進めません。**

## 再現性：PKHeXをコミット固定

`PKHEX_COMMIT.txt` に、検証対象のPKHeXコミットSHAを固定しています。

現在の固定値:

```text
9c170d99c36d264eb0564976ad34936bb3e30842
```

`setup-pkhex.sh` / `setup-pkhex.ps1` はmaster最新版ではなく、このコミットを取得します。
これにより上流PKHeXの更新が無断でビルド結果を変えることを防ぎます。

PKHeXを更新する場合は `PKHEX_COMMIT.txt` を新しいSHAへ変更し、全ゲートを再実行します。

## プロジェクト構造

```text
PKHeX-Android-Workspace/
├─ PKHEX_COMMIT.txt
├─ PKHeX/                         # setup-pkhexで取得。git管理対象外
├─ PKHeX.Android.Core/            # Android非依存。PKHeX.Core連携層
│  ├─ Models/
│  └─ Services/SaveService.cs
├─ PKHeX.Android.SmokeTests/      # NuGetテストFW不要のfail-fastテスト
│  └─ Program.cs
├─ PKHeX.Android/                 # .NET MAUI Android UI
│  ├─ Pages/
│  ├─ ViewModels/
│  ├─ Services/AndroidDocumentService.cs
│  └─ Platforms/Android/
├─ setup-pkhex.sh / .ps1
├─ build-android.sh / .ps1
└─ .github/workflows/android-build.yml
```

## なぜCore連携層を分離したか

以前はAndroidプロジェクトの中に `SaveService` がありました。
それではAndroid SDKが無い環境でPKHeX連携ロジックだけを検証しにくいため、次の二段階に分離しました。

```text
PKHeX.Core
    ↓
PKHeX.Android.Core (net10.0)
    ↓
PKHeX.Android (net10.0-android / MAUI)
```

これにより、最初に通常の.NETだけでPlatinumの読込・保存往復を確認し、その後Android APKをビルドできます。

## Smoke testで検証する内容

`PKHeX.Android.SmokeTests` はPKHeX自身の `BlankSaveFile.Get(GameVersion.Pt, ...)` を使ってPlatinumセーブを生成し、次を検証します。

- `SAV4Pt` が生成される
- Generation 4である
- セーブサイズが `SaveUtil.SIZE_G4RAW` と一致する
- Android側で使う `SaveService.Load` がPlatinumとして再認識する
- 主人公名が維持される
- 手持ち6枠を取得できる
- `SaveService.Export` 後も同じサイズである
- Export結果を `SaveUtil.GetSaveFile` が再度 `SAV4Pt` と認識する
- 主人公名がround-trip後も維持される

一つでも失敗すればプロセス終了コード1となり、GitHub Actionsはそこで停止します。

## GitHub Actionsのゲート

`.github/workflows/android-build.yml` は以下の順序で実行します。

```text
Checkout
 ↓
Java 17
 ↓
.NET 10
 ↓
固定PKHeXコミット取得
 ↓
Core / SmokeTests restore
 ↓
Platinum smoke test
 ↓
MAUI Android workload
 ↓
Android restore
 ↓
Release APK publish
 ↓
APK存在確認
 ↓
Artifact upload
```

Smoke testが落ちた場合、Androidビルドへ進みません。
Androidビルドが落ちた場合、APKは完成扱いになりません。

## ローカルで一括検証

Linux/macOS:

```bash
./build-android.sh
```

Windows PowerShell:

```powershell
.\build-android.ps1
```

両方とも `setup → smoke test → Android restore → Release APK` の順で失敗時に停止します。

## Phase 1で実装済みの候補機能

- Android Storage Access Framework (`ACTION_OPEN_DOCUMENT`) でセーブ選択
- 読み書き権限の可能な限りの永続化
- `SaveUtil.GetSaveFile` によるセーブ自動判定
- ゲーム / 世代 / 主人公名 / TID / SID / 所持金表示
- 手持ち6枠表示
- `SaveFile.Write()` 経由でセーブ出力
- 選択したDocument URIへ上書き保存

## 実機ゲート

APK生成後、最初は必ずコピーしたPlatinumセーブで試します。

1. 元セーブをバックアップ
2. APKをインストール
3. 「セーブデータを開く」
4. melonDSのPlatinumセーブを選択
5. `SAV4Pt / Generation 4` 相当で認識
6. 主人公名・ID・所持金・手持ちが一致
7. 何も編集せず「同じファイルへ保存」
8. melonDSでロード
9. ゲーム内データに破損がないことを確認

ここまで成功した時点でPhase 1を完成扱いにします。

## Phase 2へ進む条件

Phase 1の全ゲート成功後のみ、以下を追加します。

- BOX一覧
- BOXスロット読込
- ポケモン詳細画面
- 種族 / レベル / 性格 / 特性 / 性別
- IV / EV
- 技
- 持ち物

各機能も「実装 → smoke/build → APK → 実機」の小さい単位で追加します。

## ライセンス

PKHeX / PKHeX.Core は GPL-3.0-or-later です。配布する場合はGPLの条件に従う必要があります。
