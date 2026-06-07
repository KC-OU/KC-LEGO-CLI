# Lego Manager

A unified, high-performance Go-based web application for managing your Lego collection.

## Features
- **Unified Management:** Manage Sets, Parts, and standalone Minifigures in one place.
- **Visual Interface:** Modern web UI with image support (powered by Rebrickable).
- **Automated Metadata:** Fetch set details and images automatically using the Rebrickable API.
- **Wishlist:** Plan your future purchases with a dedicated priority-based wishlist.
- **SQLite Backend:** High efficiency and data integrity compared to raw JSON files.

## Getting Started

### 1. Requirements
- Go 1.25+ (installed during migration)
- Rebrickable API Key (optional but recommended for images)

### 2. Setup
The migration has already been performed. Your existing sets from `kc-sets/sets.json` have been imported into the new database located at `~/.lego-manager.db`.

### 3. Running the Server
To start the application, run:
```bash
cd lego-manager
export REBRICKABLE_API_KEY="your_api_key_here"
./bin/lego-manager
```
Then open your browser to `http://localhost:8080`.

### 4. Default Credentials
- **Username:** admin
- **Password:** 12345

## Project Structure
- `cmd/server`: The main web application server.
- `cmd/migrate`: Utility for migrating from old JSON formats.
- `internal/db`: Database schema and initialization logic.
- `internal/api`: Rebrickable API client.
- `internal/services`: Business logic for the collection.
- `web/templates`: HTML templates using HTMX and TailwindCSS.
