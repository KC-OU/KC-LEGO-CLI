package services

import (
	"database/sql"
	"encoding/json"
	"lego-manager/internal/models"
	"time"
)

type CollectionService struct {
	DB *sql.DB
}

type FilterOptions struct {
	Search    string
	SortBy    string
	SortOrder string // ASC or DESC
	Theme     string
	Category  string
	Year      int
	MinPrice  float64
	MaxPrice  float64
	Status    string
	Country   string
	Store     string
}

func NewCollectionService(db *sql.DB) *CollectionService {
	return &CollectionService{DB: db}
}

func (s *CollectionService) AddSet(set *models.Set) error {
	query := `INSERT INTO sets (set_num, name, year, theme, parts_count, quantity, image_url, price, cost, status, condition, remarks, instruction_book_number, instruction_book_count, has_instructions, part_out, box_art_url, instructions_url, lego_link, ebay_link, amazon_link, created_at, updated_at) 
			  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
	now := time.Now()
	_, err := s.DB.Exec(query, set.SetNum, set.Name, set.Year, set.Theme, set.PartsCount, set.Quantity, set.ImageURL, set.Price, set.Cost, set.Status, set.Condition, set.Remarks, set.InstructionBookNumber, set.InstructionBookCount, set.HasInstructions, set.PartOut, set.BoxArtURL, set.InstructionsURL, set.LegoLink, set.EbayLink, set.AmazonLink, now, now)
	return err
}

func (s *CollectionService) ListSets(opt FilterOptions) ([]models.Set, error) {
	query := `SELECT id, set_num, name, year, theme, parts_count, quantity, image_url, 
			  COALESCE(price, 0), COALESCE(cost, 0), COALESCE(status, ''), COALESCE(condition, ''), 
			  COALESCE(remarks, ''), COALESCE(instruction_book_number, ''), 
			  COALESCE(instruction_book_count, 0), COALESCE(has_instructions, 0), 
			  COALESCE(part_out, 0), COALESCE(box_art_url, ''), COALESCE(instructions_url, ''),
			  COALESCE(lego_link, ''), COALESCE(ebay_link, ''), COALESCE(amazon_link, ''),
			  COALESCE(ldraw_file, '') FROM sets WHERE 1=1`
	
	args := []interface{}{}
	if opt.Search != "" {
		query += " AND (name LIKE ? OR set_num LIKE ?)"
		args = append(args, "%"+opt.Search+"%", "%"+opt.Search+"%")
	}
	if opt.Theme != "" {
		query += " AND theme = ?"
		args = append(args, opt.Theme)
	}
	if opt.Year > 0 {
		query += " AND year = ?"
		args = append(args, opt.Year)
	}
	if opt.Status != "" {
		query += " AND status = ?"
		args = append(args, opt.Status)
	}

	if opt.SortBy != "" {
		// Basic SQL injection protection for column name
		allowedColumns := map[string]bool{"name": true, "year": true, "theme": true, "parts_count": true, "price": true, "cost": true, "quantity": true, "id": true, "set_num": true}
		if allowedColumns[opt.SortBy] {
			query += " ORDER BY " + opt.SortBy
			if opt.SortOrder == "DESC" {
				query += " DESC"
			} else {
				query += " ASC"
			}
		}
	} else {
		query += " ORDER BY created_at DESC"
	}

	rows, err := s.DB.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var sets []models.Set
	for rows.Next() {
		var set models.Set
		if err := rows.Scan(&set.ID, &set.SetNum, &set.Name, &set.Year, &set.Theme, &set.PartsCount, &set.Quantity, &set.ImageURL, &set.Price, &set.Cost, &set.Status, &set.Condition, &set.Remarks, &set.InstructionBookNumber, &set.InstructionBookCount, &set.HasInstructions, &set.PartOut, &set.BoxArtURL, &set.InstructionsURL, &set.LegoLink, &set.EbayLink, &set.AmazonLink, &set.LDrawFile); err != nil {
			return nil, err
		}
		sets = append(sets, set)
	}
	return sets, nil
}

func (s *CollectionService) UpdateUserSetProgress(userID, setID, partID, quantity int) error {
	_, err := s.DB.Exec("INSERT OR REPLACE INTO user_set_progress (user_id, set_id, part_id, found_quantity) VALUES (?, ?, ?, ?)", userID, setID, partID, quantity)
	return err
}

func (s *CollectionService) GetUserSetProgress(userID, setID int) (map[int]int, error) {
	rows, err := s.DB.Query("SELECT part_id, found_quantity FROM user_set_progress WHERE user_id = ? AND set_id = ?", userID, setID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	progress := make(map[int]int)
	for rows.Next() {
		var partID, found int
		if err := rows.Scan(&partID, &found); err != nil {
			return nil, err
		}
		progress[partID] = found
	}
	return progress, nil
}

func (s *CollectionService) AddPart(part *models.Part) error {
	query := `INSERT INTO parts (part_num, name, category, color, quantity, image_url, long_part_id, condition, price, cost, remarks, cad_file, created_at, updated_at) 
			  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
	now := time.Now()
	_, err := s.DB.Exec(query, part.PartNum, part.Name, part.Category, part.Color, part.Quantity, part.ImageURL, part.LongPartID, part.Condition, part.Price, part.Cost, part.Remarks, part.CadFile, now, now)
	return err
}

func (s *CollectionService) ListParts(opt FilterOptions) ([]models.Part, error) {
	query := `SELECT id, part_num, name, category, color, quantity, image_url, long_part_id, 
			  COALESCE(condition, ''), COALESCE(price, 0), COALESCE(cost, 0), COALESCE(remarks, ''),
			  COALESCE(cad_file, '')
			  FROM parts WHERE 1=1`
	
	args := []interface{}{}
	if opt.Search != "" {
		query += " AND (name LIKE ? OR part_num LIKE ?)"
		args = append(args, "%"+opt.Search+"%", "%"+opt.Search+"%")
	}
	if opt.Category != "" {
		query += " AND category = ?"
		args = append(args, opt.Category)
	}

	if opt.SortBy != "" {
		allowedColumns := map[string]bool{"name": true, "part_num": true, "category": true, "color": true, "quantity": true, "price": true, "cost": true, "id": true}
		if allowedColumns[opt.SortBy] {
			query += " ORDER BY " + opt.SortBy
			if opt.SortOrder == "DESC" {
				query += " DESC"
			} else {
				query += " ASC"
			}
		}
	} else {
		query += " ORDER BY created_at DESC"
	}

	rows, err := s.DB.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var parts []models.Part
	for rows.Next() {
		var part models.Part
		if err := rows.Scan(&part.ID, &part.PartNum, &part.Name, &part.Category, &part.Color, &part.Quantity, &part.ImageURL, &part.LongPartID, &part.Condition, &part.Price, &part.Cost, &part.Remarks, &part.CadFile); err != nil {
			return nil, err
		}
		parts = append(parts, part)
	}
	return parts, nil
}

func (s *CollectionService) AddPartToSet(setID, partID, quantity int) error {
	_, err := s.DB.Exec("INSERT OR REPLACE INTO set_parts (set_id, part_id, quantity) VALUES (?, ?, ?)", setID, partID, quantity)
	return err
}

type SetPartDetail struct {
	models.Part
	QuantityInSet int `json:"quantity_in_set"`
}

func (s *CollectionService) GetPartsForSet(setID int, opt FilterOptions) ([]SetPartDetail, error) {
	query := `SELECT p.id, p.part_num, p.name, p.category, p.color, sp.quantity, p.image_url, p.long_part_id, 
			  COALESCE(p.condition, ''), COALESCE(p.price, 0), COALESCE(p.cost, 0), COALESCE(p.remarks, '') 
			  FROM parts p 
			  JOIN set_parts sp ON p.id = sp.part_id 
			  WHERE sp.set_id = ?`
	
	args := []interface{}{setID}
	if opt.Search != "" {
		query += " AND (p.name LIKE ? OR p.part_num LIKE ?)"
		args = append(args, "%"+opt.Search+"%", "%"+opt.Search+"%")
	}

	if opt.SortBy != "" {
		allowedColumns := map[string]bool{"name": true, "part_num": true, "category": true, "color": true, "quantity": true, "price": true, "cost": true}
		if allowedColumns[opt.SortBy] {
			if opt.SortBy == "quantity" {
				query += " ORDER BY sp.quantity"
			} else {
				query += " ORDER BY p." + opt.SortBy
			}
			if opt.SortOrder == "DESC" {
				query += " DESC"
			} else {
				query += " ASC"
			}
		}
	}

	rows, err := s.DB.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var parts []SetPartDetail
	for rows.Next() {
		var p SetPartDetail
		if err := rows.Scan(&p.ID, &p.PartNum, &p.Name, &p.Category, &p.Color, &p.QuantityInSet, &p.ImageURL, &p.LongPartID, &p.Condition, &p.Price, &p.Cost, &p.Remarks); err != nil {
			return nil, err
		}
		parts = append(parts, p)
	}
	return parts, nil
}

func (s *CollectionService) AddMinifigure(fig *models.Minifigure) error {
	query := `INSERT INTO minifigures (fig_num, name, quantity, image_url, created_at, updated_at) 
			  VALUES (?, ?, ?, ?, ?, ?)
			  ON CONFLICT(fig_num) DO UPDATE SET 
			  quantity = minifigures.quantity + excluded.quantity,
			  updated_at = excluded.updated_at`
	now := time.Now()
	_, err := s.DB.Exec(query, fig.FigNum, fig.Name, fig.Quantity, fig.ImageURL, now, now)
	return err
}

func (s *CollectionService) ListMinifigures(opt FilterOptions) ([]models.Minifigure, error) {
	query := "SELECT id, fig_num, name, quantity, image_url FROM minifigures WHERE 1=1"
	
	args := []interface{}{}
	if opt.Search != "" {
		query += " AND (name LIKE ? OR fig_num LIKE ?)"
		args = append(args, "%"+opt.Search+"%", "%"+opt.Search+"%")
	}

	if opt.SortBy != "" {
		allowedColumns := map[string]bool{"name": true, "fig_num": true, "quantity": true, "id": true}
		if allowedColumns[opt.SortBy] {
			query += " ORDER BY " + opt.SortBy
			if opt.SortOrder == "DESC" {
				query += " DESC"
			} else {
				query += " ASC"
			}
		}
	} else {
		query += " ORDER BY created_at DESC"
	}

	rows, err := s.DB.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var figures []models.Minifigure
	for rows.Next() {
		var fig models.Minifigure
		if err := rows.Scan(&fig.ID, &fig.FigNum, &fig.Name, &fig.Quantity, &fig.ImageURL); err != nil {
			return nil, err
		}
		figures = append(figures, fig)
	}
	return figures, nil
}

func (s *CollectionService) AddToWishlist(item *models.WishlistItem) error {
	query := `INSERT INTO wishlist (item_type, ref_num, name, priority, created_at) 
			  VALUES (?, ?, ?, ?, ?)`
	now := time.Now()
	_, err := s.DB.Exec(query, item.ItemType, item.RefNum, item.Name, item.Priority, now)
	return err
}

func (s *CollectionService) GetWishlist() ([]models.WishlistItem, error) {
	rows, err := s.DB.Query("SELECT id, item_type, ref_num, name, priority, created_at FROM wishlist ORDER BY priority DESC")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []models.WishlistItem
	for rows.Next() {
		var item models.WishlistItem
		if err := rows.Scan(&item.ID, &item.ItemType, &item.RefNum, &item.Name, &item.Priority, &item.CreatedAt); err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, nil
}

func (s *CollectionService) GetAllData() (map[string]interface{}, error) {
	sets, err := s.ListSets(FilterOptions{})
	if err != nil {
		return nil, err
	}
	parts, err := s.ListParts(FilterOptions{})
	if err != nil {
		return nil, err
	}
	figs, err := s.ListMinifigures(FilterOptions{})
	if err != nil {
		return nil, err
	}
	wishlist, err := s.GetWishlist()
	if err != nil {
		return nil, err
	}

	return map[string]interface{}{
		"sets":        sets,
		"parts":       parts,
		"minifigures": figs,
		"wishlist":    wishlist,
	}, nil
}

func (s *CollectionService) DeleteSet(id int) error {
	_, err := s.DB.Exec("DELETE FROM sets WHERE id = ?", id)
	return err
}

func (s *CollectionService) DeletePart(id int) error {
	_, err := s.DB.Exec("DELETE FROM parts WHERE id = ?", id)
	return err
}

func (s *CollectionService) DeleteMinifigure(id int) error {
	_, err := s.DB.Exec("DELETE FROM minifigures WHERE id = ?", id)
	return err
}

func (s *CollectionService) DeleteWishlist(id int) error {
	_, err := s.DB.Exec("DELETE FROM wishlist WHERE id = ?", id)
	return err
}

func (s *CollectionService) UpdateSetImage(id int, imageURL string) error {
	_, err := s.DB.Exec("UPDATE sets SET image_url = ?, updated_at = ? WHERE id = ?", imageURL, time.Now(), id)
	return err
}

func (s *CollectionService) RemovePartFromSet(setID, partID int) error {
	_, err := s.DB.Exec("DELETE FROM set_parts WHERE set_id = ? AND part_id = ?", setID, partID)
	return err
}

func (s *CollectionService) UpdateSet(set *models.Set) error {
	query := `UPDATE sets SET set_num = ?, name = ?, year = ?, theme = ?, parts_count = ?, quantity = ?, image_url = ?, price = ?, cost = ?, status = ?, condition = ?, remarks = ?, instruction_book_number = ?, instruction_book_count = ?, has_instructions = ?, part_out = ?, box_art_url = ?, instructions_url = ?, lego_link = ?, ebay_link = ?, amazon_link = ?, updated_at = ? WHERE id = ?`
	_, err := s.DB.Exec(query, set.SetNum, set.Name, set.Year, set.Theme, set.PartsCount, set.Quantity, set.ImageURL, set.Price, set.Cost, set.Status, set.Condition, set.Remarks, set.InstructionBookNumber, set.InstructionBookCount, set.HasInstructions, set.PartOut, set.BoxArtURL, set.InstructionsURL, set.LegoLink, set.EbayLink, set.AmazonLink, time.Now(), set.ID)
	return err
}

func (s *CollectionService) AddMinifigToSet(setID, minifigID, quantity int) error {
	_, err := s.DB.Exec("INSERT OR REPLACE INTO set_minifigures (set_id, minifig_id, quantity) VALUES (?, ?, ?)", setID, minifigID, quantity)
	return err
}

func (s *CollectionService) GetMinifigsForSet(setID int) ([]models.Minifigure, error) {
	query := `SELECT m.id, m.fig_num, m.name, sm.quantity, m.image_url 
			  FROM minifigures m 
			  JOIN set_minifigures sm ON m.id = sm.minifig_id 
			  WHERE sm.set_id = ?`
	rows, err := s.DB.Query(query, setID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var figs []models.Minifigure
	for rows.Next() {
		var fig models.Minifigure
		if err := rows.Scan(&fig.ID, &fig.FigNum, &fig.Name, &fig.Quantity, &fig.ImageURL); err != nil {
			return nil, err
		}
		figs = append(figs, fig)
	}
	return figs, nil
}

func (s *CollectionService) ListDeals(opt FilterOptions) ([]models.LegoDeal, error) {
	query := "SELECT id, name, set_num, store, price, discount, image_url, COALESCE(link, ''), COALESCE(country, 'UK') FROM deals WHERE 1=1"
	
	args := []interface{}{}
	if opt.Search != "" {
		query += " AND (name LIKE ? OR set_num LIKE ?)"
		args = append(args, "%"+opt.Search+"%", "%"+opt.Search+"%")
	}
	if opt.Country != "" {
		query += " AND country = ?"
		args = append(args, opt.Country)
	}
	if opt.Store != "" {
		query += " AND store = ?"
		args = append(args, opt.Store)
	}

	if opt.SortBy != "" {
		allowedColumns := map[string]bool{"name": true, "price": true, "discount": true, "created_at": true}
		if allowedColumns[opt.SortBy] {
			query += " ORDER BY " + opt.SortBy
			if opt.SortOrder == "DESC" {
				query += " DESC"
			} else {
				query += " ASC"
			}
		}
	} else {
		query += " ORDER BY created_at DESC"
	}

	rows, err := s.DB.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var deals []models.LegoDeal
	for rows.Next() {
		var d models.LegoDeal
		if err := rows.Scan(&d.ID, &d.Name, &d.SetNum, &d.Store, &d.Price, &d.Discount, &d.ImageURL, &d.URL, &d.Country); err != nil {
			return nil, err
		}
		deals = append(deals, d)
	}
	return deals, nil
}

func (s *CollectionService) AddDeal(d *models.LegoDeal) error {
	_, err := s.DB.Exec("INSERT INTO deals (name, set_num, store, price, discount, image_url, link, country) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
		d.Name, d.SetNum, d.Store, d.Price, d.Discount, d.ImageURL, d.URL, d.Country)
	return err
}

func (s *CollectionService) AddDeals(deals []models.LegoDeal) error {
	tx, err := s.DB.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	stmt, err := tx.Prepare("INSERT INTO deals (name, set_num, store, price, discount, image_url, link, country) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")
	if err != nil {
		return err
	}
	defer stmt.Close()

	for _, d := range deals {
		_, err := stmt.Exec(d.Name, d.SetNum, d.Store, d.Price, d.Discount, d.ImageURL, d.URL, d.Country)
		if err != nil {
			return err
		}
	}

	return tx.Commit()
}

func (s *CollectionService) DeleteDeal(id int) error {
	_, err := s.DB.Exec("DELETE FROM deals WHERE id = ?", id)
	return err
}

func (s *CollectionService) UpdatePart(part *models.Part) error {
	query := `UPDATE parts SET part_num = ?, name = ?, category = ?, color = ?, quantity = ?, image_url = ?, condition = ?, price = ?, cost = ?, remarks = ?, updated_at = ? WHERE id = ?`
	_, err := s.DB.Exec(query, part.PartNum, part.Name, part.Category, part.Color, part.Quantity, part.ImageURL, part.Condition, part.Price, part.Cost, part.Remarks, time.Now(), part.ID)
	return err
}

func (s *CollectionService) ImportData(data map[string]interface{}) error {
	// Simple implementation: iterate over each type and add. 
	// In a real app, we might want to use a transaction and handle duplicates better.
	
	if sets, ok := data["sets"].([]interface{}); ok {
		for _, setMap := range sets {
			jsonData, _ := json.Marshal(setMap)
			var set models.Set
			json.Unmarshal(jsonData, &set)
			s.AddSet(&set)
		}
	}

	if parts, ok := data["parts"].([]interface{}); ok {
		for _, partMap := range parts {
			jsonData, _ := json.Marshal(partMap)
			var part models.Part
			json.Unmarshal(jsonData, &part)
			s.AddPart(&part)
		}
	}

	if figs, ok := data["minifigures"].([]interface{}); ok {
		for _, figMap := range figs {
			jsonData, _ := json.Marshal(figMap)
			var fig models.Minifigure
			json.Unmarshal(jsonData, &fig)
			s.AddMinifigure(&fig)
		}
	}

	if wishlist, ok := data["wishlist"].([]interface{}); ok {
		for _, itemMap := range wishlist {
			jsonData, _ := json.Marshal(itemMap)
			var item models.WishlistItem
			json.Unmarshal(jsonData, &item)
			s.AddToWishlist(&item)
		}
	}

	return nil
}
