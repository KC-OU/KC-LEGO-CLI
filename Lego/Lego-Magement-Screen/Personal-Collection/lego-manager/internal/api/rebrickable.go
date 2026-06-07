package api

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type RebrickableClient struct {
	APIKey string
	BaseURL string
}

func NewRebrickableClient(apiKey string) *RebrickableClient {
	return &RebrickableClient{
		APIKey: apiKey,
		BaseURL: "https://rebrickable.com/api/v3/lego",
	}
}

type SetDetails struct {
	SetNum     string `json:"set_num"`
	Name       string `json:"name"`
	Year       int    `json:"year"`
	ThemeID    int    `json:"theme_id"`
	NumParts   int    `json:"num_parts"`
	SetImgURL  string `json:"set_img_url"`
}

type PartDetails struct {
	PartNum    string `json:"part_num"`
	Name       string `json:"name"`
	PartCatID  int    `json:"part_cat_id"`
	PartImgURL string `json:"part_img_url"`
}

type MinifigDetails struct {
	SetNum    string `json:"set_num"`
	Name      string `json:"name"`
	NumParts  int    `json:"num_parts"`
	SetImgURL string `json:"set_img_url"`
}

func (c *RebrickableClient) GetSetDetails(setNum string) (*SetDetails, error) {
	url := fmt.Sprintf("%s/sets/%s/", c.BaseURL, setNum)
	req, _ := http.NewRequest("GET", url, nil)
	req.Header.Set("Authorization", "key "+c.APIKey)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("api error: %s", resp.Status)
	}

	var details SetDetails
	if err := json.NewDecoder(resp.Body).Decode(&details); err != nil {
		return nil, err
	}

	return &details, nil
}

func (c *RebrickableClient) GetPartDetails(partNum string) (*PartDetails, error) {
	url := fmt.Sprintf("%s/parts/%s/", c.BaseURL, partNum)
	req, _ := http.NewRequest("GET", url, nil)
	req.Header.Set("Authorization", "key "+c.APIKey)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("api error: %s", resp.Status)
	}

	var details PartDetails
	if err := json.NewDecoder(resp.Body).Decode(&details); err != nil {
		return nil, err
	}

	return &details, nil
}

func (c *RebrickableClient) GetMinifigureDetails(figNum string) (*MinifigDetails, error) {
	url := fmt.Sprintf("%s/minifigs/%s/", c.BaseURL, figNum)
	req, _ := http.NewRequest("GET", url, nil)
	req.Header.Set("Authorization", "key "+c.APIKey)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("api error: %s", resp.Status)
	}

	var details MinifigDetails
	if err := json.NewDecoder(resp.Body).Decode(&details); err != nil {
		return nil, err
	}

	return &details, nil
}
