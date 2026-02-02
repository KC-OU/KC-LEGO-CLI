# KC LEGO Management System

![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![jq](https://img.shields.io/badge/jq-C7254E?style=for-the-badge&logo=jq&logoColor=white)

A comprehensive, terminal-based application for managing personal and non-personal LEGO collections.

---

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Application Tour](#application-tour)
- [User Account Management](#user-account-management)
- [Technologies](#technologies)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup and Execution](#setup-and-execution)
- [License](#license)

---

## Overview

This project is a powerful, menu-driven system for LEGO enthusiasts to manage their collections directly from the terminal. Built with a combination of Bash for the user interface and Python for the backend logic, it provides a robust set of tools for tracking sets, managing user access, and querying a large, local LEGO database.

## Key Features

-   **LEGO Set and Part Lookup:**
    -   Perform powerful, multi-criteria searches on local JSON databases for LEGO sets and parts using `jq`.
    -   Search by set number, name, theme, year, and more.

-   **Comprehensive Collection Management:**
    -   Manage multiple distinct collections:
        -   **Personal Collection:** Track the sets and parts you own.
        -   **Non-Retired LEGO Sets:** Keep a database of currently available sets.
        -   **Retired & Retiring Sets:** Monitor sets that are no longer in production.
    -   Perform CRUD operations (Create, Read, Update, Delete) on your collection data.

-   **Secure User Management:**
    -   Each collection module has its own secure user authentication system.
    -   **Admin Role:** Admins can manage the user base for their respective module, including creating, deleting, and resetting user accounts.
    -   **Standard User Role:** Standard users can manage collection data.

-   **Interactive Terminal UI:**
    -   A dynamic and responsive menu-driven interface created with Bash scripting (`tput`).
    -   Colored output for better readability and user experience.

# ## Application Tour

# Here is a glimpse into the KC LEGO Management System.

# **Main Menu**
# *(A brief description of the main entry point of the application.)*
# > ![Main Menu](Lego/screenshots/01-main-menu.png)

# * *LEGO Lookup System**
# *(Showcasing the powerful search capabilities for finding sets and parts.)*
# > ![LEGO Lookup](Lego/screenshots/02-lego-lookup.png)

# **Collection Management**
# *(The main dashboard for one of the collection modules after logging in.)*
# > ![Collection Management](Lego/screenshots/03-collection-management.png)

# **User Management (Admin View)**
# *(The menu available to administrators for managing users.)*
# > ![User Management](Lego/screenshots/04-user-management.png)

# ***Note:** To add screenshots, place your images in the `Lego/screenshots/` directory and uncomment the Markdown image tags above.*

## User Account Management

Each collection management module (`Personal-Collection`, `Non-Retired-Lego-Sets`, etc.) has its own independent user database.

### First-Time Login

When you run a management module for the first time, it will create a default administrator account.

-   **Username:** `admin`
-   **Password:** `12345`

### Forced Password Change

For security, the system will **require you to change the default password** upon your first successful login. You will be prompted to enter and confirm a new password. The new password cannot be the default one.

### How to Change Your Password

1.  Log into the desired collection module.
2.  If it is your first time, you will be automatically prompted to change your password.
3.  If you are an administrator and want to change another user's password (or your own), navigate to the **User Management** menu and select **Reset User Password**. This will reset the user's password to the default (`12345`), and they will be forced to change it on their next login.

## Technologies

-   **Frontend/UI:** **Bash** with `tput` for screen formatting.
-   **Backend/Data Logic:** **Python 3** for data management, user authentication, and business logic.
-   **Data Querying:** **`jq`** is used extensively for parsing and searching the large JSON database files.
-   **Data Storage:** **JSON** is used for all user data, collections, and the lookup databases.

## Project Structure

```
.
├── Lego/
│   ├── Lego-Managment.sh       # Main application launcher
│   ├── Lego-Lookup/            # Scripts and data for the lookup system
│   │   ├── lookup-set.sh
│   │   ├── legolookup.json       # Main set database
│   │   └── ...
│   ├── Lego-Magement-Screen/   # Python-based collection management modules
│   │   ├── Personal-Collection/
│   │   ├── Non-Retired-Lego-Sets/
│   │   └── Retried-and-retiring-Lego-Sets/
│   ├── screenshots/            # Directory for application screenshots
│   └── ...
└── README.md                   # This file
```

## Prerequisites

The following tools must be installed on your system:
-   `bash`
-   `python3`
-   `jq`

You can typically install them using a package manager:
```sh
sudo apt install jq python3 bash
```

## Setup and Execution

1.  **Set Permissions:** Before the first run, all shell scripts must be made executable.

    ```bash
    chmod +x Lego/Lego-Managment.sh
    chmod +x Lego/Lego-Lookup/*.sh
    find Lego/Lego-Magement-Screen -name "*.sh" -exec chmod +x {} \;
    ```

2.  **Run the Application:** Start the system by executing the main launcher script from the project root.

    ```bash
    ./Lego/Lego-Managment.sh
    ```
    On the first run, you will be prompted to accept an MIT license agreement.

## License

This project is licensed under the MIT License. See the `Ligo/LICENSE` file for details.
