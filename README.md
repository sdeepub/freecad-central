### FreeCAD Central Infrastructure Engine

A centralized, cloud-native design workspace and automation pipeline. This project wraps a performance-isolated CAD compute engine inside a secure browser-accessible gateway (Apache Guacamole) and hooks it directly into a backend automation and asset lifecycle management ecosystem. 

### 🏗️ Architecture Layers

* **Layer 1: Gateway Panel** – Apache Guacamole (cad-gateway) running a web-native application stream client.
* **Layer 2: Compute Engine** – Linux Native FreeCAD App (cad-mockup-app) optimized for standalone workspace streaming via VNC.
* **Layer 3: Automation Core** – Node-RED Workflow Canvas (cad-approval-engine) watching the design pipeline filesystem.
* **Layer 4: PDM Hub & Asset Tracking** – Odoo Community Edition for Bill of Materials (BOM) registries and Snipe-IT for ITAM license tracking.

### 🚀 Easy Deployment Steps

### 1. Prerequisites

Ensure your local host machine has the standard container engine plugins installed: 

* Docker Engine (20.10+)
* Docker Compose V2

### 2. Project Setup

Clone this repository to your target workspace path and ensure proper file permissions are established for the shared data volumes: 

```bash

cd /path/to/your/project-folder/

# Make the startup initialization script executable
chmod +x config/cad-app/entrypoint-init.sh

# Open file access permissions for the shared drawing volume so containers can write files cleanly
sudo chmod -R 777 $(docker inspect --format '{{ .Mountpoint }}' project-folder_cad_drawings 2>/dev/null || echo "/var/lib/docker/volumes/project-folder_cad_drawings/_data")

```
Use code with caution.

### 3. Spin Up the Infrastructure Stack

Launch all services in detached background mode using a single command: 

```bash

docker compose up -d

```
Use code with caution.

### 4. Verify System Initialization

Check that all containers are up and running healthily: 

```bash

docker compose ps

```
Use code with caution.

### 🌐 Portal Reference Guide

Once fully initialized, all platforms are securely mapped to your local host loopback addresses: 

Platform 

Web Workspace Address 

Default Credentials / Purpose 

****Guacamole Gateway****
http://localhost:8080/guacamoleguacadmin / guacadmin
****Node-RED Dashboard****
http://localhost:1880Automation logic workflow editor
****Odoo PDM Database****
http://localhost:8069Product component & BOM registry
****Snipe-IT License ITAM****
http://localhost:8888Workstation node & seat tracking

### 🛠️ Guacamole Connection Parameters

To connect to the standalone CAD screen, navigate to **Settings -> Connections -> New Connection** inside Guacamole and input these parameters: 

* **Protocol:** VNC
* **Hostname:** cad-app
* **Port:** 5901
* **Password:** cadpass

### 🧹 Maintenance & Tear Down

To stop the background container runtimes without destroying your persistent data volumes, run: 

```bash

docker compose down

```
Use code with caution.

To perform a complete hard reset, wiping the container caches while safely retaining your design volume blocks, use: 

```bash

docker compose down --remove-orphans && docker compose up -d --force-recreate

```
Use code with caution.
