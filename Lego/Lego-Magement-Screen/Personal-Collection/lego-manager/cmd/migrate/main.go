package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"

	"lego-manager/internal/auth"
	"lego-manager/internal/db"
	"lego-manager/internal/models"
	"lego-manager/internal/services"
	_ "github.com/mattn/go-sqlite3"
)

type OldSet struct {
	SetID                 string `json:"set_id"`
	SetName               string `json:"set_name"`
	SetTheme              string `json:"set_theme"`
	SetYear               string `json:"set_year"`
	InstructionBookNumber string `json:"instruction_book_number"`
	InstructionBookCount  int    `json:"instruction_book_count"`
	SetQty                int    `json:"set_qty"`
	PartsQty              int    `json:"parts_qty"`
	PartOut               bool   `json:"part_out"`
}

func main() {
	dbPath := filepath.Join(os.Getenv("HOME"), ".lego-manager.db")
	database, err := db.InitDB(dbPath)
	if err != nil {
		log.Fatal(err)
	}
	defer database.Close()

	collectionSvc := services.NewCollectionService(database)

	// Migrate Sets
	migrateSets(collectionSvc)

	// Create default admin if none exists
	createDefaultAdmin(database)

	fmt.Println("Migration completed successfully!")
}

func migrateSets(svc *services.CollectionService) {
	setsFile := "../kc-sets/sets.json"
	data, err := ioutil.ReadFile(setsFile)
	if err != nil {
		fmt.Printf("Warning: Could not read %s: %v\n", setsFile, err)
		return
	}

	var oldSets []OldSet
	if err := json.Unmarshal(data, &oldSets); err != nil {
		fmt.Printf("Error unmarshaling %s: %v\n", setsFile, err)
		return
	}

	for _, os := range oldSets {
		var year int
		fmt.Sscanf(os.SetYear, "%d", &year)

		newSet := &models.Set{
			SetNum:                os.SetID,
			Name:                  os.SetName,
			Year:                  year,
			Theme:                 os.SetTheme,
			PartsCount:            os.PartsQty,
			Quantity:              os.SetQty,
			InstructionBookNumber: os.InstructionBookNumber,
			InstructionBookCount:  os.InstructionBookCount,
			PartOut:               os.PartOut,
		}

		if err := svc.AddSet(newSet); err != nil {
			fmt.Printf("Skipping duplicate or error set %s: %v\n", os.SetID, err)
		} else {
			fmt.Printf("Migrated set: %s\n", os.SetID)
		}
	}
}

func createDefaultAdmin(database *sql.DB) {
	var count int
	database.QueryRow("SELECT COUNT(*) FROM users").Scan(&count)
	if count == 0 {
		hash, _ := auth.HashPassword("12345")
		_, err := database.Exec(`INSERT INTO users (username, password_hash, first_name, last_name, role, password_changed) 
								VALUES (?, ?, ?, ?, ?, ?)`, 
								"admin", hash, "Admin", "User", "admin", false)
		if err != nil {
			log.Printf("Error creating default admin: %v", err)
		} else {
			fmt.Println("Created default admin user (admin/12345)")
		}
	}
}
