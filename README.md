# 🎩 OAS + MySQL + phpMyAdmin + Grafana

This project sets up an IoT stack using Docker Compose, consisting of:

- **Open Automation Software (OAS)** + **OAS License Host**
- **MySQL 8.0**, with:
  - A user for OAS with permission to create and manage databases
  - A dedicated database and user for Grafana
- **Grafana Enterprise**, pre-configured to use MySQL as a data source
- **phpMyAdmin**, to view and manage MySQL database


## Setup


### Windows Users

This project works best on **Windows 10/11** using **WSL2 (Windows Subsystem for Linux 2)** with **Docker Desktop**.

| Requirement        | Instructions                                                               |
| ------------------ | -------------------------------------------------------------------------- |
| **Docker Desktop** | Download from [docker.com](https://www.docker.com/products/docker-desktop) |
| **WSL2 Backend**   | Follow [Install WSL](https://aka.ms/wslinstall)                            |
| **Linux Distro**   | Install *Ubuntu 22.04 LTS* from the Microsoft Store                        |
| **Install tools**  | Inside WSL terminal: `sudo apt update && sudo apt install gettext`         |
| **Configure OAS**  | Download from [OAS](https://openautomationsoftware.com/downloads/) and see note below.|

> Make sure your Docker Desktop uses the **WSL 2 based engine**, and WSL integration is enabled for your distro (under Docker settings → Resources → WSL Integration).

#### **NOTE:** Configure OAS

For the purposes of this deployment, you should not have OAS installed in Windows at the same time, because it will conflict with the port numbers. If you do have OAS installed already, you will need to stop all of the OAS services.

If you want to use the *Configure OAS* application, you can install OAS and choose a **Custom** installation during setup. You can disable all the features except the **Configure Application** feature. This way it will install the Configure OAS application, but not the OAS engine.


### Linux Users

Before running the project, make sure you have the following installed.

| Tool           | Version Suggestion       | Install Command (Ubuntu/Debian)          |
| -------------- | ------------------------ | ---------------------------------------- |
| Docker         | 20+                      | `sudo apt install docker.io`             |
| Docker Compose | v2+ (plugin)             | `sudo apt install docker-compose-plugin` |
| `envsubst`     | (from `gettext`)         | `sudo apt install gettext`               |
| Bash Shell     | (default on Linux/macOS) | ✅ Alread preinstalled                   |
| **Configure OAS**  | V20+ | Download the `OAS Configuration Client` from [openautomationsoftware.com](https://openautomationsoftware.com/downloads/) |

## Cloning the Repository

   In a Windows WSL terminal or a Linux Ubuntu terminal run the following commands in your home directory to download the project files.

   ```bash
   git clone https://github.com/Cloudea-Solutions/oas-mysql-grafana.git
   cd oas-mysql-grafana
   ```

## Configure Credentials

The first step is to create a new `.env` file in the folder where the credentials (username and password) details will be stored.

Create a new `.env` file in the project root directory with the following content:

```env
MYSQL_ROOT_PASSWORD=<mysql_root_password>

# OAS DB user
OAS_DB_USER=oas
OAS_DB_PASSWORD=<oas_db_password>

# Grafana DB and user
GRAFANA_DB=grafana
GRAFANA_DB_USER=grafana_user
GRAFANA_DB_PASSWORD=<grafana_db_password>

# Grafana admin login
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=<grafana_admin_password>

# OAS admin login
OAS_ADMIN_USER=admin
OAS_ADMIN_PASSWORD=<oas_admin_password>
```

Replace all of the <> items with your own passwords in the `.env` file.

| Parameter | Description |
| --------- | ----------- |
| <mysql_root_password> | The root password for the MySQL database |
| <oas_db_password> | The password that OAS data logging configurations will use |
| <grafana_db_password> | The password that Grafana will use to access the MySQL database |
| <grafana_admin_password> | The admin login password for Grafana dashboard |
| <oas_admin_password> | The OAS admin password to login with Configure OAS |


## Deployment

The following steps can be done in the WSL Ubuntu terminal if you are using a Windows operating system or in a standard Ubuntu terminal if you are using a Ubuntu Linux operating system.

1. **Run the OAS License Host installation script**

   The OAS License Host is needed to license OAS running in Docker containers.

   ```bash
   ./install_oas_license_host.sh
   ```

   After the installation is completed you should be able to check on the service status.

   ```
   sudo systemctl status oas-license-host
   ```

   This should output something like this:

   ```
   ● oas-license-host.service - Open Automation Software License Host
     Loaded: loaded (/etc/systemd/system/oas-license-host.service; enabled; preset: enabled)
     Active: active (running) since Wed 2025-08-06 16:01:06 AWST; 6s ago
   Main PID: 55675 (OASLicenseHost)
      Tasks: 15 (limit: 14999)
     Memory: 24.7M ()
     CGroup: /system.slice/oas-license-host.service
             └─55675 /opt/oas/oas-linux-license-host/OASLicenseHost
   ```

   You can now connect to the license host using *Configure OAS* and access the Configure > Container License screen. This will connect to the license host on port `58729`.

   To activate a DEMO license using the OAS [License Key Generator](https://openautomationsoftware.com/manual-license-key-generator/) website. You can find more information on [How to activate a license](https://openautomationsoftware.com/knowledge-base/activate-license-with-license-code-manually/).

2. **Run the startup script**

   ```bash
   chmod +x start.sh
   ./start.sh
   ```

This will:

- Generate the necessary `init-users.sql` for MySQL
- Generate the OAS admin credentials in `admin-create.expect`
- Generate the Grafana data source config
- Start the stack using Docker Compose
- Set the initial OAS admin credentials

To generate the configuration files from the templates (`.tpl` files), the startup script uses a utility called `envsubst` to do the variable substitutions from the environment files.


## 🚀 Access the Services

| Service    | URL                                               | Credentials                      |
| ---------- | ------------------------------------------------- | -------------------------------- |
| Grafana    | [http://localhost:3000](http://localhost:3000)    | `admin / admin` (or from `.env`) |
| OAS        | Use the Configure OAS application				     | Use credentials from `.env`      |
| MySQL      | `localhost:3306`                                  | Use credentials from `.env`      |
| PhpMyAdmin | [http://localhost:8080](http://localhost:8080)    | Logged in automatically          |


## 📁 File Structure

```
project-root/
├── grafana/
│   └── provisioning/
│       └── datasources/
│           └── mysql.yml          # Generated Grafana config
├── mysql/
│   └── init/
│       └── init-users.sql         # Generated MySQL init script
├── scripts/
│   └── admin-create.expect        # Generated OAS Admin Create script
├── templates/
│   ├── admin-create.expect.tpl    # Template for OAS user config
│   ├── init-users.sql.tpl         # Template for MySQL user config
│   └── mysql.yml.tpl              # Template for Grafana provisioning
├── .env                           # Environment variables
├── .gitignore
├── docker-compose.yml             # Docker Compose setup
├── install_oas_license_host.yml   # OAS License Host installation script
├── README.md                      # This readme tile
└── start.sh                       # Automated setup script
```


## 🔐 Security Notes

- `.env` is **excluded from version control** via `.gitignore`
- Never commit real production secrets
- In production, consider using **Docker Secrets**, **Vault**, or other secret management


## 🪩 Cleanup

To stop and remove all containers:

```bash
docker-compose down
```

Volumes will not be deleted which means your Grafana, MySQL and OAS data will remain

To remove volumes and clean up everything:

```bash
docker-compose down -v
```

