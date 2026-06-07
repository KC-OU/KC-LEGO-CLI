package main

import (
	"database/sql"
	"encoding/csv"
	"encoding/gob"
	"encoding/json"
	"encoding/xml"
	"fmt"
	"html/template"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"lego-manager/internal/api"
	"lego-manager/internal/auth"
	"lego-manager/internal/db"
	"lego-manager/internal/models"
	"lego-manager/internal/services"

	"github.com/gorilla/sessions"
	_ "github.com/mattn/go-sqlite3"
)

var (
	collectionSvc *services.CollectionService
	userSvc       *services.UserService
	rebrickable   *api.RebrickableClient
	store         = sessions.NewCookieStore([]byte("lego-manager-secret")) // Use a proper secret in production
	database      *sql.DB
	templateCache = make(map[string]*template.Template)
)

func main() {
	gob.Register(int64(0))
	dbPath := filepath.Join(os.Getenv("HOME"), ".lego-manager.db")
	var err error
	database, err = db.InitDB(dbPath)
	if err != nil {
		log.Fatal(err)
	}
	defer database.Close()

	collectionSvc = services.NewCollectionService(database)
	userSvc = services.NewUserService(database)

	apiKey := userSvc.GetSetting("rebrickable_key")
	if apiKey == "" {
		apiKey = os.Getenv("REBRICKABLE_API_KEY")
	}
	if apiKey == "" {
		log.Println("Warning: REBRICKABLE_API_KEY not set in environment or database")
	}
	rebrickable = api.NewRebrickableClient(apiKey)

	// Auth routes
	http.HandleFunc("/login", loginHandler)
	http.HandleFunc("/logout", logoutHandler)
	http.HandleFunc("/change-password", changePasswordHandler)

	// Protected routes
	protected := func(h http.Handler) http.Handler {
		return authMiddleware(passcodeMiddleware(h))
	}

	http.Handle("/", protected(http.HandlerFunc(indexHandler)))
	http.Handle("/verify-passcode", authMiddleware(http.HandlerFunc(verifyPasscodeHandler)))
	
	http.Handle("/sets", protected(http.HandlerFunc(setsHandler)))
	http.Handle("/sets/new", protected(restrictGuestMiddleware(http.HandlerFunc(addSetFormHandler))))
	http.Handle("/sets/add", protected(restrictGuestMiddleware(http.HandlerFunc(addSetActionHandler))))
	http.Handle("/sets/delete", protected(restrictGuestMiddleware(http.HandlerFunc(deleteSetHandler))))
	http.Handle("/sets/view", protected(http.HandlerFunc(viewSetHandler)))
	http.Handle("/sets/sync-parts", protected(restrictGuestMiddleware(http.HandlerFunc(syncPartsHandler))))
	http.Handle("/sets/sync-minifigs", protected(restrictGuestMiddleware(http.HandlerFunc(syncMinifigsHandler))))
	http.Handle("/sets/sync-parts/remove", protected(restrictGuestMiddleware(http.HandlerFunc(removePartFromSetHandler))))
	http.Handle("/sets/update-image", protected(restrictGuestMiddleware(http.HandlerFunc(updateSetImageHandler))))
	http.Handle("/sets/edit", protected(restrictGuestMiddleware(http.HandlerFunc(editSetFormHandler))))
	http.Handle("/sets/update", protected(restrictGuestMiddleware(http.HandlerFunc(updateSetActionHandler))))
	http.Handle("/sets/bulk-delete", protected(restrictGuestMiddleware(http.HandlerFunc(bulkDeleteSetsHandler))))
	http.Handle("/sets/export", protected(restrictGuestMiddleware(http.HandlerFunc(exportSetsHandler))))
	http.Handle("/sets/export/csv", protected(restrictGuestMiddleware(http.HandlerFunc(exportSetsCSVHandler))))
	http.Handle("/sets/import", protected(restrictGuestMiddleware(http.HandlerFunc(importSetsHandler))))
	http.Handle("/sets/import/csv", protected(restrictGuestMiddleware(http.HandlerFunc(importSetsHandler))))
	http.Handle("/sets/progress", protected(http.HandlerFunc(updateProgressHandler)))

	http.Handle("/parts", protected(http.HandlerFunc(partsHandler)))
	http.Handle("/parts/new", protected(restrictGuestMiddleware(http.HandlerFunc(addPartFormHandler))))
	http.Handle("/parts/add", protected(restrictGuestMiddleware(http.HandlerFunc(addPartActionHandler))))
	http.Handle("/parts/delete", protected(restrictGuestMiddleware(http.HandlerFunc(deletePartHandler))))
	http.Handle("/parts/view", protected(http.HandlerFunc(viewPartHandler)))
	http.Handle("/parts/edit", protected(restrictGuestMiddleware(http.HandlerFunc(editPartFormHandler))))
	http.Handle("/parts/update", protected(restrictGuestMiddleware(http.HandlerFunc(updatePartActionHandler))))
	http.Handle("/parts/bulk-delete", protected(restrictGuestMiddleware(http.HandlerFunc(bulkDeletePartsHandler))))
	http.Handle("/parts/export", protected(restrictGuestMiddleware(http.HandlerFunc(exportPartsHandler))))
	http.Handle("/parts/export/csv", protected(restrictGuestMiddleware(http.HandlerFunc(exportPartsCSVHandler))))
	http.Handle("/parts/import", protected(restrictGuestMiddleware(http.HandlerFunc(importPartsHandler))))
	http.Handle("/parts/import/csv", protected(restrictGuestMiddleware(http.HandlerFunc(importPartsHandler))))

	// User management (Admin only)
	http.Handle("/users", adminMiddleware(authMiddleware(http.HandlerFunc(usersHandler))))
	http.Handle("/users/create", adminMiddleware(authMiddleware(http.HandlerFunc(createUserHandler))))
	http.Handle("/users/toggle", adminMiddleware(authMiddleware(http.HandlerFunc(toggleUserHandler))))
	http.Handle("/users/role", adminMiddleware(authMiddleware(http.HandlerFunc(changeUserRoleHandler))))
	http.Handle("/users/user_id", adminMiddleware(authMiddleware(http.HandlerFunc(changeUserIDHandler))))
	http.Handle("/users/reset", adminMiddleware(authMiddleware(http.HandlerFunc(resetPasswordHandler))))
	http.Handle("/users/delete", adminMiddleware(authMiddleware(http.HandlerFunc(deleteUserHandler))))

	http.Handle("/minifigures", protected(http.HandlerFunc(minifiguresHandler)))
	http.Handle("/minifigures/new", protected(restrictGuestMiddleware(http.HandlerFunc(addMinifigureFormHandler))))
	http.Handle("/minifigures/add", protected(restrictGuestMiddleware(http.HandlerFunc(addMinifigureActionHandler))))
	http.Handle("/minifigures/delete", protected(restrictGuestMiddleware(http.HandlerFunc(deleteMinifigureHandler))))
	http.Handle("/minifigures/bulk-delete", protected(restrictGuestMiddleware(http.HandlerFunc(bulkDeleteMinifiguresHandler))))
	http.Handle("/minifigures/export", protected(restrictGuestMiddleware(http.HandlerFunc(exportMinifiguresHandler))))
	http.Handle("/minifigures/export/csv", protected(restrictGuestMiddleware(http.HandlerFunc(exportMinifiguresCSVHandler))))
	http.Handle("/minifigures/import", protected(restrictGuestMiddleware(http.HandlerFunc(importMinifiguresHandler))))
	http.Handle("/minifigures/import/csv", protected(restrictGuestMiddleware(http.HandlerFunc(importMinifiguresHandler))))

	http.Handle("/wishlist", protected(http.HandlerFunc(wishlistHandler)))
	http.Handle("/wishlist/new", protected(restrictGuestMiddleware(http.HandlerFunc(addWishlistFormHandler))))
	http.Handle("/wishlist/add", protected(restrictGuestMiddleware(http.HandlerFunc(addWishlistActionHandler))))
	http.Handle("/wishlist/delete", protected(restrictGuestMiddleware(http.HandlerFunc(deleteWishlistHandler))))

	http.Handle("/export", protected(restrictGuestMiddleware(http.HandlerFunc(exportHandler))))
	http.Handle("/upload", protected(restrictGuestMiddleware(http.HandlerFunc(uploadHandler))))
	http.Handle("/download-template", protected(restrictGuestMiddleware(http.HandlerFunc(downloadCSVTemplateHandler))))
	http.Handle("/uploads/", http.StripPrefix("/uploads/", http.FileServer(http.Dir("uploads"))))

	http.Handle("/settings", protected(restrictGuestMiddleware(http.HandlerFunc(settingsHandler))))
	http.Handle("/settings/save", protected(restrictGuestMiddleware(http.HandlerFunc(saveSettingsHandler))))
	http.Handle("/set-currency", protected(http.HandlerFunc(setCurrencyHandler)))
	http.Handle("/deals", protected(http.HandlerFunc(dealsHandler)))
	http.Handle("/deals/add", protected(restrictGuestMiddleware(http.HandlerFunc(addDealHandler))))
	http.Handle("/deals/delete", protected(restrictGuestMiddleware(http.HandlerFunc(deleteDealHandler))))
	http.Handle("/deals/export", protected(restrictGuestMiddleware(http.HandlerFunc(exportDealsHandler))))
	http.Handle("/deals/import", protected(restrictGuestMiddleware(http.HandlerFunc(importDealsHandler))))

	log.Println("Server starting on :8080...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func verifyPasscodeHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/", http.StatusSeeOther)
		return
	}

	code := r.FormValue("passcode")
	actual := userSvc.GetSetting("system_passcode")

	if code == actual {
		session, _ := store.Get(r, "lego-manager-session")
		session.Values["passcode_verified"] = true
		session.Save(r, w)
		http.Redirect(w, r, "/", http.StatusSeeOther)
	} else {
		renderTemplate(w, r, "passcode.html", map[string]interface{}{"Error": "Invalid Passcode"})
	}
}

func settingsHandler(w http.ResponseWriter, r *http.Request) {
	data := map[string]interface{}{
		"RebrickableKey": userSvc.GetSetting("rebrickable_key"),
		"BrickLinkKey":   userSvc.GetSetting("bricklink_key"),
		"BrickOwlKey":    userSvc.GetSetting("brickowl_key"),
		"SystemPasscode": userSvc.GetSetting("system_passcode"),
	}
	renderTemplate(w, r, "settings.html", data)
}

func setCurrencyHandler(w http.ResponseWriter, r *http.Request) {
	currency := r.URL.Query().Get("c")
	if currency != "USD" && currency != "GBP" {
		currency = "USD"
	}
	session, _ := store.Get(r, "lego-manager-session")
	session.Values["currency"] = currency
	session.Save(r, w)

	referer := r.Header.Get("Referer")
	if referer == "" {
		referer = "/"
	}
	http.Redirect(w, r, referer, http.StatusSeeOther)
}

func saveSettingsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/settings", http.StatusSeeOther)
		return
	}
	userSvc.SaveSetting("rebrickable_key", r.FormValue("rebrickable_key"))
	userSvc.SaveSetting("bricklink_key", r.FormValue("bricklink_key"))
	userSvc.SaveSetting("brickowl_key", r.FormValue("brickowl_key"))
	userSvc.SaveSetting("system_passcode", r.FormValue("system_passcode"))
	
	// Dynamically update rebrickable client if key changed
	newKey := r.FormValue("rebrickable_key")
	if newKey != "" {
		rebrickable.APIKey = newKey
	}

	http.Redirect(w, r, "/settings", http.StatusSeeOther)
}

func dealsHandler(w http.ResponseWriter, r *http.Request) {
	opt := services.FilterOptions{
		Search:    r.URL.Query().Get("q"),
		SortBy:    r.URL.Query().Get("sort"),
		SortOrder: r.URL.Query().Get("order"),
		Country:   r.URL.Query().Get("country"),
	}
	if opt.SortOrder == "" {
		opt.SortOrder = "DESC"
	}

	deals, _ := collectionSvc.ListDeals(opt)

	renderTemplate(w, r, "deals.html", map[string]interface{}{
		"Deals":  deals,
		"Filter": opt,
	})
}

func exportSetsHandler(w http.ResponseWriter, r *http.Request) {
	format := r.URL.Query().Get("format")
	sets, err := collectionSvc.ListSets(services.FilterOptions{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	switch format {
	case "json":
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Content-Disposition", "attachment;filename=lego_sets.json")
		encoder := json.NewEncoder(w)
		encoder.SetIndent("", "  ")
		encoder.Encode(sets)
	case "xml":
		w.Header().Set("Content-Type", "application/xml")
		w.Header().Set("Content-Disposition", "attachment;filename=lego_sets.xml")
		w.Write([]byte(xml.Header))
		type Sets struct {
			XMLName xml.Name     `xml:"sets"`
			Items   []models.Set `xml:"set"`
		}
		encoder := xml.NewEncoder(w)
		encoder.Indent("", "  ")
		encoder.Encode(Sets{Items: sets})
	default: // csv
		exportSetsCSVHandler(w, r)
	}
}

func exportSetsCSVHandler(w http.ResponseWriter, r *http.Request) {
	sets, err := collectionSvc.ListSets(services.FilterOptions{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/csv")
	w.Header().Set("Content-Disposition", "attachment;filename=lego_sets.csv")

	writer := csv.NewWriter(w)
	defer writer.Flush()

	writer.Write([]string{"SetNum", "Name", "Year", "Theme", "PartsCount", "Quantity", "Price", "Cost", "Status", "Condition"})

	for _, s := range sets {
		writer.Write([]string{
			s.SetNum,
			s.Name,
			strconv.Itoa(s.Year),
			s.Theme,
			strconv.Itoa(s.PartsCount),
			strconv.Itoa(s.Quantity),
			strconv.FormatFloat(s.Price, 'f', 2, 64),
			strconv.FormatFloat(s.Cost, 'f', 2, 64),
			s.Status,
			s.Condition,
		})
	}
}

func importSetsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/sets", http.StatusSeeOther)
		return
	}

	file, header, err := r.FormFile("sets_csv")
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	defer file.Close()

	if strings.HasSuffix(header.Filename, ".json") {
		var sets []models.Set
		if err := json.NewDecoder(file).Decode(&sets); err != nil {
			http.Error(w, "Invalid JSON: "+err.Error(), http.StatusBadRequest)
			return
		}
		for _, s := range sets {
			collectionSvc.AddSet(&s)
		}
	} else if strings.HasSuffix(header.Filename, ".xml") {
		type Sets struct {
			Items []models.Set `xml:"set"`
		}
		var sets Sets
		if err := xml.NewDecoder(file).Decode(&sets); err != nil {
			http.Error(w, "Invalid XML: "+err.Error(), http.StatusBadRequest)
			return
		}
		for _, s := range sets.Items {
			collectionSvc.AddSet(&s)
		}
	} else {
		reader := csv.NewReader(file)
		_, _ = reader.Read() // Skip header
		for {
			record, err := reader.Read()
			if err == io.EOF {
				break
			}
			if err != nil || len(record) < 8 {
				continue
			}
			year, _ := strconv.Atoi(record[2])
			partsCount, _ := strconv.Atoi(record[4])
			qty, _ := strconv.Atoi(record[5])
			price, _ := strconv.ParseFloat(record[6], 64)
			cost, _ := strconv.ParseFloat(record[7], 64)
			collectionSvc.AddSet(&models.Set{
				SetNum:     record[0],
				Name:       record[1],
				Year:       year,
				Theme:      record[3],
				PartsCount: partsCount,
				Quantity:   qty,
				Price:      price,
				Cost:       cost,
				Status:     record[8],
				Condition:  record[9],
			})
		}
	}
	http.Redirect(w, r, "/sets", http.StatusSeeOther)
}

func downloadCSVTemplateHandler(w http.ResponseWriter, r *http.Request) {
	entity := r.URL.Query().Get("type")
	filename := "template_" + entity + ".csv"
	w.Header().Set("Content-Type", "text/csv")
	w.Header().Set("Content-Disposition", "attachment;filename="+filename)

	writer := csv.NewWriter(w)
	defer writer.Flush()

	switch entity {
	case "sets":
		writer.Write([]string{"SetNum", "Name", "Year", "Theme", "PartsCount", "Quantity", "Price", "Cost", "Status", "Condition"})
	case "parts":
		writer.Write([]string{"PartNum", "Name", "Category", "Color", "Quantity", "Price", "Cost", "Condition"})
	case "minifigures":
		writer.Write([]string{"FigNum", "Name", "Quantity"})
	case "deals":
		writer.Write([]string{"Name", "SetNum", "Store", "Price", "Discount", "ImageURL", "URL", "Country"})
	default:
		http.Error(w, "Invalid entity type", http.StatusBadRequest)
	}
}

func exportPartsHandler(w http.ResponseWriter, r *http.Request) {
	format := r.URL.Query().Get("format")
	parts, err := collectionSvc.ListParts(services.FilterOptions{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	switch format {
	case "json":
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Content-Disposition", "attachment;filename=lego_parts.json")
		encoder := json.NewEncoder(w)
		encoder.SetIndent("", "  ")
		encoder.Encode(parts)
	case "xml":
		w.Header().Set("Content-Type", "application/xml")
		w.Header().Set("Content-Disposition", "attachment;filename=lego_parts.xml")
		w.Write([]byte(xml.Header))
		type Parts struct {
			XMLName xml.Name      `xml:"parts"`
			Items   []models.Part `xml:"part"`
		}
		encoder := xml.NewEncoder(w)
		encoder.Indent("", "  ")
		encoder.Encode(Parts{Items: parts})
	default: // csv
		exportPartsCSVHandler(w, r)
	}
}

func exportPartsCSVHandler(w http.ResponseWriter, r *http.Request) {
	parts, err := collectionSvc.ListParts(services.FilterOptions{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/csv")
	w.Header().Set("Content-Disposition", "attachment;filename=lego_parts.csv")

	writer := csv.NewWriter(w)
	defer writer.Flush()

	writer.Write([]string{"PartNum", "Name", "Category", "Color", "Quantity", "Price", "Cost", "Condition"})

	for _, p := range parts {
		writer.Write([]string{
			p.PartNum,
			p.Name,
			p.Category,
			p.Color,
			strconv.Itoa(p.Quantity),
			strconv.FormatFloat(p.Price, 'f', 2, 64),
			strconv.FormatFloat(p.Cost, 'f', 2, 64),
			p.Condition,
		})
	}
}

func importPartsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/parts", http.StatusSeeOther)
		return
	}

	file, header, err := r.FormFile("parts_csv")
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	defer file.Close()

	if strings.HasSuffix(header.Filename, ".json") {
		var parts []models.Part
		if err := json.NewDecoder(file).Decode(&parts); err != nil {
			http.Error(w, "Invalid JSON: "+err.Error(), http.StatusBadRequest)
			return
		}
		for _, p := range parts {
			collectionSvc.AddPart(&p)
		}
	} else if strings.HasSuffix(header.Filename, ".xml") {
		type Parts struct {
			Items []models.Part `xml:"part"`
		}
		var parts Parts
		if err := xml.NewDecoder(file).Decode(&parts); err != nil {
			http.Error(w, "Invalid XML: "+err.Error(), http.StatusBadRequest)
			return
		}
		for _, p := range parts.Items {
			collectionSvc.AddPart(&p)
		}
	} else {
		reader := csv.NewReader(file)
		_, _ = reader.Read() // Skip header
		for {
			record, err := reader.Read()
			if err == io.EOF {
				break
			}
			if err != nil || len(record) < 8 {
				continue
			}
			qty, _ := strconv.Atoi(record[4])
			price, _ := strconv.ParseFloat(record[5], 64)
			cost, _ := strconv.ParseFloat(record[6], 64)
			collectionSvc.AddPart(&models.Part{
				PartNum:   record[0],
				Name:      record[1],
				Category:  record[2],
				Color:     record[3],
				Quantity:  qty,
				Price:     price,
				Cost:      cost,
				Condition: record[7],
			})
		}
	}
	http.Redirect(w, r, "/parts", http.StatusSeeOther)
}

func exportMinifiguresHandler(w http.ResponseWriter, r *http.Request) {
	format := r.URL.Query().Get("format")
	figs, err := collectionSvc.ListMinifigures(services.FilterOptions{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	switch format {
	case "json":
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Content-Disposition", "attachment;filename=lego_minifigures.json")
		encoder := json.NewEncoder(w)
		encoder.SetIndent("", "  ")
		encoder.Encode(figs)
	case "xml":
		w.Header().Set("Content-Type", "application/xml")
		w.Header().Set("Content-Disposition", "attachment;filename=lego_minifigures.xml")
		w.Write([]byte(xml.Header))
		type Minifigures struct {
			XMLName xml.Name            `xml:"minifigures"`
			Items   []models.Minifigure `xml:"minifigure"`
		}
		encoder := xml.NewEncoder(w)
		encoder.Indent("", "  ")
		encoder.Encode(Minifigures{Items: figs})
	default: // csv
		exportMinifiguresCSVHandler(w, r)
	}
}

func exportMinifiguresCSVHandler(w http.ResponseWriter, r *http.Request) {
	figs, err := collectionSvc.ListMinifigures(services.FilterOptions{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/csv")
	w.Header().Set("Content-Disposition", "attachment;filename=lego_minifigures.csv")

	writer := csv.NewWriter(w)
	defer writer.Flush()

	writer.Write([]string{"FigNum", "Name", "Quantity"})

	for _, f := range figs {
		writer.Write([]string{
			f.FigNum,
			f.Name,
			strconv.Itoa(f.Quantity),
		})
	}
}

func importMinifiguresHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/minifigures", http.StatusSeeOther)
		return
	}

	file, header, err := r.FormFile("figs_csv")
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	defer file.Close()

	if strings.HasSuffix(header.Filename, ".json") {
		var figs []models.Minifigure
		if err := json.NewDecoder(file).Decode(&figs); err != nil {
			http.Error(w, "Invalid JSON: "+err.Error(), http.StatusBadRequest)
			return
		}
		for _, f := range figs {
			collectionSvc.AddMinifigure(&f)
		}
	} else if strings.HasSuffix(header.Filename, ".xml") {
		type Minifigures struct {
			Items []models.Minifigure `xml:"minifigure"`
		}
		var figs Minifigures
		if err := xml.NewDecoder(file).Decode(&figs); err != nil {
			http.Error(w, "Invalid XML: "+err.Error(), http.StatusBadRequest)
			return
		}
		for _, f := range figs.Items {
			collectionSvc.AddMinifigure(&f)
		}
	} else {
		reader := csv.NewReader(file)
		_, _ = reader.Read() // Skip header
		for {
			record, err := reader.Read()
			if err == io.EOF {
				break
			}
			if err != nil || len(record) < 3 {
				continue
			}
			qty, _ := strconv.Atoi(record[2])
			collectionSvc.AddMinifigure(&models.Minifigure{
				FigNum:   record[0],
				Name:     record[1],
				Quantity: qty,
			})
		}
	}
	http.Redirect(w, r, "/minifigures", http.StatusSeeOther)
}

func exportDealsHandler(w http.ResponseWriter, r *http.Request) {
	deals, err := collectionSvc.ListDeals(services.FilterOptions{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/csv")
	w.Header().Set("Content-Disposition", "attachment;filename=lego_deals.csv")

	writer := csv.NewWriter(w)
	defer writer.Flush()

	// Header
	writer.Write([]string{"Name", "SetNum", "Store", "Price", "Discount", "ImageURL", "URL", "Country"})

	for _, d := range deals {
		writer.Write([]string{
			d.Name,
			d.SetNum,
			d.Store,
			strconv.FormatFloat(d.Price, 'f', 2, 64),
			strconv.Itoa(d.Discount),
			d.ImageURL,
			d.URL,
			d.Country,
		})
	}
}

func importDealsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/settings", http.StatusSeeOther)
		return
	}

	file, _, err := r.FormFile("deals_file")
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	defer file.Close()

	reader := csv.NewReader(file)
	// Skip header
	_, err = reader.Read()
	if err != nil {
		http.Error(w, "Invalid CSV file", http.StatusBadRequest)
		return
	}

	var deals []models.LegoDeal
	for {
		record, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			break
		}

		if len(record) < 8 {
			continue
		}

		price, _ := strconv.ParseFloat(record[3], 64)
		discount, _ := strconv.Atoi(record[4])

		deals = append(deals, models.LegoDeal{
			Name:     record[0],
			SetNum:   record[1],
			Store:    record[2],
			Price:    price,
			Discount: discount,
			ImageURL: record[5],
			URL:      record[6],
			Country:  record[7],
		})
	}

	if len(deals) > 0 {
		collectionSvc.AddDeals(deals)
	}

	http.Redirect(w, r, "/deals", http.StatusSeeOther)
}

func addDealHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/", http.StatusSeeOther)
		return
	}
	price, _ := strconv.ParseFloat(r.FormValue("price"), 64)
	discount, _ := strconv.Atoi(r.FormValue("discount"))
	
	deal := &models.LegoDeal{
		Name:     r.FormValue("name"),
		SetNum:   r.FormValue("set_num"),
		Store:    r.FormValue("store"),
		Price:    price,
		Discount: discount,
		ImageURL: r.FormValue("image_url"),
		URL:      r.FormValue("link"),
		Country:  r.FormValue("country"),
	}
	
	collectionSvc.AddDeal(deal)
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

func deleteDealHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/", http.StatusSeeOther)
		return
	}
	id, _ := strconv.Atoi(r.FormValue("id"))
	collectionSvc.DeleteDeal(id)
	
	ref := r.Header.Get("Referer")
	if ref != "" {
		http.Redirect(w, r, ref, http.StatusSeeOther)
	} else {
		http.Redirect(w, r, "/deals", http.StatusSeeOther)
	}
}

func authMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		session, _ := store.Get(r, "lego-manager-session")
		authVal, ok := session.Values["authenticated"].(bool)
		if !ok || !authVal {
			if r.Header.Get("HX-Request") == "true" {
				w.Header().Set("HX-Redirect", "/login")
				w.WriteHeader(http.StatusUnauthorized)
			} else {
				http.Redirect(w, r, "/login", http.StatusSeeOther)
			}
			return
		}

		// Session Timeout Check (30 minutes)
		username, _ := session.Values["username"].(string)
		if username != "Guest" {
			lastActivity, ok := session.Values["lastActivity"].(int64)
			if ok {
				if time.Now().Unix()-lastActivity > 1800 {
					session.Values["authenticated"] = false
					session.Save(r, w)
					if r.Header.Get("HX-Request") == "true" {
						w.Header().Set("HX-Redirect", "/login?error=Session+expired")
						w.WriteHeader(http.StatusUnauthorized)
					} else {
						http.Redirect(w, r, "/login?error=Session+expired", http.StatusSeeOther)
					}
					return
				}
			}
			session.Values["lastActivity"] = time.Now().Unix()
		}

		// Refresh Role and PasswordChanged from DB if not in session or to ensure latest
		if session.Values["role"] == nil && session.Values["username"] != "Guest" {
			var role string
			var pwChanged bool
			username, _ := session.Values["username"].(string)
			err := database.QueryRow("SELECT role, password_changed FROM users WHERE username = ?", username).Scan(&role, &pwChanged)
			if err == nil {
				session.Values["role"] = role
				session.Values["passwordChanged"] = pwChanged
			}
		}
		session.Save(r, w)

		// Force password change if not changed yet
		pwChanged, _ := session.Values["passwordChanged"].(bool)
		if !pwChanged && r.URL.Path != "/change-password" && r.URL.Path != "/logout" {
			http.Redirect(w, r, "/change-password", http.StatusSeeOther)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func adminMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		session, _ := store.Get(r, "lego-manager-session")
		role, _ := session.Values["role"].(string)
		username, _ := session.Values["username"].(string)
		if role != "admin" || username == "Guest" {
			http.Error(w, "Forbidden: Admin access required", http.StatusForbidden)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func restrictGuestMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		session, _ := store.Get(r, "lego-manager-session")
		username, _ := session.Values["username"].(string)
		if username == "Guest" {
			http.Redirect(w, r, "/login?error=Guest+cannot+access+this+feature", http.StatusSeeOther)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func passcodeMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		passcode := userSvc.GetSetting("system_passcode")
		if passcode == "" {
			next.ServeHTTP(w, r)
			return
		}

		session, _ := store.Get(r, "lego-manager-session")
		passed, _ := session.Values["passcode_verified"].(bool)
		
		if passed || r.URL.Path == "/verify-passcode" {
			next.ServeHTTP(w, r)
			return
		}

		// Redirect to passcode entry page
		renderTemplate(w, r, "passcode.html", nil)
	})
}

func renderTemplate(w http.ResponseWriter, r *http.Request, name string, data interface{}) {
	session, _ := store.Get(r, "lego-manager-session")
	
	td := make(map[string]interface{})
	if data != nil {
		if m, ok := data.(map[string]interface{}); ok {
			for k, v := range m {
				td[k] = v
			}
		} else {
			td["Items"] = data
		}
	}
	
	td["Username"] = session.Values["username"]
	td["Role"] = session.Values["role"]
	td["IsAuthenticated"] = session.Values["authenticated"]
	
	currency := "USD"
	if c, ok := session.Values["currency"].(string); ok {
		currency = c
	}
	td["Currency"] = currency

	// Get or create template
	t, ok := templateCache[name]
	if !ok {
		var err error
		t = template.New(name).Funcs(template.FuncMap{
			"formatCurrency": func(amount float64, curr string) string {
				if curr == "GBP" {
					return fmt.Sprintf("£%.2f", amount)
				}
				return fmt.Sprintf("$%.2f", amount)
			},
			"sub": func(a, b int) int {
				return a - b
			},
		})
		t, err = t.ParseFiles("web/templates/layout.html", "web/templates/"+name)
		if err != nil {
			log.Printf("Template parse error: %v", err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		templateCache[name] = t
	}
	
	if err := t.ExecuteTemplate(w, name, td); err != nil {
		log.Printf("Template execution error: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		errStr := r.URL.Query().Get("error")
		if r.URL.Query().Get("guest") == "true" {
			session, _ := store.Get(r, "lego-manager-session")
			session.Values["authenticated"] = true
			session.Values["userID"] = 0
			session.Values["username"] = "Guest"
			session.Values["role"] = "user"
			session.Values["passwordChanged"] = true
			session.Save(r, w)
			http.Redirect(w, r, "/", http.StatusSeeOther)
			return
		}
		renderTemplate(w, r, "login.html", map[string]interface{}{"Error": errStr})
		return
	}

	username := r.FormValue("username")
	password := r.FormValue("password")

	user, err := auth.Login(database, username, password)
	if err != nil {
		renderTemplate(w, r, "login.html", map[string]interface{}{"Error": err.Error()})
		return
	}

	session, _ := store.Get(r, "lego-manager-session")
	session.Values["authenticated"] = true
	session.Values["userID"] = user.ID
	session.Values["username"] = user.Username
	session.Values["role"] = user.Role
	session.Values["passwordChanged"] = user.PasswordChanged
	session.Values["lastActivity"] = time.Now().Unix()
	session.Save(r, w)

	http.Redirect(w, r, "/", http.StatusSeeOther)
}

func logoutHandler(w http.ResponseWriter, r *http.Request) {
	session, _ := store.Get(r, "lego-manager-session")
	session.Values["authenticated"] = false
	session.Values["userID"] = nil
	session.Values["username"] = nil
	session.Values["passcode_verified"] = false
	session.Options.MaxAge = -1
	session.Save(r, w)
	http.Redirect(w, r, "/login", http.StatusSeeOther)
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	sets, _ := collectionSvc.ListSets(services.FilterOptions{})
	parts, _ := collectionSvc.ListParts(services.FilterOptions{})
	figs, _ := collectionSvc.ListMinifigures(services.FilterOptions{})

	totalSets := len(sets)
	totalParts := 0
	totalValue := 0.0
	for _, p := range parts {
		totalParts += p.Quantity
		totalValue += p.Price * float64(p.Quantity)
	}
	totalFigs := 0
	for _, f := range figs {
		totalFigs += f.Quantity
	}
	for _, s := range sets {
		totalValue += s.Price * float64(s.Quantity)
	}

	opt := services.FilterOptions{
		Search:    r.URL.Query().Get("q"),
		SortBy:    r.URL.Query().Get("sort"),
		SortOrder: r.URL.Query().Get("order"),
		Country:   r.URL.Query().Get("country"),
	}
	if opt.SortOrder == "" {
		opt.SortOrder = "DESC"
	}

	deals, _ := collectionSvc.ListDeals(opt)

	renderTemplate(w, r, "index.html", map[string]interface{}{
		"TotalSets":  totalSets,
		"TotalParts": totalParts,
		"TotalFigs":  totalFigs,
		"TotalValue": totalValue,
		"Deals":      deals,
		"KanbanLink": "https://trello.com", // Restored Kanban placeholder
		"Filter":     opt,
	})
}

func verifyAdminOverride(usernameOrID, password string) bool {
	user, err := auth.Login(database, usernameOrID, password)
	if err != nil || user.Role != "admin" {
		return false
	}
	return true
}

func redirect(w http.ResponseWriter, r *http.Request, url string) {
	if r.Header.Get("HX-Request") != "" {
		w.Header().Set("HX-Redirect", url)
		w.WriteHeader(http.StatusOK)
		return
	}
	http.Redirect(w, r, url, http.StatusSeeOther)
}

func deleteSetHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		redirect(w, r, "/sets")
		return
	}
	adminUser := r.FormValue("admin_user")
	adminPass := r.FormValue("admin_pass")
	id, _ := strconv.Atoi(r.FormValue("id"))
	if !verifyAdminOverride(adminUser, adminPass) {
		sets, _ := collectionSvc.ListSets(services.FilterOptions{})
		var set *models.Set
		for _, s := range sets {
			if s.ID == id {
				set = &s
				break
			}
		}
		if set != nil {
			renderTemplate(w, r, "edit_set.html", map[string]interface{}{
				"ID":                    set.ID,
				"SetNum":                set.SetNum,
				"Name":                  set.Name,
				"Year":                  set.Year,
				"Theme":                 set.Theme,
				"PartsCount":            set.PartsCount,
				"Quantity":              set.Quantity,
				"ImageURL":              set.ImageURL,
				"Price":                 set.Price,
				"Cost":                  set.Cost,
				"Status":                set.Status,
				"Condition":             set.Condition,
				"Remarks":               set.Remarks,
				"InstructionBookNumber": set.InstructionBookNumber,
				"InstructionBookCount":  set.InstructionBookCount,
				"HasInstructions":       set.HasInstructions,
				"PartOut":               set.PartOut,
				"BoxArtURL":             set.BoxArtURL,
				"InstructionsURL":       set.InstructionsURL,
				"LegoLink":              set.LegoLink,
				"EbayLink":              set.EbayLink,
				"AmazonLink":            set.AmazonLink,
				"LDrawFile":             set.LDrawFile,
				"Error":                 "Admin override failed: Invalid credentials",
			})
			return
		}
		http.Error(w, "Admin override failed: Invalid credentials or not an admin", http.StatusUnauthorized)
		return
	}
	if err := collectionSvc.DeleteSet(id); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	redirect(w, r, "/sets")
}

func bulkDeleteSetsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		redirect(w, r, "/sets")
		return
	}

	adminUser := r.FormValue("admin_user")
	adminPass := r.FormValue("admin_pass")
	if !verifyAdminOverride(adminUser, adminPass) {
		http.Error(w, "Admin override failed: Invalid credentials or not an admin", http.StatusUnauthorized)
		return
	}

	r.ParseForm()
	ids := r.Form["set_ids"]
	for _, idStr := range ids {
		id, _ := strconv.Atoi(idStr)
		if err := collectionSvc.DeleteSet(id); err != nil {
			log.Printf("Error deleting set %d: %v", id, err)
		}
	}

	redirect(w, r, "/sets")
}

func deletePartHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		redirect(w, r, "/parts")
		return
	}
	id, _ := strconv.Atoi(r.FormValue("id"))
	adminUser := r.FormValue("admin_user")
	adminPass := r.FormValue("admin_pass")
	if !verifyAdminOverride(adminUser, adminPass) {
		parts, _ := collectionSvc.ListParts(services.FilterOptions{})
		var part *models.Part
		for _, p := range parts {
			if p.ID == id {
				part = &p
				break
			}
		}
		if part != nil {
			renderTemplate(w, r, "edit_part.html", map[string]interface{}{
				"ID":        part.ID,
				"PartNum":   part.PartNum,
				"Name":      part.Name,
				"Category":  part.Category,
				"Color":     part.Color,
				"Quantity":  part.Quantity,
				"ImageURL":  part.ImageURL,
				"Price":     part.Price,
				"Cost":      part.Cost,
				"Condition": part.Condition,
				"Remarks":   part.Remarks,
				"CadFile":   part.CadFile,
				"Error":     "Admin override failed: Invalid credentials",
			})
			return
		}
		http.Error(w, "Admin override failed: Invalid credentials or not an admin", http.StatusUnauthorized)
		return
	}
	if err := collectionSvc.DeletePart(id); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	redirect(w, r, "/parts")
}

func bulkDeletePartsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		redirect(w, r, "/parts")
		return
	}

	adminUser := r.FormValue("admin_user")
	adminPass := r.FormValue("admin_pass")
	if !verifyAdminOverride(adminUser, adminPass) {
		w.Write([]byte(`<script>alert("Admin override failed: Invalid credentials or not an admin");</script>`))
		return
	}

	r.ParseForm()
	ids := r.Form["part_ids"]
	for _, idStr := range ids {
		id, _ := strconv.Atoi(idStr)
		if err := collectionSvc.DeletePart(id); err != nil {
			log.Printf("Error deleting part %d: %v", id, err)
		}
	}

	redirect(w, r, "/parts")
}

func deleteMinifigureHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		redirect(w, r, "/minifigures")
		return
	}
	adminUser := r.FormValue("admin_user")
	adminPass := r.FormValue("admin_pass")
	id, _ := strconv.Atoi(r.FormValue("id"))
	if !verifyAdminOverride(adminUser, adminPass) {
		w.Write([]byte(`<script>alert("Admin override failed: Invalid credentials or not an admin"); window.location.href="/minifigures";</script>`))
		return
	}
	if err := collectionSvc.DeleteMinifigure(id); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	redirect(w, r, "/minifigures")
}

func bulkDeleteMinifiguresHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		redirect(w, r, "/minifigures")
		return
	}

	adminUser := r.FormValue("admin_user")
	adminPass := r.FormValue("admin_pass")
	if !verifyAdminOverride(adminUser, adminPass) {
		w.Write([]byte(`<script>alert("Admin override failed: Invalid credentials or not an admin");</script>`))
		return
	}

	r.ParseForm()
	ids := r.Form["fig_ids"]
	for _, idStr := range ids {
		id, _ := strconv.Atoi(idStr)
		if err := collectionSvc.DeleteMinifigure(id); err != nil {
			log.Printf("Error deleting minifigure %d: %v", id, err)
		}
	}

	redirect(w, r, "/minifigures")
}

func deleteWishlistHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/wishlist", http.StatusSeeOther)
		return
	}
	id, _ := strconv.Atoi(r.FormValue("id"))
	if err := collectionSvc.DeleteWishlist(id); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/wishlist", http.StatusSeeOther)
}

func changeUserIDHandler(w http.ResponseWriter, r *http.Request) {
	id, _ := strconv.Atoi(r.FormValue("id"))
	userID := r.FormValue("user_id")
	if err := userSvc.SetUserID(id, userID); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/users", http.StatusSeeOther)
}

func setsHandler(w http.ResponseWriter, r *http.Request) {
	opt := services.FilterOptions{
		Search:    r.URL.Query().Get("q"),
		SortBy:    r.URL.Query().Get("sort"),
		SortOrder: r.URL.Query().Get("order"),
		Theme:     r.URL.Query().Get("theme"),
	}
	if opt.SortOrder == "" {
		opt.SortOrder = "ASC"
	}

	sets, err := collectionSvc.ListSets(opt)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	users, _ := userSvc.ListUsers()
	var admins []models.User
	for _, u := range users {
		if u.Role == "admin" {
			admins = append(admins, u)
		}
	}
	
	data := map[string]interface{}{
		"Items":  sets,
		"Admins": admins,
		"Filter": opt,
	}

	if r.Header.Get("HX-Request") == "true" {
		renderTemplate(w, r, "sets.html", data) // In a real HTMX setup, we might render a fragment
		return
	}

	renderTemplate(w, r, "sets.html", data)
}

func viewSetHandler(w http.ResponseWriter, r *http.Request) {
	id, _ := strconv.Atoi(r.URL.Query().Get("id"))
	sets, _ := collectionSvc.ListSets(services.FilterOptions{})
	var set *models.Set
	for _, s := range sets {
		if s.ID == id {
			set = &s
			break
		}
	}
	if set == nil {
		http.Error(w, "Set not found", http.StatusNotFound)
		return
	}

	opt := services.FilterOptions{
		Search:    r.URL.Query().Get("q"),
		SortBy:    r.URL.Query().Get("sort"),
		SortOrder: r.URL.Query().Get("order"),
	}
	parts, _ := collectionSvc.GetPartsForSet(id, opt)
	minifigs, _ := collectionSvc.GetMinifigsForSet(id)
	allMinifigs, _ := collectionSvc.ListMinifigures(services.FilterOptions{})

	session, _ := store.Get(r, "lego-manager-session")
	userID, _ := session.Values["userID"].(int)
	progress, _ := collectionSvc.GetUserSetProgress(userID, id)

	similarSets, _ := collectionSvc.ListSets(services.FilterOptions{Theme: set.Theme})
	var filteredSimilar []models.Set
	for _, s := range similarSets {
		if s.ID != set.ID {
			filteredSimilar = append(filteredSimilar, s)
		}
		if len(filteredSimilar) >= 4 {
			break
		}
	}

	// Mock external data
	data := map[string]interface{}{
		"Set": set,
		"Parts": parts,
		"Minifigs": minifigs,
		"AllMinifigs": allMinifigs,
		"Progress": progress,
		"Amazon": map[string]interface{}{
			"Appreciation": -0.49,
			"LowPrice": 228.87,
			"AvgPrice": 213.74,
			"MonthlyVolume": 200,
		},
		"BrickLink": map[string]interface{}{
			"Appreciation": -21.74,
			"LowPrice": 179.99,
			"AvgPrice": 193.20,
			"UsedPrice": 164.36,
		},
		"PartOut": map[string]interface{}{
			"MinifigValue": 18.71,
			"TotalValue": 35.94,
			"Confidence": 15.6,
		},
		"Retired": set.Year < 2024,
		"SimilarSets": filteredSimilar,
	}

	renderTemplate(w, r, "view_set.html", data)
}

func addSetFormHandler(w http.ResponseWriter, r *http.Request) {
	renderTemplate(w, r, "add_set.html", nil)
}

func addSetActionHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	setNum := r.FormValue("set_num")
	qtyStr := r.FormValue("quantity")
	qty, _ := strconv.Atoi(qtyStr)
	price, _ := strconv.ParseFloat(r.FormValue("price"), 64)
	cost, _ := strconv.ParseFloat(r.FormValue("cost"), 64)
	condition := r.FormValue("condition")
	remarks := r.FormValue("remarks")
	hasInstructions := r.FormValue("has_instructions") == "on"

	// Handle LDraw file upload
	var ldrawFile string
	file, header, err := r.FormFile("ldraw_file")
	if err == nil {
		defer file.Close()
		os.MkdirAll("uploads/ldraw", os.ModePerm)
		out, err := os.Create("uploads/ldraw/" + header.Filename)
		if err == nil {
			defer out.Close()
			io.Copy(out, file)
			ldrawFile = header.Filename
		}
	}

	// Fetch from Rebrickable
	details, err := rebrickable.GetSetDetails(setNum)
	if err != nil {
		w.Write([]byte(`<div class="p-4 bg-red-100 text-red-700 rounded">Error: ` + err.Error() + `</div>`))
		return
	}

	newSet := &models.Set{
		SetNum:          details.SetNum,
		Name:            details.Name,
		Year:            details.Year,
		PartsCount:      details.NumParts,
		Quantity:        qty,
		ImageURL:        details.SetImgURL,
		Theme:           "Added",
		Price:           price,
		Cost:            cost,
		Condition:       condition,
		Remarks:         remarks,
		HasInstructions: hasInstructions,
		BoxArtURL:       r.FormValue("box_art_url"),
		InstructionsURL: r.FormValue("instructions_url"),
		LegoLink:        r.FormValue("lego_link"),
		EbayLink:        r.FormValue("ebay_link"),
		AmazonLink:      r.FormValue("amazon_link"),
		LDrawFile:       ldrawFile,
	}

	if err := collectionSvc.AddSet(newSet); err != nil {
		w.Write([]byte(`<div class="p-4 bg-red-100 text-red-700 rounded">Error saving to DB: ` + err.Error() + `</div>`))
		return
	}

	http.Redirect(w, r, "/sets", http.StatusSeeOther)
}

func partsHandler(w http.ResponseWriter, r *http.Request) {
	opt := services.FilterOptions{
		Search:    r.URL.Query().Get("q"),
		SortBy:    r.URL.Query().Get("sort"),
		SortOrder: r.URL.Query().Get("order"),
		Category:  r.URL.Query().Get("category"),
	}
	if opt.SortOrder == "" {
		opt.SortOrder = "ASC"
	}

	parts, err := collectionSvc.ListParts(opt)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	users, _ := userSvc.ListUsers()
	var admins []models.User
	for _, u := range users {
		if u.Role == "admin" {
			admins = append(admins, u)
		}
	}
	renderTemplate(w, r, "parts.html", map[string]interface{}{
		"Items":  parts,
		"Admins": admins,
		"Filter": opt,
	})
}

func viewPartHandler(w http.ResponseWriter, r *http.Request) {
	id, _ := strconv.Atoi(r.URL.Query().Get("id"))
	parts, _ := collectionSvc.ListParts(services.FilterOptions{})
	var part *models.Part
	for _, p := range parts {
		if p.ID == id {
			part = &p
			break
		}
	}
	if part == nil {
		http.Error(w, "Part not found", http.StatusNotFound)
		return
	}

	// Mock data for colors
	data := map[string]interface{}{
		"Part": part,
		"Colors": []map[string]interface{}{
			{"Name": part.Color, "ElementID": "6444198", "ImageURL": part.ImageURL},
		},
	}

	renderTemplate(w, r, "view_part.html", data)
}

func addPartFormHandler(w http.ResponseWriter, r *http.Request) {
	renderTemplate(w, r, "add_part.html", nil)
}

func addPartActionHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	partNum := r.FormValue("part_num")
	color := r.FormValue("color")
	qtyStr := r.FormValue("quantity")
	qty, _ := strconv.Atoi(qtyStr)
	price, _ := strconv.ParseFloat(r.FormValue("price"), 64)
	cost, _ := strconv.ParseFloat(r.FormValue("cost"), 64)
	condition := r.FormValue("condition")
	remarks := r.FormValue("remarks")

	var cadFile string
	file, header, err := r.FormFile("cad_file")
	if err == nil {
		defer file.Close()
		os.MkdirAll("uploads/cad", os.ModePerm)
		out, err := os.Create("uploads/cad/" + header.Filename)
		if err == nil {
			defer out.Close()
			io.Copy(out, file)
			cadFile = header.Filename
		}
	}

	details, err := rebrickable.GetPartDetails(partNum)
	if err != nil {
		w.Write([]byte(`<div class="p-4 bg-red-100 text-red-700 rounded">Error: ` + err.Error() + `</div>`))
		return
	}

	newPart := &models.Part{
		PartNum:   details.PartNum,
		Name:      details.Name,
		Color:     color,
		Quantity:  qty,
		ImageURL:  details.PartImgURL,
		Price:     price,
		Cost:      cost,
		Condition: condition,
		Remarks:   remarks,
		CadFile:   cadFile,
	}

	if err := collectionSvc.AddPart(newPart); err != nil {
		w.Write([]byte(`<div class="p-4 bg-red-100 text-red-700 rounded">Error saving to DB: ` + err.Error() + `</div>`))
		return
	}

	http.Redirect(w, r, "/parts", http.StatusSeeOther)
}

func editPartFormHandler(w http.ResponseWriter, r *http.Request) {
	id, _ := strconv.Atoi(r.URL.Query().Get("id"))
	parts, _ := collectionSvc.ListParts(services.FilterOptions{})
	var part *models.Part
	for _, p := range parts {
		if p.ID == id {
			part = &p
			break
		}
	}
	if part == nil {
		http.Error(w, "Part not found", http.StatusNotFound)
		return
	}

	users, _ := userSvc.ListUsers()
	var admins []models.User
	for _, u := range users {
		if u.Role == "admin" {
			admins = append(admins, u)
		}
	}

	renderTemplate(w, r, "edit_part.html", map[string]interface{}{
		"ID":        part.ID,
		"PartNum":   part.PartNum,
		"Name":      part.Name,
		"Category":  part.Category,
		"Color":     part.Color,
		"Quantity":  part.Quantity,
		"ImageURL":  part.ImageURL,
		"Price":     part.Price,
		"Cost":      part.Cost,
		"Condition": part.Condition,
		"Remarks":   part.Remarks,
		"CadFile":   part.CadFile,
		"Admins":    admins,
	})
}

func updatePartActionHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	id, _ := strconv.Atoi(r.FormValue("id"))
	qty, _ := strconv.Atoi(r.FormValue("quantity"))
	price, _ := strconv.ParseFloat(r.FormValue("price"), 64)
	cost, _ := strconv.ParseFloat(r.FormValue("cost"), 64)

	parts, _ := collectionSvc.ListParts(services.FilterOptions{})
	var currentFile string
	for _, p := range parts {
		if p.ID == id {
			currentFile = p.CadFile
			break
		}
	}

	file, header, err := r.FormFile("cad_file")
	if err == nil {
		defer file.Close()
		os.MkdirAll("uploads/cad", os.ModePerm)
		out, err := os.Create("uploads/cad/" + header.Filename)
		if err == nil {
			defer out.Close()
			io.Copy(out, file)
			currentFile = header.Filename
		}
	}

	updatedPart := &models.Part{
		ID:        id,
		PartNum:   r.FormValue("part_num"),
		Name:      r.FormValue("name"),
		Category:  r.FormValue("category"),
		Color:     r.FormValue("color"),
		Quantity:  qty,
		ImageURL:  r.FormValue("image_url"),
		Price:     price,
		Cost:      cost,
		Condition: r.FormValue("condition"),
		Remarks:   r.FormValue("remarks"),
		CadFile:   currentFile,
	}

	if err := collectionSvc.UpdatePart(updatedPart); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	http.Redirect(w, r, "/parts", http.StatusSeeOther)
}

func changePasswordHandler(w http.ResponseWriter, r *http.Request) {
	session, _ := store.Get(r, "lego-manager-session")
	userID := session.Values["userID"].(int)

	if r.Method == http.MethodGet {
		renderTemplate(w, r, "change_password.html", nil)
		return
	}

	newPassword := r.FormValue("password")
	confirmPassword := r.FormValue("confirm_password")

	if newPassword != confirmPassword {
		renderTemplate(w, r, "change_password.html", map[string]interface{}{"Error": "Passwords do not match"})
		return
	}

	if err := auth.ChangePassword(database, userID, newPassword); err != nil {
		renderTemplate(w, r, "change_password.html", map[string]interface{}{"Error": err.Error()})
		return
	}

	session.Values["passwordChanged"] = true
	session.Save(r, w)
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

func usersHandler(w http.ResponseWriter, r *http.Request) {
	users, err := userSvc.ListUsers()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	renderTemplate(w, r, "users.html", users)
}

func createUserHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	username := r.FormValue("username")
	firstName := r.FormValue("first_name")
	lastName := r.FormValue("last_name")
	role := r.FormValue("role")

	if err := userSvc.CreateUser(username, firstName, lastName, role); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/users", http.StatusSeeOther)
}

func toggleUserHandler(w http.ResponseWriter, r *http.Request) {
	id, _ := strconv.Atoi(r.FormValue("id"))
	disabled, _ := strconv.ParseBool(r.FormValue("disabled"))
	if err := userSvc.SetDisabled(id, !disabled); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/users", http.StatusSeeOther)
}

func changeUserRoleHandler(w http.ResponseWriter, r *http.Request) {
	id, _ := strconv.Atoi(r.FormValue("id"))
	role := r.FormValue("role")
	if err := userSvc.SetRole(id, role); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/users", http.StatusSeeOther)
}

func resetPasswordHandler(w http.ResponseWriter, r *http.Request) {
	id, _ := strconv.Atoi(r.FormValue("id"))
	if err := userSvc.ResetPassword(id); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/users", http.StatusSeeOther)
}

func deleteUserHandler(w http.ResponseWriter, r *http.Request) {
	id, _ := strconv.Atoi(r.FormValue("id"))
	if err := userSvc.DeleteUser(id); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/users", http.StatusSeeOther)
}

func syncPartsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		setID, _ := strconv.Atoi(r.URL.Query().Get("set_id"))
		parts, _ := collectionSvc.ListParts(services.FilterOptions{})
		setParts, _ := collectionSvc.GetPartsForSet(setID, services.FilterOptions{})
		
		renderTemplate(w, r, "sync_parts.html", map[string]interface{}{
			"SetID":    setID,
			"AllParts": parts,
			"SetParts": setParts,
		})
		return
	}

	setID, _ := strconv.Atoi(r.FormValue("set_id"))
	partID, _ := strconv.Atoi(r.FormValue("part_id"))
	qty, _ := strconv.Atoi(r.FormValue("quantity"))

	if err := collectionSvc.AddPartToSet(setID, partID, qty); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/sets/sync-parts?set_id="+strconv.Itoa(setID), http.StatusSeeOther)
}

func syncMinifigsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodPost {
		setID, _ := strconv.Atoi(r.FormValue("set_id"))
		minifigID, _ := strconv.Atoi(r.FormValue("minifig_id"))
		qty, _ := strconv.Atoi(r.FormValue("quantity"))

		if err := collectionSvc.AddMinifigToSet(setID, minifigID, qty); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		http.Redirect(w, r, "/sets/view?id="+strconv.Itoa(setID), http.StatusSeeOther)
	}
}

func removePartFromSetHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/sets", http.StatusSeeOther)
		return
	}
	setID, _ := strconv.Atoi(r.FormValue("set_id"))
	partID, _ := strconv.Atoi(r.FormValue("part_id"))
	if err := collectionSvc.RemovePartFromSet(setID, partID); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/sets/sync-parts?set_id="+strconv.Itoa(setID), http.StatusSeeOther)
}

func editSetFormHandler(w http.ResponseWriter, r *http.Request) {
	id, _ := strconv.Atoi(r.URL.Query().Get("id"))
	sets, _ := collectionSvc.ListSets(services.FilterOptions{})
	var set *models.Set
	for _, s := range sets {
		if s.ID == id {
			set = &s
			break
		}
	}
	if set == nil {
		http.Error(w, "Set not found", http.StatusNotFound)
		return
	}

	users, _ := userSvc.ListUsers()
	var admins []models.User
	for _, u := range users {
		if u.Role == "admin" {
			admins = append(admins, u)
		}
	}

	renderTemplate(w, r, "edit_set.html", map[string]interface{}{
		"ID":                    set.ID,
		"SetNum":                set.SetNum,
		"Name":                  set.Name,
		"Year":                  set.Year,
		"Theme":                 set.Theme,
		"PartsCount":            set.PartsCount,
		"Quantity":              set.Quantity,
		"ImageURL":              set.ImageURL,
		"Price":                 set.Price,
		"Cost":                  set.Cost,
		"Status":                set.Status,
		"Condition":             set.Condition,
		"Remarks":               set.Remarks,
		"InstructionBookNumber": set.InstructionBookNumber,
		"InstructionBookCount":  set.InstructionBookCount,
		"HasInstructions":       set.HasInstructions,
		"PartOut":               set.PartOut,
		"BoxArtURL":             set.BoxArtURL,
		"InstructionsURL":       set.InstructionsURL,
		"LegoLink":              set.LegoLink,
		"EbayLink":              set.EbayLink,
		"AmazonLink":            set.AmazonLink,
		"LDrawFile":             set.LDrawFile,
		"Admins":                admins,
	})
}

func updateSetActionHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	id, _ := strconv.Atoi(r.FormValue("id"))
	qty, _ := strconv.Atoi(r.FormValue("quantity"))
	year, _ := strconv.Atoi(r.FormValue("year"))
	partsCount, _ := strconv.Atoi(r.FormValue("parts_count"))
	price, _ := strconv.ParseFloat(r.FormValue("price"), 64)
	cost, _ := strconv.ParseFloat(r.FormValue("cost"), 64)
	bookCount, _ := strconv.Atoi(r.FormValue("instruction_book_count"))

	// Retrieve existing set to keep current file if not replaced
	sets, _ := collectionSvc.ListSets(services.FilterOptions{})
	var currentFile string
	for _, s := range sets {
		if s.ID == id {
			currentFile = s.LDrawFile
			break
		}
	}

	file, header, err := r.FormFile("ldraw_file")
	if err == nil {
		defer file.Close()
		os.MkdirAll("uploads/ldraw", os.ModePerm)
		out, err := os.Create("uploads/ldraw/" + header.Filename)
		if err == nil {
			defer out.Close()
			io.Copy(out, file)
			currentFile = header.Filename
		}
	}

	updatedSet := &models.Set{
		ID:                    id,
		SetNum:                r.FormValue("set_num"),
		Name:                  r.FormValue("name"),
		Year:                  year,
		Theme:                 r.FormValue("theme"),
		PartsCount:            partsCount,
		Quantity:              qty,
		ImageURL:              r.FormValue("image_url"),
		Price:                 price,
		Cost:                  cost,
		Status:                r.FormValue("status"),
		Condition:             r.FormValue("condition"),
		Remarks:               r.FormValue("remarks"),
		InstructionBookNumber: r.FormValue("instruction_book_number"),
		InstructionBookCount:  bookCount,
		HasInstructions:       r.FormValue("has_instructions") == "on",
		PartOut:               r.FormValue("part_out") == "on",
		BoxArtURL:             r.FormValue("box_art_url"),
		InstructionsURL:       r.FormValue("instructions_url"),
		LegoLink:              r.FormValue("lego_link"),
		EbayLink:              r.FormValue("ebay_link"),
		AmazonLink:            r.FormValue("amazon_link"),
		LDrawFile:             currentFile,
	}

	if err := collectionSvc.UpdateSet(updatedSet); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	http.Redirect(w, r, "/sets", http.StatusSeeOther)
}

func updateProgressHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	session, _ := store.Get(r, "lego-manager-session")
	userID, ok := session.Values["userID"].(int)
	if !ok {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	setID, _ := strconv.Atoi(r.FormValue("set_id"))
	partID, _ := strconv.Atoi(r.FormValue("part_id"))
	found, _ := strconv.Atoi(r.FormValue("found_quantity"))

	if err := collectionSvc.UpdateUserSetProgress(userID, setID, partID, found); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func minifiguresHandler(w http.ResponseWriter, r *http.Request) {
	opt := services.FilterOptions{
		Search:    r.URL.Query().Get("q"),
		SortBy:    r.URL.Query().Get("sort"),
		SortOrder: r.URL.Query().Get("order"),
	}
	if opt.SortOrder == "" {
		opt.SortOrder = "ASC"
	}

	figures, err := collectionSvc.ListMinifigures(opt)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	users, _ := userSvc.ListUsers()
	var admins []models.User
	for _, u := range users {
		if u.Role == "admin" {
			admins = append(admins, u)
		}
	}
	renderTemplate(w, r, "minifigures.html", map[string]interface{}{
		"Items":  figures,
		"Admins": admins,
		"Filter": opt,
	})
}

func updateSetImageHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/sets", http.StatusSeeOther)
		return
	}
	id, _ := strconv.Atoi(r.FormValue("id"))
	imageURL := r.FormValue("image_url")
	if err := collectionSvc.UpdateSetImage(id, imageURL); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/sets", http.StatusSeeOther)
}

func addMinifigureFormHandler(w http.ResponseWriter, r *http.Request) {
	renderTemplate(w, r, "add_minifigure.html", nil)
}

func addMinifigureActionHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	figNum := r.FormValue("fig_num")
	qtyStr := r.FormValue("quantity")
	qty, _ := strconv.Atoi(qtyStr)

	details, err := rebrickable.GetMinifigureDetails(figNum)
	if err != nil {
		w.Write([]byte(`<div class="p-4 bg-red-100 text-red-700 rounded">Error: ` + err.Error() + `</div>`))
		return
	}

	newFig := &models.Minifigure{
		FigNum:   details.SetNum,
		Name:     details.Name,
		Quantity: qty,
		ImageURL: details.SetImgURL,
	}

	if err := collectionSvc.AddMinifigure(newFig); err != nil {
		w.Write([]byte(`<div class="p-4 bg-red-100 text-red-700 rounded">Error saving to DB: ` + err.Error() + `</div>`))
		return
	}

	w.Write([]byte(`<div class="p-4 bg-green-100 text-green-700 rounded">Successfully added ` + details.Name + `! <a href="/minifigures" class="underline">View all figures</a></div>`))
}

func wishlistHandler(w http.ResponseWriter, r *http.Request) {
	items, err := collectionSvc.GetWishlist()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	renderTemplate(w, r, "wishlist.html", items)
}

func addWishlistFormHandler(w http.ResponseWriter, r *http.Request) {
	renderTemplate(w, r, "add_wishlist.html", nil)
}

func addWishlistActionHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	itemType := r.FormValue("item_type")
	refNum := r.FormValue("ref_num")
	priority, _ := strconv.Atoi(r.FormValue("priority"))

	var name string
	switch itemType {
	case "set":
		d, _ := rebrickable.GetSetDetails(refNum)
		if d != nil {
			name = d.Name
		}
	case "part":
		d, _ := rebrickable.GetPartDetails(refNum)
		if d != nil {
			name = d.Name
		}
	case "minifig":
		d, _ := rebrickable.GetMinifigureDetails(refNum)
		if d != nil {
			name = d.Name
		}
	}

	if name == "" {
		name = "Unknown Item " + refNum
	}

	newItem := &models.WishlistItem{
		ItemType: itemType,
		RefNum:   refNum,
		Name:     name,
		Priority: priority,
	}

	if err := collectionSvc.AddToWishlist(newItem); err != nil {
		w.Write([]byte(`<div class="p-4 bg-red-100 text-red-700 rounded">Error saving to DB: ` + err.Error() + `</div>`))
		return
	}

	w.Write([]byte(`<div class="p-4 bg-green-100 text-green-700 rounded">Successfully added ` + name + ` to wishlist! <a href="/wishlist" class="underline">View wishlist</a></div>`))
}

func exportHandler(w http.ResponseWriter, r *http.Request) {
	data, err := collectionSvc.GetAllData()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Content-Disposition", "attachment; filename=lego-collection.json")
	json.NewEncoder(w).Encode(data)
}

func uploadHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/", http.StatusSeeOther)
		return
	}

	file, _, err := r.FormFile("collection")
	if err != nil {
		http.Error(w, "Error retrieving the file", http.StatusBadRequest)
		return
	}
	defer file.Close()

	var data map[string]interface{}
	if err := json.NewDecoder(file).Decode(&data); err != nil {
		http.Error(w, "Error decoding JSON", http.StatusBadRequest)
		return
	}

	if err := collectionSvc.ImportData(data); err != nil {
		http.Error(w, "Error importing data", http.StatusInternalServerError)
		return
	}

	http.Redirect(w, r, "/", http.StatusSeeOther)
}

