# git-tutorial

# このサイトがシンプルでわかりやすい。
http://www.eiplab.com/2011/07/git-topic-branc/

#　コンフリクトしたら焦らずこれをみましょう
http://qiita.com/nfnoface/items/8823bfb8f50c4c90412d

# 最初はこれも良いかも
http://techacademy.jp/magazine/6235


Git紹介用（使ってなさそうな便利機能）

## GitをFork(画面上)
=> 何してもいい自分だけのコピーリポジトリが完成
=> masterは本家と同期時にfetch/merge作業が発生するので、改修はfork後ブランチを切って作業すること。

## branch作成

```
#ブランチ作成
git branch hogehoge

#ブランチが作られたことを確認
git branch

#作ったbranchに切り替え
git checkout hogehoge

```

## ソースをclone

```
$ git clone https://github.com/atsuko-tsujioka/git-tutorial.git git-tutorial-parent
```

## ログを確認

```
$ git log
```

## 差分を確認（ファイル数が多いときは一度pushしてgithubブラウザから見ると差分見やすい）

```
$ git diff
```

##　新規追加の場合はgit addコマンドを使用

```
$ git add file_or_dir_name
```

## add後または改修の場合はgit commitコマンドを使用

```
$ git commit file_or_dir_name
コメント入力 => :wq
```

OR

```
$ git commit -m "コミットメッセージ" file_or_dir_name
```

## コミットをまとめる
 
```
git rebase -i HEAD~X
```

## リモートに追加

```
git push orign hogehoge
```

## forkリポジトリに本家を同期する

```
git remote add upstream {本家のclone URL} (1回でOK)
git fetch upstream
git merge upstream/master

```

## remoteの最新ソースをlocalにとってくる

```
git pull
```

## conflictした場合の対応

```
git merge master

Conflict

#localを正とする場合
git checkout --ours hello.txt

#remoteを正とする場合
git checkout --theirs hello.txt

##半々の場合、各ツールを使用するか、>>>> <<<<目印を頼りに正のデータに手修正

git add hello.txt

git commit hello.txt
```

## merge前に戻す

```
git reset --hard HEAD
```


#リリースタグの生成
Githubの画面上からXX releases => Draft a new release => タグ名はチケット名を記載
