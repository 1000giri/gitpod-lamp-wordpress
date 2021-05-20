# Gitpod で Apache + PHP + MySQL + WordPress

## このリポジトリを Gitpod で開くには？

どんなものか試すだけでしたら、以下の URL にアクセスしてください。

[https://gitpod.io/#https://github.com/1000giri/gitpod-lamp-wp](https://gitpod.io/#https://github.com/1000giri/gitpod-lamp-wp)

そうでない場合は git clone, git push してから、そのリポジトリ URL の前に `https://gitpod.io/#`をつけてアクセスしてください。  
次のような URL になるでしょう。

```
https://gitpod.io/#https://github.com/<your username>/gitpod-lamp-wp
```

## Apache + PHP + MySQL

この VSCode がブラウザで起動してしばらくは Gitpod 内部で Apache や MySQL の起動処理をしていますので、30 秒ほど時間が経ってから作業を始めてください。
具体的にはデフォルトで開かれているであろうターミナルのプロンプト$が戻るまでです。

public フォルダを公開フォルダ(Apache のルートディレクトリ)に設定してありますので、HTML ファイルや PHP ファイルはこの public フォルダに置いてください。  
デフォルトで、この public 内に phpinfo()が表示される index.php を置いてあります。

### public フォルダへの URL でのアクセス方法

public フォルダに置いたファイルへのアクセス URL は少し特殊です。

Gitpod は内部で https の 80 番から http の 8001 番へリダイレクトしているようで、実際に Apache の設定で確認するとポートは現時点では 8001 番になっていました。  
なので、Gitpod では一般的な、 URL の後ろにコロンと 8001 ポート番号をつけてアクセスしてもうまくいきません。  
そのためか、Gitpod ではアクセス URL を生成するコマンドが用意されています。

```bash
gp url 8001
```

のように、ターミナルでコマンドを実行すると有効な URL が表示されます。

現時点では、単純に VSCode が表示されているアドレスバーのドメインの先頭に「8001-」を加えるだけのようです。

```
https://8001-<ランダムなサブドメイン>.gitpod.io/
```

### MySQL

MySQL のデータベースの操作は、ターミナルで mysql とだけ打てば MySQL の root ユーザーでログインできます。MySQL の root ユーザーのパスワードは設定されていませんでした。

### この開発環境を構築しているファイル

この開発環境の構築に関する主なファイルは下の 2 つのファイルです。

.gitpod.dockerfile

```docker
FROM gitpod/workspace-mysql

ENV APACHE_DOCROOT_IN_REPO="public"
```

.gitpod.yml

```yaml
image:
  file: .gitpod.dockerfile
ports:
  - port: 8001
    onOpen: ignore
  - port: 3306
    onOpen: ignore
tasks:
  - init: >
      mkdir public
    command: apachectl start
```

Gitpod が作成した `gitpod/workspace-mysql` イメージをそのまま利用しています。  
これは、`gitpod/workspace-full`という Apache, PHP, C/C++, Python などの開発環境がすでに入っているイメージに、後から MySQL をインストールしたイメージになっているようです。

このイメージの環境変数 APACHE_DOCROOT_IN_REPO でリポジトリの public フォルダを公開するように指定しています。

## WordPress

この環境で簡単に WordPress を始められるように `wordpress.sh` というシェルスクリプトを置いてあります。  
WordPress がインストールされるフォルダは public になりますので、何か大切なファイルを public フォルダに置いている場合は避難させてください。
デフォルトで public に置いてある index.php は先に削除しなくても WordPress が上書きするようです。

`wordpress.sh` に実行権限を付与して(+x)から実行すると、 wp(wp-cli.phar) コマンドをインストールして WordPress へのデータベース情報の受け渡しが終わった状態まで内部でセットアップされます。  
以下のコマンドをコピペしてターミナルで実行してください。

```bash
chmod +x wordpress.sh && ./wordpress.sh
```

ブラウザで新しいタブを開いて、そのアドレスバーに `https://8001-<ランダムなサブドメイン>.gitpod.io/wp-admin/install.php`と入力してアクセスすると、
おなじみの、サイトタイトルやユーザー、パスワード、email などを入力する画面が表示されます。

### wordpress.sh

```bash
#!/bin/bash

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo mv ./wp-cli.phar /usr/local/bin/wp
sudo chmod +x /usr/local/bin/wp

cd public
wp core download --locale=ja
wp core config --dbname=wordpress --dbuser=root --dbpass='' --dbhost=localhost --dbprefix=wp_
wp db create
sed -i '1s/^/<?php $_SERVER["HTTPS"]="on"; $_ENV["HTTPS"]="ON"; ?>\n/' wp-config.php
```

デフォルトでは日本語仕様の WordPress がインストールされます。  
他の言語を利用したいときは、

```
wp core download --locale=ja
```

の ja を書き換えてください。(例えば --locale=en_US)

データベース情報を書き出すと、

- データベース名: wordpress
- ユーザー: root
- パスワード: なし
- ホスト: localhost
- プレフィックス: wp\_

この部分については、

```bash
sed -i '1s/^/<?php $_SERVER["HTTPS"]="on"; $_ENV["HTTPS"]="ON"; ?>\n/' wp-config.php
```

これは、Gitpod が内部で 8001 番ポートの「http」を利用しているのに、外側には 80 番の「https」であるかのようになっていて、WordPress の吐き出す HTML ファイルの css リンクが http のままになっていて、それが原因でブラウザが css ファイルが暗号化されていないことを理由にダウンロードを拒否してしまい、css の当たっていないおかしなレイアウトでページが表示されるのを防ぐためです。  
WordPress に HTTPS であることを教えています。

## 利用後の操作

閉じる場合は、左上のメニューから「gitpod: Stop Workspace」を選択。  
画面が「Stopping」に切り替わるので、「Go to Dashboard」で Gitpod のダッシュボードへ行くと、利用した Workspace がリスト表示されています。  
該当の Workspace にマウスカーソルを合わせると右端にメニューボタンが表示されますので、クリックして操作を選択してください。  
用済みならば Delete、間違って閉じてしまった場合は Open です。
