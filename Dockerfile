# --- 1. ビルドステージ（Red Hat公式 OpenJDK 17 イメージ） ---
FROM registry.access.redhat.com/ubi9/openjdk-17:1.18 AS build

# 作業ディレクトリの設定（UBIイメージの標準的なパス）
WORKDIR /home/jboss/app

# ソースコードをコンテナ内にコピー（所有権をjbossユーザーに設定）
COPY . .

# パイプライン側でテストは通過済みのため、ここではテストをスキップして高速にJARを作成
RUN mvn clean package -DskipTests

# --- 2. 実行ステージ（Red Hat公式 軽量JRE 17 イメージ） ---
FROM registry.access.redhat.com/ubi9/openjdk-17-runtime:1.18

WORKDIR /home/jboss

# ビルドステージから生成されたJARファイルだけを抽出してコピー
COPY --from=build /home/jboss/app/target/*.jar ./app.jar

# アプリケーションのポート公開
EXPOSE 8080

# コンテナ起動時にJavaアプリケーションを実行
ENTRYPOINT ["java", "-jar", "./app.jar"]
