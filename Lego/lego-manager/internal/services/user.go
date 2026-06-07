package services

import (
	"database/sql"
	"lego-manager/internal/auth"
	"lego-manager/internal/models"
	"math/rand"
	"strconv"
	"time"
)

type UserService struct {
	DB *sql.DB
}

func NewUserService(db *sql.DB) *UserService {
	return &UserService{DB: db}
}

func (s *UserService) ListUsers() ([]models.User, error) {
	rows, err := s.DB.Query("SELECT id, username, COALESCE(user_id, ''), first_name, last_name, role, disabled, password_changed FROM users")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var user models.User
		if err := rows.Scan(&user.ID, &user.Username, &user.UserID, &user.FirstName, &user.LastName, &user.Role, &user.Disabled, &user.PasswordChanged); err != nil {
			return nil, err
		}
		users = append(users, user)
	}
	return users, nil
}

func (s *UserService) CreateUser(username, firstName, lastName, role string) error {
	userID := generateUserID()
	hash, err := auth.HashPassword("12345") // Default password
	if err != nil {
		return err
	}

	query := `INSERT INTO users (username, user_id, password_hash, first_name, last_name, role, password_changed) 
			  VALUES (?, ?, ?, ?, ?, ?, ?)`
	_, err = s.DB.Exec(query, username, userID, hash, firstName, lastName, role, false)
	return err
}

func (s *UserService) DeleteUser(id int) error {
	_, err := s.DB.Exec("DELETE FROM users WHERE id = ?", id)
	return err
}

func (s *UserService) SetDisabled(id int, disabled bool) error {
	_, err := s.DB.Exec("UPDATE users SET disabled = ? WHERE id = ?", disabled, id)
	return err
}

func (s *UserService) SetRole(id int, role string) error {
	_, err := s.DB.Exec("UPDATE users SET role = ? WHERE id = ?", role, id)
	return err
}

func (s *UserService) ResetPassword(id int) error {
	hash, err := auth.HashPassword("12345")
	if err != nil {
		return err
	}
	_, err = s.DB.Exec("UPDATE users SET password_hash = ?, password_changed = ? WHERE id = ?", hash, false, id)
	return err
}

func (s *UserService) SetUserID(id int, userID string) error {
	_, err := s.DB.Exec("UPDATE users SET user_id = ? WHERE id = ?", userID, id)
	return err
}

func (s *UserService) GetSetting(key string) string {
	var value string
	s.DB.QueryRow("SELECT value FROM settings WHERE key = ?", key).Scan(&value)
	return value
}

func (s *UserService) SaveSetting(key, value string) error {
	_, err := s.DB.Exec("INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)", key, value)
	return err
}

func generateUserID() string {
	rand.Seed(time.Now().UnixNano())
	return strconv.Itoa(1000 + rand.Intn(9999999-1000))
}
