# KC LEGO Management System

A comprehensive bash and Python-based application for managing personal LEGO collections, including sets and parts tracking, lookup functionality, and user management.

![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)

## 🎯 Quick Start

```bash
# Run the main application
./Lego-Managment.sh

# Or run individual components
./Lego-Lookup/lookup-set.sh    # LEGO set lookup
./Lego-Lookup/lookup-part.sh   # LEGO part lookup
```

## 📋 Table of Contents

- [Overview](#overview)
- [System Components](#system-components)
- [Default Credentials](#default-credentials)
- [Installation & Setup](#installation--setup)
- [User Guide](#user-guide)
- [Configuration File for Menu Customization](#configuration-file-for-menu-customization)- [Development](#development)
- [Data Structures](#data-structures)
- [Troubleshooting](#troubleshooting)

## 🔍 Overview

The KC LEGO Management System provides:

- **Personal Collection Management** - Track your owned LEGO sets and parts
- **LEGO Database Lookup** - Search comprehensive LEGO set and part databases
- **Non-Personal Collection Tracking** - Manage wish lists and track retired sets
- **User Management System** - Multi-user support with role-based access
- **Interactive Menu Interface** - Easy-to-navigate terminal-based UI
- **Presentation Mode** - A simplified view for clients or colleagues

## 🏗️ System Components

### 1. Main Launcher
**File:** `Lego-Managment.sh`

The central entry point featuring:
- MIT license agreement (required on first run)
- System selection menu (Management vs Lookup)
- Centralized navigation hub

```
==========================================
      KC LEGO MANAGEMENT SYSTEM        
      -------------------------        
  This bash shell helps you with your   
     Personal Lego Collection and      
     non-personal Lego collection      
==========================================
```

### 2. Personal Collection Management

#### Sets Management
**File:** `Lego-Magement-Screen/Personal-Collection/kc-sets/main.sh`
- **Language:** Python 3
- **Features:** Add, edit, search, and manage your LEGO sets
- **Data Storage:** JSON format with comprehensive metadata
- **Theme Support:** Hierarchical theme categorization with 200+ themes

#### Parts Management  
**File:** `Lego-Magement-Screen/Personal-Collection/kc-parts/main.sh`
- **Language:** Python 3
- **Features:** Track individual LEGO parts and quantities
- **Categories:** Organized by type (Bricks, Technic, Minifigures, etc.)
- **Colors:** Support for 150+ LEGO colors including special finishes

### 3. LEGO Lookup System

#### Set Lookup
**File:** `Lego-Lookup/lookup-set.sh`
- **Language:** Bash with jq JSON processing
- **Database:** `legolookup.json` (3.6MB reference data)
- **Search By:** Set ID, name, theme, year, piece count, cost, retirement status
- **Features:** Multi-criteria search, pagination, detailed set information

#### Part Lookup
**File:** `Lego-Lookup/lookup-part.sh`
- **Language:** Bash with jq JSON processing  
- **Database:** `legolookup-part.json` (9MB reference data)
- **Search By:** Part number, name, category, color
- **Features:** Comprehensive part database lookup

### 4. Non-Personal Collection Management

#### Non-Retired Sets
**File:** `Lego-Magement-Screen/Non-Retired-Lego-Sets/main.sh`
- **Language:** Python 3
- **Purpose:** Track current/available LEGO sets
- **User System:** Full user management with roles

#### Retired/Retiring Sets
**File:** `Lego-Magement-Screen/Retried-and-retiring-Lego-Sets/main.sh`
- **Language:** Python 3
- **Purpose:** Track discontinued LEGO sets
- **Features:** Retirement date tracking, pricing history

## 🔐 Default Credentials

### Primary Admin Account
- **Username:** `admin`
- **Password:** `12345` (must be changed on first login)
- **Role:** Administrator
- **User ID:** Auto-generated 4-7 digits

### User Creation
New users are automatically created with:
- **Default Password:** `12345`
- **Username:** Generated from first/last name (e.g., `jsmith`)
- **User ID:** Random 4-7 digit number
- **Status:** Active, password change required

### Password Policy
- Default password (`12345`) must be changed on first login
- No specific complexity requirements
- Passwords are SHA-256 hashed
- Admin can reset any user's password

## 🔧 Installation & Setup

### Prerequisites
```bash
# Required packages
sudo apt install jq python3 bash

# Verify installations
jq --version
python3 --version
bash --version
```

### Setup Steps
1. **Clone or download** the repository
2. **Make scripts executable:**
   ```bash
   chmod +x Lego-Managment.sh
   chmod +x Lego-Lookup/*.sh
   find Lego-Magement-Screen -name "*.sh" -exec chmod +x {} \;
   ```
3. **Run the main application:**
   ```bash
   ./Lego-Managment.sh
   ```
4. **Accept the license agreement** (creates `.lego_manager_license_agreed`)

### Data Storage Locations
- **License Cache:** `~/.lego_manager_license_agreed`
- **User Data:** `~/.kc-nonretried-sets/users.json`
- **Collection Data:** Local JSON files in project directory
- **Reference Databases:** `Lego-Lookup/*.json`

## 📖 User Guide

### First Time Setup
1. Run `./Lego-Managment.sh`
2. Accept MIT license agreement
3. Choose "Lego Management System" → "Personal Collection" 
4. Login with `admin` / `12345`
5. Change default password when prompted

### Managing Your Collection
1. **Adding Sets:**
   - Navigate to Personal Collection → Manage Lego Sets
   - Select "Add New Set"
   - Enter set details (ID, name, theme, year, pieces)

2. **Searching Sets:**
   - Use lookup tools for comprehensive LEGO database search
   - Filter by multiple criteria simultaneously
   - View detailed set information and pricing

3. **User Management (Admin Only):**
   - Create new users with auto-generated credentials
   - Assign roles (admin/user)
   - Enable/disable accounts
   - Reset passwords

### Presentation Mode
For a simplified experience when demonstrating the application, you can switch to Presentation Mode.

1.  **Enable Presentation Mode:**
    -   From the main launcher menu, select "Settings".
    -   Choose "Switch to Presentation Mode".

2.  **What it Does:**
    -   **Simplified Main Menu:** The main launcher will only show "Lego Lookup", "Settings", and "Exit".
    -   **Focused Management System:** The Lego Management System will only show "Personal Collection", hiding the "Non-Retired" and "Retired" set menus.

3.  **Switching Back:**
    -   To restore all options, go to "Settings" and select "Switch to Full Mode".

### Configuration File for Menu Customization
The main menu and sub-menus can be customized by editing the `.kc-lego-cli.conf` file located in the project's root directory (`/home/kcollins/Lego/.kc-lego-cli.conf`). This file allows you to hide or show menu items by changing `[ ]` to `[x]` for hidden, or `[x]` to `[ ]` for visible.

Example:
```
# -- LEGO SYSTEM LAUNCHER --
[ ] Lego Management System
[ ] Lego Lookup
[x] View License
[x] Settings
```
In this example, "View License" and "Settings" are hidden.
Changes to this file are immediately reflected the next time the main launcher is run.



## 📊 Data Structures

### Collection Set Format
```json
{
  "set_id": "71788",
  "set_name": "Lloyd's Ninja Street Bike",
  "set_theme": "Ninjago Core", 
  "set_year": "2023",
  "instruction_book_number": "6449669",
  "instruction_book_count": 1,
  "set_qty": 1,
  "parts_qty": 56,
  "part_out": false,
  "created_at": "2025-07-09T07:23:32.365745",
  "updated_at": "2025-07-09T07:24:19.613674"
}
```

### Theme Categories (Examples)
- **Star Wars:** 25+ subcategories (Episodes, series, spin-offs)
- **Harry Potter:** Book-based organization (Chamber of Secrets, etc.)
- **Ninjago:** 25+ seasonal categories
- **Technic:** Vehicle types, complexity levels
- **BrickHeads:** Character collections

### Part Color Categories
- **Solid Colors:** 50+ standard LEGO colors
- **Transparent:** All transparent variants
- **Metallic:** Chrome, Pearl, Satin finishes
- **Special:** Glow-in-dark, Glitter, Speckle effects
- **Modulex:** Complete Modulex color range

## 🛠️ Development

### Technology Stack
- **Frontend:** Bash terminal interface with `tput` formatting
- **Backend:** Python 3 for data management
- **Database:** JSON file storage
- **Search:** jq for JSON querying
- **License:** MIT

### Project Structure
```
Lego/
├── Lego-Managment.sh                 # Main launcher
├── Lego-Lookup/                      # Database lookup tools
│   ├── lookup-set.sh                 # Set search (bash/jq)
│   ├── lookup-part.sh                # Part search (bash/jq)
│   ├── legolookup.json               # Set database (3.6MB)
│   └── legolookup-part.json          # Part database (9MB)
├── Lego-Magement-Screen/             # Collection management
│   ├── Personal-Collection/
│   │   ├── kc-sets/main.sh           # Personal sets (Python)
│   │   └── kc-parts/main.sh          # Personal parts (Python)
│   ├── Non-Retired-Lego-Sets/main.sh # Available sets (Python)
│   └── Retried-and-retiring-Lego-Sets/main.sh # Discontinued sets
├── LICENSE                           # MIT license
└── README.md                         # This file
```

### Adding New Features
1. **For UI Changes:** Modify bash scripts using `center()` function for consistent formatting
2. **For Data Features:** Extend Python scripts with JSON storage
3. **For Search Features:** Enhance jq queries in lookup scripts
4. **For Themes:** Update THEMES arrays in both documentation and code

## 🔍 Troubleshooting

### Common Issues

**Script Permission Denied:**
```bash
chmod +x Lego-Managment.sh
chmod +x Lego-Lookup/*.sh
```

**jq Command Not Found:**
```bash
sudo apt install jq  # Ubuntu/Debian
brew install jq      # macOS
```

**Python Script Errors:**
```bash
python3 --version    # Verify Python 3 is installed
```

**License Loop Issue:**
```bash
rm ~/.lego_manager_license_agreed  # Reset license agreement
```

**User Login Issues:**
- Default credentials: `admin` / `12345`
- Check user account isn't disabled
- Verify users.json file exists and is readable

### Known Issues
- Main script shebang line had syntax errors (fixed in this version)
- Some Python scripts may have mixed shebang/extension issues
- Refresh functionality in search may not work as expected

## 📝 Notes

- **Backup:** The original notes file has been saved as `README-BACKUP-20250910.md`
- **License:** This project is MIT licensed (Copyright 2025 Kieran Collins)
- **Status:** Active development - some features may be in progress
- **Data Safety:** Always backup your collection JSON files before major updates

## 🤝 Contributing

This is a personal project but feedback and suggestions are welcome. Key areas for improvement:
- Interactive theme/category selection interface
- Enhanced search pagination and refresh functionality
- Improved error handling and user feedback
- Database synchronization features

---

*For more technical details, see `CLAUDE.md` for development guidance.*
