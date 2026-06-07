package models

import "time"

type User struct {
	ID              int    `json:"id"`
	Username        string `json:"username"`
	UserID          string `json:"user_id"`
	PasswordHash    string `json:"-"`
	FirstName       string `json:"first_name"`
	LastName        string `json:"last_name"`
	Role            string `json:"role"`
	Disabled        bool   `json:"disabled"`
	PasswordChanged bool   `json:"password_changed"`
}

type Set struct {
	ID                    int       `json:"id" xml:"id"`
	SetNum                string    `json:"set_num" xml:"set_num"`
	Name                  string    `json:"name" xml:"name"`
	Year                  int       `json:"year" xml:"year"`
	Theme                 string    `json:"theme" xml:"theme"`
	PartsCount            int       `json:"parts_count" xml:"parts_count"`
	Quantity              int       `json:"quantity" xml:"quantity"`
	ImageURL              string    `json:"image_url" xml:"image_url"`
	Price                 float64   `json:"price" xml:"price"`
	Cost                  float64   `json:"cost" xml:"cost"`
	Status                string    `json:"status" xml:"status"`
	Condition             string    `json:"condition" xml:"condition"`
	Remarks               string    `json:"remarks" xml:"remarks"`
	InstructionBookNumber string    `json:"instruction_book_number" xml:"instruction_book_number"`
	InstructionBookCount  int       `json:"instruction_book_count" xml:"instruction_book_count"`
	HasInstructions       bool      `json:"has_instructions" xml:"has_instructions"`
	PartOut               bool      `json:"part_out" xml:"part_out"`
	BoxArtURL             string    `json:"box_art_url" xml:"box_art_url"`
	InstructionsURL       string    `json:"instructions_url" xml:"instructions_url"`
	LegoLink              string    `json:"lego_link" xml:"lego_link"`
	EbayLink              string    `json:"ebay_link" xml:"ebay_link"`
	AmazonLink            string    `json:"amazon_link" xml:"amazon_link"`
	LDrawFile             string    `json:"ldraw_file" xml:"ldraw_file"`
	CreatedAt             time.Time `json:"created_at" xml:"created_at"`
	UpdatedAt             time.Time `json:"updated_at" xml:"updated_at"`
}

type Part struct {
	ID         int       `json:"id" xml:"id"`
	PartNum    string    `json:"part_num" xml:"part_num"`
	Name       string    `json:"name" xml:"name"`
	Category   string    `json:"category" xml:"category"`
	Color      string    `json:"color" xml:"color"`
	Quantity   int       `json:"quantity" xml:"quantity"`
	ImageURL   string    `json:"image_url" xml:"image_url"`
	LongPartID string    `json:"long_part_id" xml:"long_part_id"`
	Condition  string    `json:"condition" xml:"condition"`
	Price      float64   `json:"price" xml:"price"`
	Cost       float64   `json:"cost" xml:"cost"`
	Remarks    string    `json:"remarks" xml:"remarks"`
	CadFile    string    `json:"cad_file" xml:"cad_file"`
	CreatedAt  time.Time `json:"created_at" xml:"created_at"`
	UpdatedAt  time.Time `json:"updated_at" xml:"updated_at"`
}

type SetPart struct {
	SetID    int `json:"set_id" xml:"set_id"`
	PartID   int `json:"part_id" xml:"part_id"`
	Quantity int `json:"quantity" xml:"quantity"`
}

type Minifigure struct {
	ID        int       `json:"id" xml:"id"`
	FigNum    string    `json:"fig_num" xml:"fig_num"`
	Name      string    `json:"name" xml:"name"`
	Quantity  int       `json:"quantity" xml:"quantity"`
	ImageURL  string    `json:"image_url" xml:"image_url"`
	CreatedAt time.Time `json:"created_at" xml:"created_at"`
	UpdatedAt time.Time `json:"updated_at" xml:"updated_at"`
}

type WishlistItem struct {
	ID        int       `json:"id" xml:"id"`
	ItemType  string    `json:"item_type" xml:"item_type"`
	RefNum    string    `json:"ref_num" xml:"ref_num"`
	Name      string    `json:"name" xml:"name"`
	Priority  int       `json:"priority" xml:"priority"`
	CreatedAt time.Time `json:"created_at" xml:"created_at"`
}

type LegoDeal struct {
	ID        int     `json:"id" xml:"id"`
	Name      string  `json:"name" xml:"name"`
	SetNum    string  `json:"set_num" xml:"set_num"`
	Store     string  `json:"store" xml:"store"`
	Price     float64 `json:"price" xml:"price"`
	Discount  int     `json:"discount" xml:"discount"`
	ImageURL  string  `json:"image_url" xml:"image_url"`
	URL       string  `json:"url" xml:"url"`
	Country   string  `json:"country" xml:"country"`
}
