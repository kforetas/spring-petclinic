# --- 1. ビルドステージ（OpenJDK 17 + Maven が入ったRed Hat公式イメージ） ---
FROM registry.access.redhat.com/ubi8/openjdk-17:1.18 AS build

# UBIのopenjdkイメージはデフォルトで '/home/jboss' が作業ディレクトリになります
WORKDIR /home/jboss/app

# ソースコードをコンテナ内にコピー（権限をjbossユーザーに合わせる）
COPY --chown=jboss:jboss . .

# テストを実行しつつ、JARファイルをビルド
RUN mvn clean package

# --- 2. 実行ステージ（軽量な Java 17 実行専用のRed Hat公式イメージ） ---
FROM registry.access.redhat.com/ubi8/openjdk-17-runtime:1.18

WORKDIR /home/jboss

# ビルドステージから作成されたJARファイルだけをコピー
COPY --from=build /home/jboss/app/target/*.jar ./app.jar

EXPOSE 8080

# アプリケーションの起動コマンド
ENTRYPOINT ["java", "-jar", "./app.jar"]
