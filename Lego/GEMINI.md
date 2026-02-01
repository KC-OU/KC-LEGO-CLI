# GEMINI.md: Project Overview and Development Guide

This document provides a comprehensive overview of the KC LEGO Management System, its architecture, and development conventions to be used as a guide for an AI assistant.

## 1. Project Overview

### Purpose
This project is a comprehensive management system for personal and non-personal LEGO collections. It provides a terminal-based interface for users to track LEGO sets and parts, manage user accounts, and look up information from a large LEGO database.

### Technologies
-   **Frontend/UI:** The primary user interface is built using **Bash** scripts. It employs commands like `tput` for screen formatting and positioning to create an interactive menu-driven experience.
-   **Backend/Data Logic:** Core data management, user authentication, and business logic are implemented in **Python 3**.
-   **Data Querying:** **`jq`** is heavily used within the Bash scripts for parsing and searching large JSON database files.
-   **Data Storage:** All data, including user information, collections, and the lookup database, is stored in **JSON** files.

### Architecture
The system is composed of several distinct components that work together:

-   **Main Launcher (`Lego-Managment.sh`):** This is the central entry point of the application. It's a Bash script that displays the main menu and directs the user to different subsystems (Collection Management, Lookup). It also handles a one-time license agreement.

-   **LEGO Lookup System (`Lego-Lookup/`):** This subsystem is written in Bash and uses `jq` to perform powerful, multi-criteria searches on local JSON databases for LEGO sets (`legolookup.json`) and parts (`legolookup-part.json`).

-   **Collection Management Screens (`Lego-Magement-Screen/`):** This is the core of the application, containing Python scripts for managing different types of collections:
    -   `Personal-Collection/`: Manages the user's own LEGO sets and parts.
    -   `Non-Retired-Lego-Sets/`: Tracks currently available LEGO sets.
    -   `Retried-and-retiring-Lego-Sets/`: Tracks retired and soon-to-be-retired sets.
    Each of these directories contains a `main.sh` which is a Python script that handles user authentication, data manipulation (add, edit, search, remove), and user management for its specific domain.

-   **Data Files:**
    -   User and collection data for the management screens is stored in `~/.kc-sets/`, `~/.kc-nonretried-sets/`, etc.
    -   Large lookup databases are stored locally in the `Lego-Lookup/` directory.

## 2. Building and Running

### Prerequisites
The following tools must be installed on the system:
-   `bash`
-   `python3`
-   `jq`

These can typically be installed via a package manager (e.g., `sudo apt install jq python3 bash`).

### Setup and Execution
1.  **Set Permissions:** Before the first run, all shell scripts must be made executable.
    ```bash
    chmod +x Lego-Managment.sh
    chmod +x Lego-Lookup/*.sh
    find Lego-Magement-Screen -name "*.sh" -exec chmod +x {} \;
    ```
2.  **Run the Application:** Start the system by executing the main launcher script.
    ```bash
    ./Lego-Managment.sh
    ```
3.  **First Run:** On the first execution, the user will be prompted to accept an MIT license agreement.

### Testing
The project does not contain an automated test suite. Verification must be done by manually running the application and its various features.

## 3. Development Conventions

### Code Style
-   **Bash:** Scripts use functions to modularize code. A `center()` function is used to horizontally center text in the terminal for a consistent UI. Paths to other scripts and resources are hardcoded using the `$HOME` variable (e.g., `$HOME/Lego/...`).
-   **Python:** The Python scripts are self-contained and manage everything from user login to data persistence. A `Colors` class is used to style terminal output with ANSI color codes. Functions are well-defined for specific tasks (e.g., `load_users`, `add_set`, `hash_password`).

### Data Management
-   **User Data:** User credentials and roles are managed by the Python scripts and stored in `users.json` files within hidden directories in the user's home folder (e.g., `~/.kc-sets/users.json`). Passwords are salted and hashed using `hashlib.sha256`.
-   **Collection Data:** LEGO set and part information is stored in corresponding `sets.json` files in the same hidden directories.
-   **Database Lookups:** The `jq` command is the primary tool for querying the large, static JSON databases. The bash scripts dynamically construct complex `jq` filter strings based on user input.

### Key File Locations
-   **Main Script:** `/home/kcollins/Lego/Lego-Managment.sh`
-   **Lookup Scripts:** `/home/kcollins/Lego/Lego-Lookup/`
-   **Management Scripts (Python):** `/home/kcollins/Lego/Lego-Magement-Screen/`
-   **Personal Collection Data:** `~/.kc-sets/`
-   **License Agreement Flag:** `~/.lego_manager_license_agreed` (Note: The main script creates this in the project dir: `$HOME/Lego/.lego_manager_license_agreed`)
