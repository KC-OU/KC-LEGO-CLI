package auth

import (
	"database/sql"
	"errors"
	"golang.org/x/crypto/bcrypt"
	"lego-manager/internal/models"
)

func HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 14)
	return string(bytes), err
}

func CheckPasswordHash(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

func ChangePassword(db *sql.DB, userID int, newPassword string) error {
	hash, err := HashPassword(newPassword)
	if err != nil {
		return err
	}
	_, err = db.Exec("UPDATE users SET password_hash = ?, password_changed = ? WHERE id = ?", hash, true, userID)
	return err
}

func Login(db *sql.DB, username, password string) (*models.User, error) {
	var user models.User
	query := `SELECT id, username, COALESCE(user_id, ''), password_hash, first_name, last_name, role, disabled, password_changed FROM users WHERE username = ? OR user_id = ?`
	err := db.QueryRow(query, username, username).Scan(&user.ID, &user.Username, &user.UserID, &user.PasswordHash, &user.FirstName, &user.LastName, &user.Role, &user.Disabled, &user.PasswordChanged)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, errors.New("user not found")
		}
		return nil, err
	}

	if user.Disabled {
		return nil, errors.New("account is disabled")
	}

	if !CheckPasswordHash(password, user.PasswordHash) {
		return nil, errors.New("invalid password")
	}

	return &user, nil
}
