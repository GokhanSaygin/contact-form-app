# contact-form-app

# 📬 Serverless Contact Form App

A production-ready, fully serverless contact form application built on AWS — deployed and managed with **Terraform** and automated via a **Jenkins CI/CD pipeline**.

---

## 🏗️ Architecture

```
User → CloudFront (HTTPS) → S3 (HTML/CSS/JS)
                          → API Gateway → Lambda → DynamoDB

GitHub → Webhook → Jenkins (EC2) → S3 + Lambda + CloudFront
```

---

## ☁️ AWS Services Used

| Service | Purpose |
|---|---|
| **S3** | Hosts static frontend files |
| **CloudFront** | CDN — serves frontend over HTTPS globally |
| **API Gateway** | Exposes REST API endpoints |
| **Lambda** | Serverless backend functions (Python 3.12) |
| **DynamoDB** | NoSQL database for storing form submissions |
| **EC2** | Jenkins CI/CD server |
| **IAM** | Roles and permission policies |
| **CloudWatch** | Lambda logging and monitoring |

---

## 🚀 Features

- ✅ Fully serverless — no servers to manage
- ✅ HTTPS enforced via CloudFront
- ✅ Contact form with name, email, and message fields
- ✅ Admin panel to view all submitted messages
- ✅ Infrastructure as Code with Terraform
- ✅ Automated CI/CD pipeline with Jenkins
- ✅ Auto-deploy on every `git push` via GitHub Webhook
- ✅ CloudFront cache invalidation on each deploy
- ✅ IAM least-privilege security model

---

## 📁 Project Structure

```
contact-form-app/
├── frontend/
│   ├── index.html          # Contact form page
│   ├── admin.html          # Admin messages panel
│   ├── style.css           # Styling
│   └── app.js              # API integration
├── backend/
│   ├── submit_contact.py   # Lambda: save form submission
│   └── get_contacts.py     # Lambda: retrieve all submissions
├── infrastructure/
│   ├── main.tf             # Terraform provider config
│   ├── variables.tf        # Input variables
│   ├── outputs.tf          # Output values (URLs, bucket name)
│   ├── dynamodb.tf         # DynamoDB table
│   ├── lambda.tf           # Lambda functions + IAM role
│   ├── api_gateway.tf      # API Gateway + endpoints
│   ├── s3.tf               # S3 bucket + CloudFront OAC
│   ├── cloudfront.tf       # CloudFront distribution
│   └── ec2.tf              # Jenkins EC2 + IAM instance profile
├── Jenkinsfile             # CI/CD pipeline definition
├── .gitignore
└── README.md
```

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/submit` | Submit a new contact form |
| `GET` | `/contacts` | Retrieve all submissions |

### Example Request

```bash
curl -X POST https://<api-gateway-url>/dev/submit \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com","message":"Hello!"}'
```

### Example Response

```json
{ "message": "Form submitted successfully!" }
```

---

## ⚙️ CI/CD Pipeline (Jenkinsfile)

Every `git push` to `main` triggers the following pipeline automatically:

```
Stage 1: Checkout       → Pull latest code from GitHub
Stage 2: Test           → Python syntax validation
Stage 3: Deploy Frontend → Sync files to S3
Stage 4: Deploy Backend  → Update Lambda function code
Stage 5: Invalidate Cache → Clear CloudFront cache
```

---

## 🛠️ Infrastructure Setup

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.3.0
- [AWS CLI](https://aws.amazon.com/cli/) configured
- AWS IAM user with sufficient permissions

### Deploy Infrastructure

```bash
# 1. Clone the repo
git clone https://github.com/GokhanSaygin/contact-form-app.git
cd contact-form-app

# 2. Initialize Terraform
cd infrastructure
terraform init

# 3. Review the plan
terraform plan

# 4. Deploy
terraform apply
```

### Deploy Frontend

```bash
# From project root
aws s3 sync frontend/ s3://$(cd infrastructure && terraform output -raw s3_bucket_name)/
```

### Destroy Infrastructure

```bash
cd infrastructure
terraform destroy
```

---

## 🔐 Security Highlights

- S3 bucket is **not public** — only accessible via CloudFront OAC
- Lambda uses **least-privilege IAM Role** (only DynamoDB access it needs)
- Jenkins EC2 uses **IAM Instance Profile** — no hardcoded credentials
- All traffic is **HTTPS-only** (HTTP redirected)

---

## 📸 Screenshots

### Contact Form
> `https://<cloudfront-url>/index.html`

Users can submit their name, email, and message through a clean, responsive form.

### Admin Panel
> `https://<cloudfront-url>/admin.html`

All submitted messages are displayed in real time, fetched directly from DynamoDB.

---

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| Infrastructure | Terraform |
| Cloud | AWS |
| Backend | Python 3.12 |
| Frontend | HTML, CSS, Vanilla JS |
| CI/CD | Jenkins |
| Source Control | GitHub |

---

## 👤 Author

**Gokhan Saygin**  
Cloud Engineer (in progress) | AWS | Terraform | Jenkins  
[GitHub](https://github.com/GokhanSaygin)

---

## 📄 License

MIT License