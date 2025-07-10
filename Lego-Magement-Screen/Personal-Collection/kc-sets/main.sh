#!/usr/bin/env python3
import os
import json
import getpass
import time
import hashlib
import re
from datetime import datetime
import sys
import random
import signal

INACTIVITY_TIMEOUT = 180  # Default inactivity timeout in seconds
### Adding Themes

THEMES = [
    "Animal Crossing",
    "Architecture",
    "Art",
    "Batman",
    "Bluey",
    "Botanical Collection",
    "Braille Bricks",
    {"BrickHeads": [
        "Avatar", "Back to the Future", "Despicable Me and Minons", "Disney", "Fortnite", "Ghostbusters", "Harry Potter",
        "Holiday & Event", "Jurassic World", "Looney Tunes", "Minecraft", "Monkie Kid", "Ninjago", "Pets",
        "Pirates of the Caribbean", "Sonic the Hedgehog", "Sports", "Star Wars", "Stranger Things", "Super Heroes",
        "The Hobbit and The Lord of the Rings", "The Incredibles", "The LEGO Movie 2", "The LEGO NINJAGO Movie",
        "The Simpsons", "Tom and Jerry", "Toy Story", "Transformers", "Universal Monsters", "WALL-E", "Wednesday"
    ]},
    "City",
    "Classic",
    "Creator 3in1",
    "DC",
    "Despicable Me 4",
    "Disney",
    "DreamZzz",
    "Duplo",
    "Education",
    "Friends",
    "Fortnite",
    "Gabby's Dollhouse",
    {"Harry Potter": [
        "Chamber of Secrets", "Deathly Hallows", "Fantastic Beasts", "Goblet of Fire", "Half-Blood Prince",
        "Hogwarts Moment", "Mini", "Order of the Phoenix", "Prisoner of Azkaban", "Sculptures", "Sorcerer's Stone"
    ]},
    "Icons",
    "Ideas",
    "Jurassic World",
    "Lord of the Rings",
    "Minecraft",
    "Minifigures",
    "Monkie Kid",
    "Nike Collection",
    {"Ninjago": [
        "Other", "Core", "Crystalized", "Day of the Departed", "Dragons Rising Season 1", "Dragons Rising Season 2",
        "Dragons Rising Season 3", "Hunted", "Legacy", "March of the Oni", "Master of the Mountain", "NINJAGO Legends",
        "Possession", "Prime Empire", "Rebooted", "Rise of the Snakes", "Seabound", "Secrets of the Forbidden Spinjitzu",
        "Skybound", "Sons of Garmadon", "Spinjitzu", "The Final Battle", "The Golden Weapons", "The Hands of Time",
        "The Island", "Tournament of Elements"
    ]},
    "One Piece",
    "Powered UP",
    "Serious Play",
    "Sonic the Hedgehog",
    "Speed Champions",
    {"Star Wars": [
        "Boost", "Buildable Figures", "Diorama Collection", "Helmet Collection", "Master Builder Series",
        "Microfighters Series 1", "Microfighters Series 2", "Microfighters Series 3", "Microfighters Series 4",
        "Microfighters Series 5", "Microfighters Series 6", "Microfighters Series 7", "Microfighters Series 8",
        {"Mini (158)": [
            "Star Wars Episode 1", "Star Wars Episode 2", "Star Wars Episode 3", "Star Wars Episode 4/5/6",
            "Star Wars Episode 7", "Star Wars Episode 8", "Star Wars Episode 9", "Star Wars Obi-Wan Kenobi",
            "Star Wars Rebels", "Star Wars Rogue One", "Star Wars Solo", "Star Wars The Bad Batch",
            "Star Wars The Clone Wars", "Star Wars The Mandalorian"
        ]},
        "Planets Series 1", "Planets Series 2", "Planets Series 3", "Planets Series 4", "Promotional", "Sculptures",
        "Star Wars Ahsoka", "Star Wars Andor", "Star Wars Battlefront", "Star Wars Episode 1", "Star Wars Episode 2",
        "Star Wars Episode 3", "Star Wars Episode 4/5/6", "Star Wars Episode 7", "Star Wars Episode 8",
        "Star Wars Episode 9", "Star Wars Galaxy's Edge", "Star Wars Legends",
        {"Star Wars Knights of the Old Republic": [
            "Star Wars The Force Unleashed", "Star Wars The Old Republic"
        ]},
        "Star Wars Obi-Wan Kenobi", "Star Wars Other", "Star Wars Mechs", "Star Wars Rebuild the Galaxy",
        "Star Wars The Freemaker Adventures", "Star Wars Rebels", "Star Wars Resistance", "Star Wars Rogue One",
        "Star Wars Skeleton Crew", "Star Wars Solo", "Star Wars The Bad Batch", "Star Wars The Book of Boba Fett",
        "Star Wars The Clone Wars", "Star Wars The Mandalorian", "Star Wars Yoda Chronicles",
        "Star Wars Young Jedi Adventures", "Starship Collection", "Ultimate Collector Series"
    ]},
    {"SuperMario": [
        "Mario Kart", "Sculptures", "Super Mario Expansion Set", "Super Mario Maker Set", "Super Mario Power-Up Pack",
        "Super Mario Series 1", "Super Mario Series 2", "Super Mario Series 3", "Super Mario Series 4",
        "Super Mario Series 5", "Super Mario Series 6", "Super Mario Starter Course"
    ]},
    {"Technic": [
        "Arctic Technic", "Competition", "Expert Builder", "Model 395", "Airport", "Construction", "Farm", "Fire",
        "Harbor", "Off-Road", "Police", "Race", "Riding Cycle", "Robot", "Space Exploration", "Traffic", "RoboRiders",
        "Speed Slammers", "Star Wars", "Super Heroes", "Supplemental", "Throwbot / Slizer", "Universal Building Set"
    ]},
    "The Legend of Zelda",
    "Wednesday",
    "Wicked",
    {"SpiderMan": ["Spider Man 1", "Spider Man 2"]},
    {"Super Heroes": [
        "Ant-Man", "Ant-Man and the Wasp", "Ant-Man and the Wasp Quantumania", "Aquaman", "Avengers",
        "Avengers Age of Ultron", "Avengers Assemble", "Avengers Endgame", "Avengers Infinity War",
        "Batman Classic TV Series", "Batman II", "Batman The Animated Series", "Black Panther",
        "Black Panther Wakanda Forever", "Black Widow", "Buildable Figures", "Bust Collection",
        "Captain America Brave New World", "Captain America Civil War", "Captain Marvel", "Dawn of Justice",
        "Doctor Strange", "Doctor Strange in the Multiverse of Madness", "Eternals", "Ghost Rider",
        "Guardians of the Galaxy", "Guardians of the Galaxy Vol. 2", "Guardians of the Galaxy Vol. 3",
        "Iron Man 3", "Justice League", "Legends of Tomorrow", "Man of Steel", "Mighty Micros", "Sculpture",
        "Shang-Chi", "Spider-Man", "Spider-Man Across the Spider-Verse", "Spider-Man Far From Home",
        "Spider-Man Homecoming", "Spider-Man No Way Home", "Spidey and his Amazing Friends", "Super Heroes Other",
        "Superman", "The Avengers", "The Batman", "The Dark Knight Trilogy", "The Fantastic Four First Steps",
        "The Infinity Saga", "The LEGO Batman Movie", "The Marvels", "Thor Love and Thunder", "Thor Ragnarok",
        "Tim Burton's Batman", "Ultimate Spider-Man", "What If...?", "Wonder Woman", "Wonder Woman 1984",
        "Wonder Woman Comic", "X-Men"
    ]},
    "Other"
]



# ANSI color codes for better UI
class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def cprint(text, color=Colors.ENDC, end='\n'):
    print(f"{color}{text}{Colors.ENDC}", end=end)

# Define the data files
USERS_FILE = "users.json"
SETS_FILE = "sets.json"
CONFIG_DIR = os.path.expanduser("~/.kc-sets")

# Ensure the config directory exists
if not os.path.exists(CONFIG_DIR):
    os.makedirs(CONFIG_DIR)

USERS_PATH = os.path.join(CONFIG_DIR, USERS_FILE)
SETS_PATH = os.path.join(CONFIG_DIR, SETS_FILE)

# Initialize default data files if they don't exist
if not os.path.exists(USERS_PATH):
    with open(USERS_PATH, 'w') as f:
        json.dump({
            "admin": {
                "password": hashlib.sha256("12345".encode()).hexdigest(),
                "first_name": "Admin",
                "last_name": "User",
                "role": "admin",
                "password_changed": False,
                "disabled": False
            }
        }, f, indent=4)

if not os.path.exists(SETS_PATH):
    with open(SETS_PATH, 'w') as f:
        json.dump([], f, indent=4)

def clear_screen():
    """Clear the terminal screen."""
    os.system('cls' if os.name == 'nt' else 'clear')

def hash_password(password):
    """Hash a password using SHA-256."""
    return hashlib.sha256(password.encode()).hexdigest()

def generate_user_id(existing_ids):
    """Generate a unique 4-7 digit user ID."""
    while True:
        user_id = str(random.randint(1000, 9999999))
        if user_id not in existing_ids:
            return user_id

def load_users():
    """Load users from the users file."""
    with open(USERS_PATH, 'r') as f:
        return json.load(f)

def save_users(users):
    """Save users to the users file."""
    with open(USERS_PATH, 'w') as f:
        json.dump(users, f, indent=4)

def load_sets():
    """Load sets from the sets file."""
    with open(SETS_PATH, 'r') as f:
        return json.load(f)

def save_sets(sets):
    """Save sets to the sets file."""
    with open(SETS_PATH, 'w') as f:
        json.dump(sets, f, indent=4)

def get_user_by_id(users, user_id):
    for username, user in users.items():
        if user.get("user_id") == user_id:
            return username, user
    return None, None

def get_user_by_username_or_id(users, value):
    """Return (username, user) by username or user_id."""
    user = users.get(value)
    if user:
        return value, user
    return get_user_by_id(users, value)

def login():
    """Handle user login."""
    clear_screen()
    cprint("===== KC-Sets Login =====", Colors.HEADER)
    users = load_users()
    enter_count = 0
    while True:
        username_or_id = input("Username or UserID: ").strip()
        if username_or_id == "":
            enter_count += 1
            if enter_count == 2:
                cprint("Do you want to exit the script? (y/n)", Colors.WARNING)
                resp = input("> ").strip().lower()
                if resp == "y":
                     return "__EXIT__"  # Signal to exit the script
                else:
                    enter_count = 0
                    continue
            continue
        enter_count = 0
        user = users.get(username_or_id)
        if not user:
            uname, user = get_user_by_id(users, username_or_id)
            if uname:
                username_or_id = uname
        if not user:
            cprint("Invalid username or user ID.", Colors.FAIL)
            time.sleep(1.5)
            return None
        if user.get("disabled", False):
            cprint("This user account is disabled. Contact an admin.", Colors.FAIL)
            time.sleep(2)
            return None
        password = getpass.getpass("Password: ")
        hashed_password = hash_password(password)
        if user["password"] == hashed_password:
            if not user.get("password_changed", False):
                clear_screen()
                cprint("You must change your default password.", Colors.WARNING)
                while True:
                    new_password = getpass.getpass("New Password: ")
                    confirm_password = getpass.getpass("Confirm Password: ")
                    if new_password == confirm_password and new_password != "12345":
                        user["password"] = hash_password(new_password)
                        user["password_changed"] = True
                        save_users(users)
                        cprint("Password changed successfully!", Colors.OKGREEN)
                        time.sleep(1.5)
                        break
                    else:
                        cprint("Passwords do not match or you're using the default password. Try again.", Colors.FAIL)
            return user
        else:
            cprint("Invalid password.", Colors.FAIL)
            time.sleep(1.5)
            return None

def create_user(admin_user):
    """Create a new user (admin only)."""
    if admin_user["role"] != "admin":
        cprint("Only admins can create users.", Colors.FAIL)
        time.sleep(1.5)
        return

    clear_screen()
    cprint("===== Create New User =====", Colors.HEADER)
    first_name = input("First Name: ").strip()
    last_name = input("Last Name: ").strip()
    users = load_users()
    existing_ids = [u.get("user_id") for u in users.values()]
    user_id = generate_user_id(existing_ids)
    username = (first_name[0] + last_name).lower()
    username = re.sub(r'\W+', '', username)
    role = ""
    while role not in ["admin", "user"]:
        role = input("Role (admin/user): ").strip().lower()
    if username in users:
        cprint(f"User {username} already exists.", Colors.WARNING)
        time.sleep(1.5)
        return
    users[username] = {
        "user_id": user_id,
        "password": hash_password("12345"),
        "first_name": first_name,
        "last_name": last_name,
        "role": role,
        "password_changed": False,
        "disabled": False
    }
    save_users(users)
    cprint(f"User {username} created with UserID {user_id} and default password '12345'.", Colors.OKGREEN)
    input("Press Enter to continue...")

def list_users(admin_user):
    """List all users (admin only)."""
    if admin_user["role"] != "admin":
        cprint("Only admins can view the user list.", Colors.FAIL)
        time.sleep(1.5)
        return
    clear_screen()
    cprint("===== User List =====", Colors.HEADER)
    users = load_users()
    print("{:<8} {:<15} {:<20} {:<10}".format("UserID", "Username", "Name", "Role"))
    print("-" * 75)
    for username, user_data in users.items():
        print("{:<8} {:<15} {:<20} {:<10}".format(
            user_data.get("user_id", ""),
            username,
            f"{user_data['first_name']} {user_data['last_name']}",
            user_data['role']
        ))
    input("\nPress Enter to continue...")

def list_specific_user(admin_user):
    """List a specific user by Username or UserID (admin only)."""
    if admin_user["role"] != "admin":
        cprint("Only admins can view user details.", Colors.FAIL)
        time.sleep(1.5)
        return
    clear_screen()
    cprint("===== View User Details =====", Colors.HEADER)
    users = load_users()
    value = input("Enter Username or UserID: ").strip()
    uname, user = get_user_by_username_or_id(users, value)
    if not user:
        cprint(f"User '{value}' not found.", Colors.FAIL)
        time.sleep(1.5)
        return
    print("{:<8} {:<15} {:<20} {:<10}".format("UserID", "Username", "Name", "Role"))
    print("-" * 75)
    print("{:<8} {:<15} {:<20} {:<10}".format(
        user.get("user_id", ""),
        uname,
        f"{user['first_name']} {user['last_name']}",
        user['role']
    ))
    input("\nPress Enter to continue...")

def remove_user(admin_user, current_username):
    """Remove a user (admin only)."""
    if admin_user["role"] != "admin":
        cprint("Only admins can remove users.", Colors.FAIL)
        time.sleep(1.5)
        return
    clear_screen()
    cprint("===== Remove User =====", Colors.HEADER)
    users = load_users()
    print("{:<8} {:<15} {:<20} {:<10}".format("UserID", "Username", "Name", "Role"))
    print("-" * 75)
    for username, user_data in users.items():
        print("{:<8} {:<15} {:<20} {:<10}".format(
            user_data.get("user_id", ""),
            username,
            f"{user_data['first_name']} {user_data['last_name']}",
            user_data['role']
        ))
    print("\nEnter the UserID or Username to remove (or leave blank to cancel):")
    value = input("UserID or Username: ").strip()
    if not value:
        cprint("Operation cancelled.", Colors.WARNING)
        time.sleep(1)
        return
    uname, user = get_user_by_username_or_id(users, value)
    if not user:
        cprint(f"User '{value}' not found.", Colors.FAIL)
        time.sleep(1.5)
        return
    if uname == current_username:
        cprint("You cannot remove your own account.", Colors.FAIL)
        time.sleep(1.5)
        return
    if user["role"] == "admin":
        admin_count = sum(1 for u in users.values() if u["role"] == "admin")
        if admin_count <= 1:
            cprint("Cannot remove the only admin user.", Colors.FAIL)
            time.sleep(1.5)
            return
    print(f"\nUser Details:")
    print(f"Name: {user['first_name']} {user['last_name']}")
    print(f"Role: {user['role']}")
    confirm = input("\nAre you sure you want to remove this user? (y/n): ").strip().lower()
    if confirm == 'y':
        del users[uname]
        save_users(users)
        cprint(f"User '{uname}' removed successfully.", Colors.OKGREEN)
    else:
        cprint("Removal cancelled.", Colors.WARNING)
    input("Press Enter to continue...")

def disable_enable_user(admin_user, current_username):
    """Disable or enable a user (admin only)."""
    if admin_user["role"] != "admin":
        cprint("Only admins can disable/enable users.", Colors.FAIL)
        time.sleep(1.5)
        return
    clear_screen()
    cprint("===== Disable/Enable User =====", Colors.HEADER)
    users = load_users()
    print("{:<8} {:<15} {:<20} {:<10}".format("UserID", "Username", "Name", "Disabled"))
    print("-" * 60)
    for username, user_data in users.items():
        print("{:<8} {:<15} {:<20} {:<10}".format(
            user_data.get("user_id", ""),
            username,
            f"{user_data['first_name']} {user_data['last_name']}",
            "Yes" if user_data.get("disabled", False) else "No"
        ))
    print("\nEnter the UserID or Username to disable/enable (or leave blank to cancel):")
    value = input("UserID or Username: ").strip()
    if not value:
        cprint("Operation cancelled.", Colors.WARNING)
        time.sleep(1)
        return
    uname, user = get_user_by_username_or_id(users, value)
    if not user:
        cprint(f"User '{value}' not found.", Colors.FAIL)
        time.sleep(1.5)
        return
    if uname == current_username:
        cprint("You cannot disable your own account.", Colors.FAIL)
        time.sleep(1.5)
        return
    user["disabled"] = not user.get("disabled", False)
    state = "disabled" if user["disabled"] else "enabled"
    save_users(users)
    cprint(f"User '{uname}' has been {state}.", Colors.OKGREEN)
    input("Press Enter to continue...")

def change_user_role(admin_user, current_username):
    """Change a user's role (admin only)."""
    if admin_user["role"] != "admin":
        cprint("Only admins can change user roles.", Colors.FAIL)
        time.sleep(1.5)
        return
    clear_screen()
    cprint("===== Change User Role =====", Colors.HEADER)
    users = load_users()
    print("{:<8} {:<15} {:<20} {:<10}".format("UserID", "Username", "Name", "Role"))
    print("-" * 60)
    for username, user_data in users.items():
        print("{:<8} {:<15} {:<20} {:<10}".format(
            user_data.get("user_id", ""),
            username,
            f"{user_data['first_name']} {user_data['last_name']}",
            user_data['role']
        ))
    print("\nEnter the UserID or Username to change role (or leave blank to cancel):")
    value = input("UserID or Username: ").strip()
    if not value:
        cprint("Operation cancelled.", Colors.WARNING)
        time.sleep(1)
        return
    uname, user = get_user_by_username_or_id(users, value)
    if not user:
        cprint(f"User '{value}' not found.", Colors.FAIL)
        time.sleep(1.5)
        return
    if uname == current_username:
        cprint("You cannot change your own role.", Colors.FAIL)
        time.sleep(1.5)
        return
    new_role = ""
    while new_role not in ["admin", "user"]:
        new_role = input("New Role (admin/user): ").strip().lower()
    user["role"] = new_role
    save_users(users)
    cprint(f"User '{uname}' role changed to {new_role}.", Colors.OKGREEN)
    input("Press Enter to continue...")

def edit_user_id(admin_user, current_username):
    """Edit a user's UserID (admin only)."""
    if admin_user["role"] != "admin":
        cprint("Only admins can edit user IDs.", Colors.FAIL)
        time.sleep(1.5)
        return
    clear_screen()
    cprint("===== Edit UserID =====", Colors.HEADER)
    users = load_users()
    print("{:<8} {:<15} {:<20}".format("UserID", "Username", "Name"))
    print("-" * 50)
    for username, user_data in users.items():
        print("{:<8} {:<15} {:<20}".format(
            user_data.get("user_id", ""),
            username,
            f"{user_data['first_name']} {user_data['last_name']}"
        ))
    print("\nEnter the UserID or Username to edit (or leave blank to cancel):")
    value = input_with_timeout("UserID or Username: ")
    if not value:
        cprint("Operation cancelled.", Colors.WARNING)
        time.sleep(1)
        return
    uname, user = get_user_by_username_or_id(users, value)
    if not user:
        cprint(f"User '{value}' not found.", Colors.FAIL)
        time.sleep(1.5)
        return
    # Admin can now edit their own UserID
    existing_ids = [u.get("user_id") for u in users.values()]
    while True:
        new_id = input_with_timeout("Enter new UserID (4-7 digits): ").strip()
        if not new_id.isdigit() or not (4 <= len(new_id) <= 7) or new_id in existing_ids:
            cprint("Invalid or duplicate UserID. Try again.", Colors.FAIL)
        else:
            break
    user["user_id"] = new_id
    save_users(users)
    cprint(f"UserID for '{uname}' changed to {new_id}.", Colors.OKGREEN)
    input_with_timeout("Press Enter to continue...")

def reset_user_password(admin_user, current_username):
    """Reset a user's password (admin only, with override for self)."""
    if admin_user["role"] != "admin":
        cprint("Only admins can reset passwords.", Colors.FAIL)
        time.sleep(1.5)
        return
    clear_screen()
    cprint("===== Reset User Password =====", Colors.HEADER)
    users = load_users()
    print("{:<8} {:<15} {:<20}".format("UserID", "Username", "Name"))
    print("-" * 50)
    for username, user_data in users.items():
        print("{:<8} {:<15} {:<20}".format(
            user_data.get("user_id", ""),
            username,
            f"{user_data['first_name']} {user_data['last_name']}"
        ))
    print("\nEnter the UserID or Username to reset password (or leave blank to cancel):")
    value = input("UserID or Username: ").strip()
    if not value:
        cprint("Operation cancelled.", Colors.WARNING)
        time.sleep(1)
        return
    uname, user = get_user_by_username_or_id(users, value)
    if not user:
        cprint(f"User '{value}' not found.", Colors.FAIL)
        time.sleep(1.5)
        return

    # If admin is resetting their own password, require override login
    if uname == current_username:
        cprint("Admin override required to reset your own password.", Colors.WARNING)
        override_id = input("Re-enter your UserID: ").strip()
        override_pass = getpass.getpass("Re-enter your password: ")
        # Find admin user by user_id
        admin_uname, admin_user_check = get_user_by_id(users, override_id)
        if not admin_user_check or admin_uname != current_username:
            cprint("Override failed: UserID does not match your account.", Colors.FAIL)
            time.sleep(1.5)
            return
        if admin_user_check["password"] != hash_password(override_pass):
            cprint("Override failed: Incorrect password.", Colors.FAIL)
            time.sleep(1.5)
            return

    user["password"] = hash_password("12345")
    user["password_changed"] = False
    save_users(users)
    cprint(f"Password for '{uname}' reset to default ('12345').", Colors.OKGREEN)
    input("Press Enter to continue...")

def add_set():
    """Add a new Lego set."""
    clear_screen()
    cprint("===== Add Lego Set =====", Colors.HEADER)

    set_id = input("Set ID (Required): ").strip()
    if not set_id:
        cprint("Set ID is required.", Colors.FAIL)
        time.sleep(1.5)
        return

    sets = load_sets()
    for s in sets:
        if s["set_id"] == set_id:
            cprint(f"Set with ID {set_id} already exists. Use Edit instead.", Colors.WARNING)
            time.sleep(1.5)
            return

    set_name = input("Set Name (Required): ").strip()
    if not set_name:
        cprint("Set Name is required.", Colors.FAIL)
        time.sleep(1.5)
        return

    theme, subtheme = pick_theme()
    if subtheme:
        set_theme = f"{theme} - {subtheme}"
    else:
        set_theme = theme
    if not set_theme:
        cprint("Set Theme is required.", Colors.FAIL)
        time.sleep(1.5)
        return

    set_year = input("Set Year (Required): ").strip()
    if not set_year:
        cprint("Set Year is required.", Colors.FAIL)
        time.sleep(1.5)
        return

    instruction_book_number = input("Lego Set Instruction Book Number (Optional): ").strip()

    while True:
        try:
            instruction_book_count = int(input("How many instruction books (Required): ").strip())
            if instruction_book_count < 0:
                raise ValueError
            break
        except ValueError:
            cprint("Please enter a valid number.", Colors.FAIL)

    while True:
        try:
            set_qty = int(input("How many of the set do I have (Required): ").strip())
            if set_qty < 0:
                raise ValueError
            break
        except ValueError:
            cprint("Please enter a valid number.", Colors.FAIL)

    while True:
        try:
            parts_qty = int(input("Qty of Parts in the set (Required): ").strip())
            if parts_qty < 0:
                raise ValueError
            break
        except ValueError:
            cprint("Please enter a valid number.", Colors.FAIL)

    part_out = input("Have you parted out this set and kept only the missing parts? (yes/no): ").strip().lower()
    part_out_info = {}
    if part_out == "yes":
        while True:
            try:
                total_parts_counted = int(input("Total Parts Counted (Required): ").strip())
                if total_parts_counted < 0:
                    raise ValueError
                break
            except ValueError:
                cprint("Please enter a valid number.", Colors.FAIL)
        while True:
            try:
                parts_missing = int(input("Parts Missing (Required): ").strip())
                if parts_missing < 0:
                    raise ValueError
                break
            except ValueError:
                cprint("Please enter a valid number.", Colors.FAIL)
        cost_bricklink = input("Cost of parts on Bricklink - If Missing (Optional): ").strip()
        cost_lego = input("Cost of parts on Lego - If Missing (Optional): ").strip()
        part_out_info = {
            "total_parts_counted": total_parts_counted,
            "parts_missing": parts_missing,
            "cost_bricklink": cost_bricklink,
            "cost_lego": cost_lego
        }

    new_set = {
        "set_id": set_id,
        "set_name": set_name,
        "set_theme": set_theme,
        "set_year": set_year,
        "instruction_book_number": instruction_book_number,
        "instruction_book_count": instruction_book_count,
        "set_qty": set_qty,
        "parts_qty": parts_qty,
        "part_out": part_out == "yes",
        "part_out_info": part_out_info,
        "created_at": datetime.now().isoformat(),
        "updated_at": datetime.now().isoformat()
    }

    sets.append(new_set)
    save_sets(sets)
    cprint(f"Set {set_id} ({set_name}) added successfully.", Colors.OKGREEN)
    input("Press Enter to continue...")

def edit_set():
    """Edit an existing Lego set."""
    clear_screen()
    cprint("===== Edit Lego Set =====", Colors.HEADER)
    
    set_id = input("Enter Set ID to edit: ").strip()
    
    sets = load_sets()
    set_index = None
    
    for i, s in enumerate(sets):
        if s["set_id"] == set_id:
            set_index = i
            break
    
    if set_index is None:
        cprint(f"Set with ID {set_id} not found.", Colors.FAIL)
        time.sleep(1.5)
        return
    
    s = sets[set_index]
    print(f"\nEditing Set: {s['set_name']} (ID: {s['set_id']})")
    
    # Display current values and get new values
    set_name = input(f"Set Name [{s['set_name']}]: ").strip()
    if set_name:
        s["set_name"] = set_name

    print(f"Current Theme: {s['set_theme']}")
    theme, subtheme = pick_theme()
    if subtheme:
        s["set_theme"] = f"{theme} - {subtheme}"
    else:
        s["set_theme"] = theme
    
    set_year = input(f"Set Year [{s['set_year']}]: ").strip()
    if set_year:
        s["set_year"] = set_year
    
    instruction_book_number = input(f"Lego Set Instruction Book Number [{s['instruction_book_number']}]: ").strip()
    if instruction_book_number:
        s["instruction_book_number"] = instruction_book_number
    
    instruction_book_count = input(f"How many instruction books [{s['instruction_book_count']}]: ").strip()
    if instruction_book_count:
        try:
            s["instruction_book_count"] = int(instruction_book_count)
        except ValueError:
            cprint("Invalid number. Keeping previous value.", Colors.WARNING)
    
    set_qty = input(f"How many of the set do I have [{s['set_qty']}]: ").strip()
    if set_qty:
        try:
            s["set_qty"] = int(set_qty)
        except ValueError:
            cprint("Invalid number. Keeping previous value.", Colors.WARNING)
    
    parts_qty = input(f"Qty of Parts in the set [{s['parts_qty']}]: ").strip()
    if parts_qty:
        try:
            s["parts_qty"] = int(parts_qty)
        except ValueError:
            cprint("Invalid number. Keeping previous value.", Colors.WARNING)
    
    part_out = input(f"Have you parted out this set and kept only the missing parts? (yes/no) [{'yes' if s.get('part_out') else 'no'}]: ").strip().lower()
    if part_out:
        s["part_out"] = part_out == "yes"
        if s["part_out"]:
            part_out_info = s.get("part_out_info", {})
            total_parts_counted = input(f"Total Parts Counted [{part_out_info.get('total_parts_counted', '')}]: ").strip()
            if total_parts_counted:
                try:
                    part_out_info["total_parts_counted"] = int(total_parts_counted)
                except ValueError:
                    cprint("Invalid number. Keeping previous value.", Colors.WARNING)
            parts_missing = input(f"Parts Missing [{part_out_info.get('parts_missing', '')}]: ").strip()
            if parts_missing:
                try:
                    part_out_info["parts_missing"] = int(parts_missing)
                except ValueError:
                    cprint("Invalid number. Keeping previous value.", Colors.WARNING)
            cost_bricklink = input(f"Cost of parts on Bricklink - If Missing [{part_out_info.get('cost_bricklink', '')}]: ").strip()
            if cost_bricklink:
                part_out_info["cost_bricklink"] = cost_bricklink
            cost_lego = input(f"Cost of parts on Lego - If Missing [{part_out_info.get('cost_lego', '')}]: ").strip()
            if cost_lego:
                part_out_info["cost_lego"] = cost_lego
            s["part_out_info"] = part_out_info
        else:
            s["part_out_info"] = {}
    s["updated_at"] = datetime.now().isoformat()
    save_sets(sets)
    
    cprint(f"Set {set_id} updated successfully.", Colors.OKGREEN)
    input("Press Enter to continue...")

def search_sets():
    """Search for Lego sets with paging, refresh, and summary."""
    while True:
        clear_screen()
        cprint("===== Search Lego Sets =====", Colors.HEADER)
        print("Enter search criteria (leave blank to skip):")
        set_id = input("Set ID: ").strip().lower()
        set_name = input("Set Name: ").strip().lower()
        print("Theme search:")
        print("1. Type theme manually")
        print("2. Pick from list")
        theme_choice = input("Choose theme input method (1/2, blank to skip): ")


        if theme_choice == "2":
            theme, subtheme = pick_theme()
            set_theme = f"{theme} - {subtheme}" if subtheme else theme
        elif theme_choice == "1":
            set_theme = input("Set Theme: ").strip()
        else:
            set_theme = ""
        set_year = input("Set Year: ").strip().lower()

        def get_results():
            sets = load_sets()
            results = []
            for s in sets:
                matches = True
                if set_id and set_id not in s["set_id"].lower():
                    matches = False
                if set_name and set_name not in s["set_name"].lower():
                    matches = False
                if set_theme and set_theme not in s["set_theme"].lower():
                    matches = False
                if set_year and set_year not in str(s["set_year"]).lower():
                    matches = False
                if matches:
                    results.append(s)
            return results

        results = get_results()
        page_size = 10
        page = 0

        while True:
            results = get_results()  # Always get fresh results for each page/refresh
            total_pages = (len(results) + page_size - 1) // page_size if results else 1
            clear_screen()
            cprint("===== Search Results =====", Colors.HEADER)
            if not results:
                cprint("No sets found matching your criteria.", Colors.WARNING)
                input("\nPress Enter to continue...")
                return
            else:
                cprint(f"Found {len(results)} set(s): (Page {page+1}/{total_pages})", Colors.OKGREEN)
                print("\n{:<12} {:<30} {:<20} {:<6} {:<8} {:<8} {:<8} {:<8}".format(
                    "Set ID", "Set Name", "Theme", "Year", "Books", "Qty", "Parts", "Parted?"))
                print("-" * 110)
                start = page * page_size
                end = start + page_size
                for s in results[start:end]:
                    print("{:<12} {:<30} {:<20} {:<6} {:<8} {:<8} {:<8} {:<8}".format(
                        s["set_id"],
                        s["set_name"][:30],
                        s["set_theme"][:20],
                        s["set_year"],
                        s["instruction_book_count"],
                        s["set_qty"],
                        s["parts_qty"],
                        "Yes" if s.get("part_out") else "No"
                    ))
                # Summary Table
                total_qty = sum(int(s.get("set_qty", 0)) for s in results)
                total_parts = sum(int(s.get("parts_qty", 0)) for s in results)
                print("\n" + "="*40 + " SUMMARY " + "="*40)
                print("{:<20} {:<20} {:<20}".format("Total Sets", "Total Qty", "Total Parts"))
                print("{:<20} {:<20} {:<20}".format(len(results), total_qty, total_parts))
                print("="*95)
                # Paging controls
                print("\n[n] Next page | [p] Previous page | [r] Refresh | [q] Quit")
                action = input("Action: ").strip().lower()
                if action == "n" and page < total_pages - 1:
                    page += 1
                elif action == "p" and page > 0:
                    page -= 1
                elif action == "q":
                    return
                elif action == "r" or action == "":
                    # Re-fetch sets and re-apply filter, stay on same page
                    continue
                else:
                    continue

def remove_set(current_user):
    """Remove a Lego set (admin override required for all users)."""
    clear_screen()
    cprint("===== Remove Lego Set =====", Colors.HEADER)

    set_id = input("Enter Set ID to remove: ").strip()
    sets = load_sets()
    set_index = None

    for i, s in enumerate(sets):
        if s["set_id"] == set_id:
            set_index = i
            set_to_remove = s
            break

    if set_index is None:
        cprint(f"Set with ID {set_id} not found.", Colors.FAIL)
        time.sleep(1.5)
        return

    print(f"\nSet Details:")
    print(f"Set Name: {set_to_remove['set_name']}")
    print(f"Theme: {set_to_remove['set_theme']}")
    print(f"Year: {set_to_remove['set_year']}")
    print(f"Instruction Book Number: {set_to_remove['instruction_book_number']}")
    print(f"Instruction Book Count: {set_to_remove['instruction_book_count']}")
    print(f"Set Qty: {set_to_remove['set_qty']}")
    print(f"Parts Qty: {set_to_remove['parts_qty']}")
    print(f"Parted Out: {'Yes' if set_to_remove.get('part_out') else 'No'}")
    if set_to_remove.get('part_out'):
        info = set_to_remove.get('part_out_info', {})
        print(f"  Total Parts Counted: {info.get('total_parts_counted', '')}")
        print(f"  Parts Missing: {info.get('parts_missing', '')}")
        print(f"  Cost Bricklink: {info.get('cost_bricklink', '')}")
        print(f"  Cost Lego: {info.get('cost_lego', '')}")

    # Admin override required
    cprint("\nAdmin override required to remove this set.", Colors.WARNING)
    users = load_users()
    admin_username = input("Admin Username or UserID: ").strip()
    admin_user = users.get(admin_username)
    if not admin_user:
        admin_uname, admin_user = get_user_by_id(users, admin_username)
    if not admin_user or admin_user.get("role") != "admin":
        cprint("Admin override failed: Not a valid admin account.", Colors.FAIL)
        time.sleep(1.5)
        return
    admin_pass = getpass.getpass("Admin Password: ")
    if admin_user["password"] != hash_password(admin_pass):
        cprint("Admin override failed: Incorrect password.", Colors.FAIL)
        time.sleep(1.5)
        return

    confirm = input("\nAre you sure you want to remove this set? (y/n): ").strip().lower()
    if confirm == 'y':
        sets.pop(set_index)
        save_sets(sets)
        cprint(f"Set {set_id} removed successfully.", Colors.OKGREEN)
    else:
        cprint("Removal cancelled.", Colors.WARNING)

    input("Press Enter to continue...")

def export_sets():
    """Export sets to a file."""
    clear_screen()
    cprint("===== Export Lego Sets =====", Colors.HEADER)
    
    format_choice = ""
    while format_choice not in ["1", "2"]:
        print("Select export format:")
        print("1. JSON")
        print("2. TXT")
        format_choice = input("Choice (1-2): ").strip()
    
    filename = input("Enter filename (without extension): ").strip()
    if not filename:
        filename = f"kc_sets_export_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    
    sets = load_sets()
    
    if format_choice == "1":  # JSON
        export_path = os.path.join(os.getcwd(), f"{filename}.json")
        with open(export_path, 'w') as f:
            json.dump(sets, f, indent=4)
    else:  # TXT
        export_path = os.path.join(os.getcwd(), f"{filename}.txt")
        with open(export_path, 'w') as f:
            f.write("KC-Sets Export - {}\n".format(datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
            f.write("\n{:<12} {:<30} {:<20} {:<6} {:<8} {:<8} {:<8} {:<8}\n".format(
                "Set ID", "Set Name", "Theme", "Year", "Books", "Qty", "Parts", "Parted?"))
            f.write("-" * 110 + "\n")
            for s in sets:
                f.write("{:<12} {:<30} {:<20} {:<6} {:<8} {:<8} {:<8} {:<8}\n".format(
                    s["set_id"],
                    s["set_name"][:30],
                    s["set_theme"][:20],
                    s["set_year"],
                    s["instruction_book_count"],
                    s["set_qty"],
                    s["parts_qty"],
                    "Yes" if s.get("part_out") else "No"
                ))
                if s.get("part_out"):
                    info = s.get("part_out_info", {})
                    f.write("    Total Parts Counted: {}\n".format(info.get("total_parts_counted", "")))
                    f.write("    Parts Missing: {}\n".format(info.get("parts_missing", "")))
                    f.write("    Cost Bricklink: {}\n".format(info.get("cost_bricklink", "")))
                    f.write("    Cost Lego: {}\n".format(info.get("cost_lego", "")))
    cprint(f"\nExport completed successfully to {export_path}", Colors.OKGREEN)
    input("Press Enter to continue...")

def admin_settings_menu():
    global INACTIVITY_TIMEOUT
    while True:
        clear_screen()
        cprint("===== Admin Settings =====", Colors.HEADER)
        print(f"1. Set inactivity timeout (current: {INACTIVITY_TIMEOUT} seconds)")
        print("2. Return to previous menu")
        try:
            choice = input_with_timeout("Enter your choice: ")
        except TimeoutError:
            cprint("Logged out due to inactivity.", Colors.WARNING)
            time.sleep(1)
            return
        if choice == "1":
            try:
                new_timeout = int(input_with_timeout("Enter new timeout in seconds: "))
                if new_timeout < 30:
                    cprint("Timeout must be at least 30 seconds.", Colors.WARNING)
                    time.sleep(1)
                else:
                    INACTIVITY_TIMEOUT = new_timeout
                    cprint(f"Inactivity timeout set to {INACTIVITY_TIMEOUT} seconds.", Colors.OKGREEN)
                    time.sleep(1)
            except (ValueError, TimeoutError):
                cprint("Invalid input or timed out.", Colors.WARNING)
                time.sleep(1)
        elif choice == "2":
            return
        else:
            cprint("Invalid choice.", Colors.WARNING)
            time.sleep(1)

def user_management_menu(admin_user, current_username):
    """Display the user management menu and handle admin choices."""
    global INACTIVITY_TIMEOUT
    while True:
        clear_screen()
        cprint("===== KC-Sets - User Management =====", Colors.HEADER)
        print("1. List Users")
        print("2. List Specific User")
        print("3. Create User")
        print("4. Remove User")
        print("5. Disable/Enable User")
        print("6. Change User Role")
        print("7. Edit UserID")
        print("8. Reset User Password")
        print(f"9. Set inactivity timeout (current: {INACTIVITY_TIMEOUT} seconds)")
        print("10. Return to Main Menu")
        choice = input_with_timeout("\nEnter your choice: ")
        if choice == "1":
            list_users(admin_user)
        elif choice == "2":
            list_specific_user(admin_user)
        elif choice == "3":
            create_user(admin_user)
        elif choice == "4":
            remove_user(admin_user, current_username)
        elif choice == "5":
            disable_enable_user(admin_user, current_username)
        elif choice == "6":
            change_user_role(admin_user, current_username)
        elif choice == "7":
            edit_user_id(admin_user, current_username)
        elif choice == "8":
            reset_user_password(admin_user, current_username)
        elif choice == "9":
            # Inline admin settings logic
            try:
                new_timeout = int(input_with_timeout("Enter new inactivity timeout in seconds: "))
                if new_timeout < 30:
                    cprint("Timeout must be at least 30 seconds.", Colors.WARNING)
                    time.sleep(1)
                else:
                    INACTIVITY_TIMEOUT = new_timeout
                    cprint(f"Inactivity timeout set to {INACTIVITY_TIMEOUT} seconds.", Colors.OKGREEN)
                    time.sleep(1)
            except (ValueError, TimeoutError):
                cprint("Invalid input or timed out.", Colors.WARNING)
                time.sleep(1)
        elif choice == "10":
            return
        else:
            cprint("Invalid choice. Please try again.", Colors.WARNING)
            time.sleep(1)

def main_menu(current_user):
    """Display the main menu and handle user choices."""
    current_username = ""
    for username, user_data in load_users().items():
        if (user_data["first_name"] == current_user["first_name"] and 
            user_data["last_name"] == current_user["last_name"] and
            user_data["role"] == current_user["role"]):
            current_username = username
            break
            
    while True:
        clear_screen()
        cprint(f"===== KC-Sets - Logged in as {current_user['first_name']} {current_user['last_name']} ({current_user['role']}) =====", Colors.OKCYAN)
        print("1. Add Lego Set")
        print("2. Edit Lego Set")
        print("3. Search Lego Sets")
        print("4. Export Sets")
        
        if current_user["role"] == "admin":
            print("5. User Management")
            print("6. Remove Lego Set (Admin approval required)")
            print("7. Logout")
            print("8. Exit")
        else:
            print("5. Remove Lego Part (Admin approval required)")  # Only standard users see this
            print("6. Logout")
            print("7. Exit")
        
        choice = input_with_timeout("\nEnter your choice: ")
        
        if current_user["role"] == "admin":
            if choice == "1":
                add_set()
            elif choice == "2":
                edit_set()
            elif choice == "3":
                search_sets()
            elif choice == "4":
                export_sets()                                                                                                                                                           
            elif choice == "5":
                user_management_menu(current_user, current_username)
            elif choice == "6":
                remove_set(current_user)
            elif choice == "7":
                cprint("Logging out...", Colors.WARNING)
                time.sleep(1)
                return True
            elif choice == "8":
                cprint("Exiting KC-Parts. Goodbye!", Colors.OKGREEN)
                return False
            else:
                cprint("Invalid choice. Please try again.", Colors.WARNING)
                time.sleep(1)
        else:
            if choice == "1":
                add_set()
            elif choice == "2":
                edit_set()
            elif choice == "3":
                search_sets()
            elif choice == "4":
                export_sets()
            elif choice == "5":
                remove_set(current_user)  # Only standard users can request removal
            elif choice == "6":
                cprint("Logging out...", Colors.WARNING)
                time.sleep(1)
                return True
            elif choice == "7":
                cprint("Exiting KC-Set. Goodbye!", Colors.OKGREEN)
                return False
            else:
                cprint("Invalid choice. Please try again.", Colors.WARNING)
                time.sleep(1)

def input_with_timeout(prompt, timeout=None):
    """Input with inactivity timeout. Returns None if timed out."""
    if timeout is None:
        timeout = INACTIVITY_TIMEOUT
    def handler(signum, frame):
        raise TimeoutError
    signal.signal(signal.SIGALRM, handler)
    signal.alarm(timeout)
    try:
        value = input(prompt)
        signal.alarm(0)
        return value
    except TimeoutError:
        print("\nSession timed out due to inactivity.")
        raise
    finally:
        signal.alarm(0)

def pick_theme(themes=THEMES):
    """
    Interactive theme picker. Returns (theme, subtheme) or (theme, None).
    """
    while True:
        clear_screen()
        cprint("Select a theme (type number, or 0 to enter a custom theme):", Colors.HEADER)
        idx = 1
        flat = []
        for t in themes:
            if isinstance(t, dict):
                main = list(t.keys())[0]
                print(f"{idx}. {main} [+]")
                flat.append((main, t[main]))
            else:
                print(f"{idx}. {t}")
                flat.append((t, None))
            idx += 1
        print("0. Other (type your own theme)")
        choice = input("Choice: ").strip()
        if choice == "0":
            custom = input("Enter your custom theme: ").strip()
            if custom:
                return (custom, None)
            else:
                continue
        try:
            choice = int(choice)
            if 1 <= choice <= len(flat):
                theme, sub = flat[choice-1]
                if sub:
                    # Subtheme picker
                    while True:
                        clear_screen()
                        cprint(f"Select a subtheme for {theme} (type number, or 0 for just '{theme}'):", Colors.HEADER)
                        for i, s in enumerate(sub, 1):
                            if isinstance(s, dict):
                                submain = list(s.keys())[0]
                                print(f"{i}. {submain} [+]")
                            else:
                                print(f"{i}. {s}")
                        print("0. Just use main theme")
                        subchoice = input("Choice: ").strip()
                        if subchoice == "0":
                            return (theme, None)
                        try:
                            subchoice = int(subchoice)
                            if 1 <= subchoice <= len(sub):
                                s_item = sub[subchoice-1]
                                if isinstance(s_item, dict):
                                    submain = list(s_item.keys())[0]
                                    # Recursively pick deeper
                                    subtheme, subsub = pick_theme([s_item])
                                    return (theme, f"{submain} - {subsub}" if subsub else submain)
                                else:
                                    return (theme, s_item)
                        except ValueError:
                            continue
                else:
                    return (theme, None)
        except ValueError:
            continue
def run_app():
    """Run the KC-Parts application."""
    continue_to_login = True

    while continue_to_login:
        current_user = login()

        if current_user:
            continue_to_login = main_menu(current_user)
        else:
            # Login failed, but we'll loop back to the login screen
            continue_to_login = True

if __name__ == "__main__":
    print("Welcome to KC-Sets!")
    run_app()