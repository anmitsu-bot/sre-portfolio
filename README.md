# SRE Portfolio

FastAPIで作成したシンプルなWeb APIを題材に、Dockerによるコンテナ化、AWS上へのデプロイ、TerraformによるInfrastructure as Code、GitHub Actionsによるデプロイ自動化を実践するプロジェクトです。

アプリケーションを「動かす」だけではなく、インフラの再現性やデプロイ作業の自動化、監視、障害対応など、サービスを安定して運用するための仕組みを段階的に構築しています。

---

## アーキテクチャ

現在は以下の構成でAWS上にデプロイしています。

- FastAPI
- Docker
- Amazon ECR
- Amazon ECS / Fargate
- Amazon CloudWatch Logs
- Security Group
- IAM
- Terraform
- GitHub Actions
- GitHub Actions OIDC

現在のデプロイフローは以下の通りです。

```text
GitHub
   │
   │ git push
   ▼
GitHub Actions
   │
   ├─ OIDCによるAWS認証
   │
   ├─ Docker Image Build
   │
   └─ Amazon ECRへPush
   │
   ▼
Amazon ECS / Fargate
   │
   ▼
FastAPI Container
   │
   └─ Amazon CloudWatch Logs
```

AWSインフラはTerraformで管理しています。

```text
Terraform
   │
   ├─ Security Group
   ├─ IAM Role
   ├─ CloudWatch Log Group
   ├─ ECS Cluster
   ├─ ECS Task Definition
   └─ ECS Service
```

---

## 特徴

以下のAPIを実装しています。

### `GET /`

APIの動作確認用エンドポイントです。

```json
{
  "message": "SRE Portfolio API"
}
```

### `GET /health`

サービスの正常性を確認するためのヘルスチェック用エンドポイントです。

```json
{
  "status": "ok"
}
```

### `GET /slow`

意図的にレスポンスを遅延させるエンドポイントです。

今後、負荷試験や監視、障害検知の検証に利用する予定です。

---

## 技術スタック

### アプリケーション

- Python
- FastAPI
- Uvicorn

### コンテナ

- Docker

### AWS

- Amazon ECR
- Amazon ECS
- AWS Fargate
- Amazon CloudWatch Logs
- IAM
- Security Group

### Infrastructure as Code

- Terraform

### CI/CD

- GitHub Actions
- GitHub Actions OIDC

---

## ローカル環境立ち上げ

### 1. Clone

```bash
git clone https://github.com/anmitsu-bot/sre-portfolio.git
cd sre-portfolio
```

### 2. 仮想環境作成

```bash
python3 -m venv .venv
source .venv/bin/activate
```

### 3. 依存関係

```bash
pip install -r requirements.txt
```

### 4. FastAPI起動

```bash
uvicorn app.main:app --reload
```

Access:

```text
http://127.0.0.1:8000
```

API documentation:

```text
http://127.0.0.1:8000/docs
```

---

## Dockerで起動

Docker ImageをBuildします。

```bash
docker build -t sre-portfolio .
```

Containerを起動します。

```bash
docker run --name sre-api -p 8000:8000 sre-portfolio
```

Health Check:

```text
http://127.0.0.1:8000/health
```

---

## AWSへデプロイ

Docker ImageをAmazon ECRへPushし、Amazon ECS Fargate上でコンテナを実行しています。

```text
FastAPI
   ↓
Docker Image
   ↓
Amazon ECR
   ↓
Amazon ECS Fargate
   ↓
FastAPI Container
```

ECS TaskにはPublic IPを割り当て、Security GroupによってFastAPIが使用するTCP 8000番ポートへのアクセスを制御しています。

アプリケーションの実行ログはAmazon CloudWatch Logsから確認できます。

---

## TerraformによるInfrastructure as Code

AWS Management Consoleから手動で構築していたインフラをTerraformによってコード化しました。

現在、以下のリソースをTerraformで管理しています。

- Security Group
- ECS Cluster
- ECS Task Definition
- ECS Service
- IAM Role / IAM Policy
- CloudWatch Log Group
- GitHub Actions用OIDC Provider
- GitHub Actions用IAM Role

これにより、AWS Management Console上での手動操作だけに依存せず、インフラ構成をコードとして管理・再現できるようにしています。

```text
Terraform Code
      ↓
terraform plan
      ↓
terraform apply
      ↓
AWS Infrastructure
```

---

## GitHub Actionsによるデプロイ自動化

`main` ブランチへのPushをトリガーとして、GitHub ActionsからAWSへのデプロイを自動化しています。

```text
git push
   ↓
GitHub Actions
   ↓
Docker Image Build
   ↓
Amazon ECR Push
   ↓
ECS Task Definition更新
   ↓
ECS Service更新
   ↓
Deployment
```

Docker ImageにはGitのCommit SHAをタグとして付与し、ソースコードとデプロイされたImageの対応を確認できるようにしています。

また、GitHub ActionsからAWSへの認証にはOIDCを利用しています。

AWS Access Key / Secret Access Keyのような長期認証情報をGitHub側へ保存せず、一時的なAWS認証情報を利用してデプロイを行う構成にしています。

---

## TerraformとGitHub Actionsの役割分担

インフラ構成とアプリケーションのデプロイを分離しています。

```text
Terraform
   │
   ├─ ECS Cluster
   ├─ ECS Service
   ├─ IAM
   ├─ Security Group
   └─ CloudWatch

GitHub Actions
   │
   ├─ Docker Build
   ├─ ECR Push
   ├─ Task Definition Revision作成
   └─ ECS Deployment
```

ECS ServiceのTask Definition RevisionについてはGitHub Actions側で更新するため、Terraformでは変更を無視するように設定しています。

---

## 学んだこと

このプロジェクトを通じて、以下を実践しました。

- FastAPIを利用したWeb APIの構築
- Dockerによるアプリケーションのコンテナ化
- Docker ImageとContainerの関係
- Amazon ECRを利用したContainer Image管理
- Amazon ECS / Fargateによるコンテナ実行
- Security Groupによる通信制御
- Public IPとPortを利用した外部アクセス
- CloudWatch Logsを利用したアプリケーションログの確認
- IAM Role / PolicyによるAWS権限管理
- TerraformによるAWSインフラのコード化
- Terraform Stateによるインフラ管理
- GitHub Actionsを利用したデプロイ自動化
- GitHub Actions OIDCを利用したAWS認証
- Git CommitとDocker Imageを対応させたImage管理
- インフラ管理とアプリケーションデプロイの責務分離
- AWSリソースを利用しない際に停止するなど、クラウドコストを意識した運用

特に、最初はAWS Management Consoleから手動で構築・デプロイしていた環境を、

```text
手動構築
   ↓
TerraformによるIaC化
   ↓
GitHub Actionsによるデプロイ自動化
```

と段階的に改善しました。

---

## 今後の実装

今後は、構築・デプロイの自動化だけでなく、サービスの信頼性を実際に観測・改善する仕組みを追加する予定です。

### ネットワーク・公開構成の改善

- [ ] Application Load Balancerの導入
- [ ] ECS TaskをPrivate Subnetへ配置
- [ ] Public / Private Subnetを含むVPC構成のTerraform化
- [ ] Route Tableの設計
- [ ] HTTPS対応
- [ ] Route 53 / ACMの利用
- [ ] VPC Flow Logsによる通信確認

現在の、

```text
Internet
   ↓
Public IP :8000
   ↓
ECS Task
```

という構成から、

```text
Internet
   ↓
HTTPS :443
   ↓
Application Load Balancer
   ↓
Private Subnet
   ↓
ECS Fargate
```

のような構成への改善を予定しています。

### Monitoring / Reliability

- [ ] CloudWatch MetricsによるCPU・Memory等の監視
- [ ] CloudWatch Alarmによる異常検知
- [ ] 負荷試験
- [ ] レスポンスタイムの計測
- [ ] ECS Service Auto Scaling
- [ ] 障害発生時の原因調査
- [ ] 改善前後の性能比較
- [ ] SLI / SLOの設定
- [ ] 障害対応・改善内容の記録

最終的には、

```text
Code Push
   ↓
CI/CD
   ↓
Docker Build
   ↓
Amazon ECR
   ↓
Amazon ECS
   ↓
Monitoring
   ↓
Failure Detection
   ↓
Investigation
   ↓
Improvement
   ↓
Measurement
```

という一連の運用を構築し、サービスの信頼性と運用効率を継続的に改善できる環境を目標としています。

---

## 目的

SRE（Site Reliability Engineering）に興味を持ったことをきっかけに、アプリケーションを「作る」だけでなく、

- どのようにインフラを構築・再現するか
- どのようにデプロイ作業を自動化するか
- どのように安全にAWSへ認証するか
- どのようにサービスの状態を把握するか
- どのように手作業を減らすか
- 障害や負荷にどう対応するか
- 改善の効果をどのように測定するか

といった運用・信頼性の観点を実践的に学ぶために制作しています。

---

## デプロイ先のURL

```text
http://13.196.171.17:8000/
```

> ECS Taskの再起動・再デプロイによってPublic IPが変更される場合があります。  
> 今後、ALB・HTTPS・独自のエンドポイント導入によって改善予定です。
