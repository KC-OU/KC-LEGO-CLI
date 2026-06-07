package db

import (
	"database/sql"
	"log"

	_ "github.com/mattn/go-sqlite3"
	"golang.org/x/crypto/bcrypt"
)

func InitDB(filepath string) (*sql.DB, error) {
	db, err := sql.Open("sqlite3", filepath)
	if err != nil {
		return nil, err
	}
	if err = db.Ping(); err != nil {
		return nil, err
	}

	if err := createTables(db); err != nil {
		return nil, err
	}

	// Migrations for existing tables
	columnMigrations := []struct {
		table  string
		column string
		Type   string
	}{
		{"users", "user_id", "TEXT"},
		{"sets", "price", "REAL"},
		{"sets", "cost", "REAL"},
		{"sets", "status", "TEXT"},
		{"sets", "condition", "TEXT"},
		{"sets", "remarks", "TEXT"},
		{"sets", "has_instructions", "BOOLEAN DEFAULT FALSE"},
		{"sets", "box_art_url", "TEXT"},
		{"sets", "instructions_url", "TEXT"},
		{"sets", "lego_link", "TEXT"},
		{"sets", "ebay_link", "TEXT"},
		{"sets", "amazon_link", "TEXT"},
		{"parts", "condition", "TEXT"},
		{"parts", "price", "REAL"},
		{"parts", "cost", "REAL"},
		{"parts", "remarks", "TEXT"},
		{"deals", "country", "TEXT"},
	}

	for _, m := range columnMigrations {
		// Ignore error if column already exists
		_, err := db.Exec("ALTER TABLE " + m.table + " ADD COLUMN " + m.column + " " + m.Type)
		if err != nil {
			// Only log if it's NOT a "duplicate column" error
			if err.Error() != "duplicate column name: "+m.column {
				log.Printf("Migration notice (table %s, col %s): %v", m.table, m.column, err)
			}
		}
	}

	if err := ensureAdmin(db); err != nil {
		log.Printf("Warning: Failed to ensure admin user: %v", err)
	}

	return db, nil
}

func ensureAdmin(db *sql.DB) error {
	var count int
	err := db.QueryRow("SELECT COUNT(*) FROM users").Scan(&count)
	if err != nil {
		return err
	}

	if count == 0 {
		hash, err := bcrypt.GenerateFromPassword([]byte("12345"), 14)
		if err != nil {
			return err
		}
		_, err = db.Exec(`INSERT INTO users (username, user_id, password_hash, first_name, last_name, role, password_changed) 
						VALUES (?, ?, ?, ?, ?, ?, ?)`, 
						"admin", "1000000", string(hash), "Admin", "User", "admin", false)
		if err != nil {
			return err
		}
		log.Println("Created default admin user (admin/12345)")
	}
	return nil
}

func createTables(db *sql.DB) error {
	queries := []string{
		`CREATE TABLE IF NOT EXISTS users (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			username TEXT UNIQUE NOT NULL,
			user_id TEXT UNIQUE,
			password_hash TEXT NOT NULL,
			first_name TEXT,
			last_name TEXT,
			role TEXT DEFAULT 'user',
			disabled BOOLEAN DEFAULT FALSE,
			password_changed BOOLEAN DEFAULT FALSE
		);`,
		`CREATE TABLE IF NOT EXISTS sets (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			set_num TEXT UNIQUE NOT NULL,
			name TEXT NOT NULL,
			year INTEGER,
			theme TEXT,
			parts_count INTEGER,
			quantity INTEGER DEFAULT 0,
			image_url TEXT,
			price REAL,
			cost REAL,
			status TEXT,
			condition TEXT,
			remarks TEXT,
			instruction_book_number TEXT,
			instruction_book_count INTEGER DEFAULT 0,
			has_instructions BOOLEAN DEFAULT FALSE,
			part_out BOOLEAN DEFAULT FALSE,
			box_art_url TEXT,
			instructions_url TEXT,
			lego_link TEXT,
			ebay_link TEXT,
			amazon_link TEXT,
			created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
			updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
		);`,
		`CREATE TABLE IF NOT EXISTS parts (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			part_num TEXT UNIQUE NOT NULL,
			name TEXT NOT NULL,
			category TEXT,
			color TEXT,
			quantity INTEGER DEFAULT 0,
			image_url TEXT,
			long_part_id TEXT,
			condition TEXT,
			price REAL,
			cost REAL,
			remarks TEXT,
			created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
			updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
		);`,
		`CREATE TABLE IF NOT EXISTS set_parts (
			set_id INTEGER,
			part_id INTEGER,
			quantity INTEGER DEFAULT 1,
			PRIMARY KEY (set_id, part_id),
			FOREIGN KEY (set_id) REFERENCES sets(id),
			FOREIGN KEY (part_id) REFERENCES parts(id)
		);`,
		`CREATE TABLE IF NOT EXISTS minifigures (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			fig_num TEXT UNIQUE NOT NULL,
			name TEXT NOT NULL,
			quantity INTEGER DEFAULT 0,
			image_url TEXT,
			created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
			updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
		);`,
		`CREATE TABLE IF NOT EXISTS wishlist (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			item_type TEXT NOT NULL, -- 'set', 'part', 'minifig'
			ref_num TEXT NOT NULL,
			name TEXT,
			priority INTEGER DEFAULT 1,
			created_at DATETIME DEFAULT CURRENT_TIMESTAMP
		);`,
		`CREATE TABLE IF NOT EXISTS set_minifigures (
			set_id INTEGER,
			minifig_id INTEGER,
			quantity INTEGER DEFAULT 1,
			PRIMARY KEY (set_id, minifig_id),
			FOREIGN KEY (set_id) REFERENCES sets(id),
			FOREIGN KEY (minifig_id) REFERENCES minifigures(id)
		);`,
		`CREATE TABLE IF NOT EXISTS deals (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT NOT NULL,
			set_num TEXT,
			store TEXT,
			price REAL,
			discount INTEGER,
			image_url TEXT,
			link TEXT,
			country TEXT,
			created_at DATETIME DEFAULT CURRENT_TIMESTAMP
		);`,
		`CREATE TABLE IF NOT EXISTS settings (
			key TEXT PRIMARY KEY,
			value TEXT
		);`,
		`CREATE TABLE IF NOT EXISTS user_set_progress (
			user_id INTEGER,
			set_id INTEGER,
			part_id INTEGER,
			found_quantity INTEGER DEFAULT 0,
			PRIMARY KEY (user_id, set_id, part_id),
			FOREIGN KEY (user_id) REFERENCES users(id),
			FOREIGN KEY (set_id) REFERENCES sets(id),
			FOREIGN KEY (part_id) REFERENCES parts(id)
		);`,
	}

	for _, query := range queries {
		if _, err := db.Exec(query); err != nil {
			return err
		}
	}

	// Add CAD file columns
	db.Exec("ALTER TABLE sets ADD COLUMN ldraw_file TEXT")
	db.Exec("ALTER TABLE parts ADD COLUMN cad_file TEXT")

	return nil
}
