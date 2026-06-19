# ArbGet — Crypto Arbitrage Monitoring Ecosystem

ArbGet is a high-performance full-stack application designed for real-time cryptocurrency arbitrage analysis. This repository serves as the central orchestration hub, connecting the backend engine, frontend dashboard, and infrastructure components using Docker.

## 🚀 Overview

The project monitors price spreads across multiple cryptocurrency exchanges simultaneously, providing traders with real-time data to identify arbitrage opportunities.

### Core Architecture:
*   **[crypto-arb-core](https://github.com/chernovprog/crypto-arb-core)**: Java 17 / Spring Boot 3 backend handling WebSocket connections to exchanges and business logic.
*   **[crypto-arb-dash](https://github.com/chernovprog/crypto-arb-dash)**: React / TypeScript frontend providing a reactive dashboard with Material UI and Zustand.
*   **Infrastructure**: Fully containerized environment using Docker and Docker Compose.

## 🛠 Tech Stack

*   **Backend:** Java 17, Spring Boot 3, Spring Data, Spring Security, PostgreSQL.
*   **Frontend:** React 19, Vite, TypeScript, Axios, Material UI, Zustand.
*   **DevOps:** Docker, Docker Compose, Kubernetes, CI/CD.

## 📂 Project Structure
```
crypto-arb/
├── backend/           # Git Submodule/Folder: Java Spring Boot application
├── frontend/          # Git Submodule/Folder: React TypeScript application
├── docker/            # Specific Docker configurations
├── .env.example       # Template for environment variables
└── docker-compose.yml # Main orchestration file
```

## ⚙️ Quick Start
Prerequisites
- Docker and Docker Compose installed.
- Java 21 (for local development).
- Node.js & NPM (for local frontend development).

## Running with Docker
1. Clone the main repository:
* git clone [https://github.com/chernovprog/crypto-arb.git](https://github.com/chernovprog/crypto-arb.git)
cd crypto-arb
2. Clone the sub-services:
* git clone [https://github.com/chernovprog/crypto-arb-core.git](https://github.com/chernovprog/crypto-arb-core.git) backend
* git clone [https://github.com/chernovprog/crypto-arb-dash.git](https://github.com/chernovprog/crypto-arb-dash.git) frontend
3. Launch the entire ecosystem:
* docker-compose up --build

## The application will be available at:
* http://localhost

## ⚠️ Prerequisite for local setup:
To make Ingress work in your local cluster (Docker Desktop / Minikube), you must have the NGINX Ingress Controller installed.
You can install it using the following command:
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

## 👤 Author
Andrii Chernov (Full Stack Developer & DevOps)
