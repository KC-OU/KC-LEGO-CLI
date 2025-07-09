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


PART_CATEGORY_SECTIONS = {
    "General": [
        "Other", "Classic", "Special Assembly", "Sticker Sheet", "Stickered Assembly", "Cardboard Sleeve", "Paper", "Plastic", "Foam", "Felt"
    ],
    "Animals": [
        "Animal", "Animal, Accessory", "Animal, Air", "Animal, Body Part", "Animal, Body Part, Decorated", "Animal, Dinosaur", "Animal, Land", "Animal, Water"
    ],
    "Minifigures & Dolls": [
        "Mini Dool", "Micro Doll, Body Part", "Mini Doll, Body Part", "Mini Doll, Body Wear", "Mini Doll, Hair", "Mini Doll, Head", "Mini Doll, Head, Modified",
        "Mini Doll, Headgear", "Mini Doll, Legs", "Mini Doll, Torso", "Mini Doll, Utensil", "Minifigure", "Minifigure, Body Part", "Minifigure, Body Wear",
        "Minifigure, Hair", "Minifigure, Head", "Minifigure, Head, Modified", "Minifigure, Headgear", "Minifigure, Headgear Accessory", "Minifigure, Legs",
        "Minifigure, Legs, Decorated", "Minifigure, Legs, Modified", "Minifigure, Legs, Modified, Decorated", "Minifigure, Shield", "Minifigure, Torso",
        "Minifigure, Torso Assembly", "Minifigure, Torso Assembly, Decor.", "Minifigure, Utensil", "Minifigure, Utensil, Decorated", "Minifigure, Weapon"
    ],
    "Bricks & Plates": [
        "Brick", "Brick, Braille", "Brick, Decorated", "Brick, Modified", "Brick, Modified, Decorated", "Brick, Promotional", "Brick, Round", "Brick, Round, Decorated",
        "Plate", "Plate, Decorated", "Plate, Modified", "Plate, Modified, Decorated", "Plate, Round", "Plate, Round, Decorated"
    ],
    "Technic": [
        "Technic", "Technic, Axle", "Technic, Brick", "Technic, Connector", "Technic, Disk", "Technic, Figure Accessory", "Technic, Flex Cable", "Technic, Gear",
        "Technic, Liftarm", "Technic, Liftarm, Decorated", "Technic, Link", "Technic, Panel", "Technic, Panel, Decorated", "Technic, Pin", "Technic, Plate",
        "Technic, Shock Absorber", "Technic, Steering"
    ],
    "Vehicles & Aircraft": [
        "Aircraft", "Aircraft, Decorated", "Boat", "DUPLO, Aircraft", "DUPLO, Boat", "DUPLO, Train", "DUPLO, Vehicle", "Vehicle", "Vehicle, Base", "Vehicle, Mudguard",
        "Vehicle, Mudguard, Decorated", "Train", "Train, Track", "Monorail", "Riding Cycle", "Propeller", "Windscreen", "Windscreen, Decorated", "Wing"
    ], # ...add more sections as needed...
    }

PART_COLOR_SECTIONS = {
    "Solid Colours": [
        "White", "Very Light Gray", "Very Light Bluish Gray", "Light Bluish Gray", "Light Gray", "Dark Gray",
        "Dark Bluish Gray", "Black", "Dark Red", "Red", "Reddish Orange", "Dark Salmon", "Salmon", "Coral",
        "Light Salmon", "Sand Red", "Dark Brown", "Umber", "Brown", "Reddish Brown", "Light Brown", "Medium Brown",
        "Fabuland Brown", "Dark Tan", "Tan", "Light Nougat", "Medium Tan", "Nougat", "Medium Nougat", "Dark Nougat",
        "Sienna", "Fabuland Orange", "Earth Orange", "Dark Orange", "Rust", "Neon Orange", "Orange", "Medium Orange",
        "Light Orange", "Bright Light Orange", "Warm Yellowish Orange", "Very Light Orange", "Dark Yellow",
        "Ochre Yellow", "Yellow", "Light Yellow", "Bright Light Yellow", "Neon Yellow", "Lemon", "Neon Green",
        "Light Lime", "Yellowish Green", "Medium Lime", "Lime", "Fabuland Lime", "Olive Green", "Dark Olive Green",
        "Dark Green", "Green", "Bright Green", "Medium Green", "Light Green", "Sand Green", "Dark Turquoise",
        "Light Turquoise", "Aqua", "Light Aqua", "Dark Blue", "Blue", "Dark Azure", "Little Robots Blue", "Maersk Blue",
        "Medium Azure", "Sky Blue", "Medium Blue", "Bright Light Blue", "Light Blue", "Sand Blue", "Dark BlueViolet",
        "Violet", "BlueViolet", "Lilac", "Medium Violet", "Light Lilac", "Light Violet", "Dark Purple", "Purple",
        "Light Purple", "Medium Lavender", "Lavender", "Clikits Lavender", "Sand Purple", "Magenta", "Dark Pink",
        "Medium Dark Pink", "Bright Pink", "Pink", "Rose Pink"
    ],
    "Transparent Colours": [
        "Trans-Clear", "Trans-Brown", "Trans-Black", "Trans-Red", "Trans-Neon Orange", "Trans-Orange",
        "Trans-Light Orange", "Trans-Neon Yellow", "Trans-Yellow", "Trans-Neon Green", "Trans-Bright Green",
        "Trans-Light Green", "Trans-Light Bright Green", "Trans-Green", "Trans-Dark Blue", "Trans-Medium Blue",
        "Trans-Light Blue", "Trans-Aqua", "Trans-Light Purple", "Trans-Medium Purple", "Trans-Purple",
        "Trans-Dark Pink", "Trans-Pink"
    ],
    "Chrome Colours": [
        "Chrome Gold", "Chrome Silver", "Chrome Antique Brass", "Chrome Black", "Chrome Blue", "Chrome Green", "Chrome Pink"
    ],
    "Pearl Colours": [
        "Pearl White", "Pearl Very Light Gray", "Pearl Light Gray", "Flat Silver", "Bionicle Silver", "Pearl Dark Gray",
        "Pearl Black", "Pearl Light Gold", "Pearl Gold", "Reddish Gold", "Bionicle Gold", "Flat Dark Gold",
        "Reddish Copper", "Copper", "Bionicle Copper", "Pearl Brown", "Pearl Red", "Pearl Green", "Pearl Blue",
        "Pearl Sand Blue", "Pearl Sand Purple"
    ],
    "Satin Colours": [
        "Satin Trans-Brown", "Satin Trans-Yellow", "Satin Trans-Clear", "Satin Trans-Bright Green",
        "Satin Trans-Light Blue", "Satin Trans-Dark Blue", "Satin Trans-Purple", "Satin Trans-Dark Pink"
    ],
    "Metallic Colours": [
        "Metallic Silver", "Metallic Green", "Metallic Gold", "Metallic Copper"
    ],
    "Milky Colours": [
        "Milky White", "Glow In Dark White", "Glow In Dark Opaque", "Glow In Dark Trans"
    ],
    "Glitter Colours": [
        "Glitter Trans-Clear", "Glitter Trans-Orange", "Glitter Trans-Neon Green", "Glitter Trans-Light Blue",
        "Glitter Trans-Purple", "Glitter Trans-Dark Pink"
    ],
    "Speckle Colours": [
        "Speckle Black-Silver", "Speckle Black-Gold", "Speckle Black-Copper", "Speckle DBGray-Silver"
    ],
    "Modulex Colours": [
        "Mx White", "Mx Light Bluish Gray", "Mx Light Gray", "Mx Charcoal Gray", "Mx Tile Gray", "Mx Black",
        "Mx Tile Brown", "Mx Terracotta", "Mx Brown", "Mx Buff", "Mx Red", "Mx Pink Red", "Mx Orange",
        "Mx Light Orange", "Mx Light Yellow", "Mx Ochre Yellow", "Mx Lemon", "Mx Pastel Green", "Mx Olive Green",
        "Mx Aqua Green", "Mx Teal Blue", "Mx Tile Blue", "Mx Medium Blue", "Mx Pastel Blue", "Mx Violet",
        "Mx Pink", "Mx Clear", "Mx Foil Dark Gray", "Mx Foil Light Gray", "Mx Foil Dark Green", "Mx Foil Light Green",
        "Mx Foil Dark Blue", "Mx Foil Light Blue", "Mx Foil Violet", "Mx Foil Red", "Mx Foil Yellow", "Mx Foil Orange"
    ]
}
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
PARTS_FILE = "parts.json"
CONFIG_DIR = os.path.expanduser("~/.kc-parts")

# Ensure the config directory exists
if not os.path.exists(CONFIG_DIR):
    os.makedirs(CONFIG_DIR)

USERS_PATH = os.path.join(CONFIG_DIR, USERS_FILE)
PARTS_PATH = os.path.join(CONFIG_DIR, PARTS_FILE)

# Initialize default data files if they don't exist
# Update default admin user to include 'disabled'
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

if not os.path.exists(PARTS_PATH):
    with open(PARTS_PATH, 'w') as f:
        json.dump([], f, indent=4)

DEFAULT_TIMEOUT = 180  # seconds

TIMEOUT_FILE = "timeout.json"
TIMEOUT_PATH = os.path.join(CONFIG_DIR, TIMEOUT_FILE)

def load_timeout():
    if not os.path.exists(TIMEOUT_PATH):
        return DEFAULT_TIMEOUT
    with open(TIMEOUT_PATH, 'r') as f:
        return json.load(f).get("timeout", DEFAULT_TIMEOUT)

def save_timeout(timeout):
    with open(TIMEOUT_PATH, 'w') as f:
        json.dump({"timeout": timeout}, f, indent=4)

SESSION_TIMEOUT = load_timeout()

def clear_screen():
    """Clear the terminal screen."""
    os.system('cls' if os.name == 'nt' else 'clear')

def hash_password(password):
    """Hash a password using SHA-256."""
    return hashlib.sha256(password.encode()).hexdigest()

def load_users():
    """Load users from the users file."""
    with open(USERS_PATH, 'r') as f:
        return json.load(f)

def save_users(users):
    """Save users to the users file."""
    with open(USERS_PATH, 'w') as f:
        json.dump(users, f, indent=4)

def load_parts():
    """Load parts from the parts file."""
    with open(PARTS_PATH, 'r') as f:
        return json.load(f)

def save_parts(parts):
    """Save parts to the parts file."""
    with open(PARTS_PATH, 'w') as f:
        json.dump(parts, f, indent=4)

def generate_userid(users):
    """Generate a unique 4-7 digit UserID."""
    while True:
        userid = str(random.randint(1000, 9999999))
        if not any(u.get("userid") == userid for u in users.values()):
            return userid

def login():
    """Handle user login."""
    clear_screen()
    cprint("===== KC-Parts Login =====", Colors.HEADER)
    
    users = load_users()
    empty_count = 0
    while True:
        login_input = timeout_input("Username or UserID: ").strip()
        if login_input == "":
            empty_count += 1
            if empty_count >= 2:
                choice = input("Do you want to exit the program? (y/n): ").strip().lower()
                if choice == "y":
                    return "__EXIT__"  # Signal to exit the script
                else:
                    empty_count = 0
                    continue
            continue
        else:
            empty_count = 0

        # Find user by username or userid
        username = None
        for uname, udata in users.items():
            if uname == login_input or udata.get("userid") == login_input:
                username = uname
                break
        if not username:
            cprint("Invalid username or UserID.", Colors.FAIL)
            time.sleep(1.5)
            return None

        if users[username].get("disabled", False):
            cprint("This user account is disabled. Contact an admin.", Colors.FAIL)
            time.sleep(2)
            return None
        
        password = getpass.getpass("Password: ")
        hashed_password = hash_password(password)
        
        if users[username]["password"] == hashed_password:
            # Check if password needs to be changed
            if not users[username]["password_changed"]:
                clear_screen()
                cprint("You must change your default password.", Colors.WARNING)
                
                while True:
                    new_password = getpass.getpass("New Password: ")
                    confirm_password = getpass.getpass("Confirm Password: ")
                    
                    if new_password == confirm_password and new_password != "12345":
                        users[username]["password"] = hash_password(new_password)
                        users[username]["password_changed"] = True
                        save_users(users)
                        cprint("Password changed successfully!", Colors.OKGREEN)
                        time.sleep(1.5)
                        break
                    else:
                        cprint("Passwords do not match or you're using the default password. Try again.", Colors.FAIL)
            
            return users[username]
        else:
            cprint("Invalid password.", Colors.FAIL)
            time.sleep(1.5)
            return None

def create_user(admin_user):
    """Create a new user (admin only)."""
    if admin_user["role"] != "admin":
        cprint("Only admins can create users.", Colors.FAIL)
        time.sleep(1.5)
        input("Press Enter to continue...")
        return
    
    clear_screen()
    cprint("===== Create New User =====", Colors.HEADER)
    
    first_name = input("First Name: ").strip()
    last_name = input("Last Name: ").strip()
    
    # Generate username (first letter of first name + last name, all lowercase)
    username = (first_name[0] + last_name).lower()
    username = re.sub(r'\W+', '', username)  # Remove non-alphanumeric characters
    
    role = ""
    while role not in ["admin", "user"]:
        role = input("Role (admin/user): ").strip().lower()
    
    users = load_users()
    
    if username in users:
        cprint(f"User {username} already exists.", Colors.WARNING)
        time.sleep(1.5)
        return

    # UserID: auto-generate, but allow admin to override
    userid = generate_userid(users)
    cprint(f"Generated UserID: {userid}", Colors.OKCYAN)
    custom_id = input("Enter custom UserID (4-7 digits) or press Enter to use generated: ").strip()
    if custom_id and custom_id.isdigit() and 4 <= len(custom_id) <= 7 and not any(u.get("userid") == custom_id for u in users.values()):
        userid = custom_id

    users[username] = {
        "userid": userid,
        "password": hash_password("12345"),
        "first_name": first_name,
        "last_name": last_name,
        "role": role,
        "password_changed": False,
        "disabled": False
    }
    
    save_users(users)
    cprint(f"User {username} (UserID: {userid}) created successfully with default password '12345'.", Colors.OKGREEN)
    input("Press Enter to continue...")  # <-- This line ensures a pause

def find_username(users, login_input):
    """Find username by username or UserID."""
    for uname, udata in users.items():
        if uname == login_input or udata.get("userid") == login_input:
            return uname
    return None

def list_users(admin_user):
    """List all users or a specific user (admin only)."""
    if admin_user["role"] != "admin":
        cprint("Only admins can view the user list.", Colors.FAIL)
        time.sleep(1.5)
        return

    clear_screen()
    cprint("===== User List =====", Colors.HEADER)
    users = load_users()
    search = input("Enter Username or UserID to filter (leave blank for all): ").strip()
    print("{:<15} {:<10} {:<20} {:<15} {:<15} {:<10}".format(
        "Username", "UserID", "Name", "Role", "Password Changed", "Disabled"))
    print("-" * 90)
    if search:
        uname = find_username(users, search)
        if uname:
            user_data = users[uname]
            print("{:<15} {:<10} {:<20} {:<15} {:<15} {:<10}".format(
                uname,
                user_data.get("userid", ""),
                f"{user_data['first_name']} {user_data['last_name']}",
                user_data['role'],
                "Yes" if user_data['password_changed'] else "No",
                "Yes" if user_data.get("disabled", False) else "No"
            ))
        else:
            cprint("User not found.", Colors.FAIL)
    else:
        for username, user_data in users.items():
            print("{:<15} {:<10} {:<20} {:<15} {:<15} {:<10}".format(
                username,
                user_data.get("userid", ""),
                f"{user_data['first_name']} {user_data['last_name']}",
                user_data['role'],
                "Yes" if user_data['password_changed'] else "No",
                "Yes" if user_data.get("disabled", False) else "No"
            ))
    input("\nPress Enter to continue...")

def remove_user(admin_user, current_username):
    """Remove a user (admin only)."""
    if admin_user["role"] != "admin":
        cprint("Only admins can remove users.", Colors.FAIL)
        time.sleep(1.5)
        return

    users = load_users()
    clear_screen()
    cprint("===== Remove User =====", Colors.HEADER)
    print("Current Users:")
    print("{:<15} {:<10} {:<20}".format("Username", "UserID", "Name"))
    print("-" * 50)
    for username, user_data in users.items():
        print("{:<15} {:<10} {:<20}".format(
            username, user_data.get("userid", ""), f"{user_data['first_name']} {user_data['last_name']}"
        ))
    uname = input("\nEnter Username or UserID to remove: ").strip()
    uname = find_username(users, uname)
    if not uname:
        cprint("User not found.", Colors.FAIL)
        time.sleep(1.5)
        return
    if uname == current_username:
        cprint("You cannot remove your own account.", Colors.FAIL)
        time.sleep(1.5)
        return
    confirm = input(f"Are you sure you want to remove '{uname}'? (y/n): ").strip().lower()
    if confirm == 'y':
        users.pop(uname)
        save_users(users)
        cprint(f"User '{uname}' removed.", Colors.OKGREEN)
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
    print("Current Users:")
    print("{:<15} {:<10} {:<20} {:<10}".format("Username", "UserID", "Name", "Disabled"))
    print("-" * 55)
    for username, user_data in users.items():
        print("{:<15} {:<10} {:<20} {:<10}".format(
            username,
            user_data.get("userid", ""),
            f"{user_data['first_name']} {user_data['last_name']}",
            "Yes" if user_data.get("disabled", False) else "No"
        ))
    uname = input("\nEnter Username or UserID to disable/enable: ").strip()
    uname = find_username(users, uname)
    if not uname:
        cprint("User not found.", Colors.FAIL)
        time.sleep(1.5)
        return
    if uname == current_username:
        cprint("You cannot disable your own account.", Colors.FAIL)
        time.sleep(1.5)
        return
    users[uname]["disabled"] = not users[uname].get("disabled", False)
    state = "disabled" if users[uname]["disabled"] else "enabled"
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
    print("Current Users:")
    print("{:<15} {:<10} {:<20} {:<10}".format("Username", "UserID", "Name", "Role"))
    print("-" * 55)
    for username, user_data in users.items():
        print("{:<15} {:<10} {:<20} {:<10}".format(
            username,
            user_data.get("userid", ""),
            f"{user_data['first_name']} {user_data['last_name']}",
            user_data['role']
        ))
    uname = input("\nEnter Username or UserID to change role: ").strip()
    uname = find_username(users, uname)
    if not uname:
        cprint("User not found.", Colors.FAIL)
        time.sleep(1.5)
        return
    if uname == current_username:
        cprint("You cannot change your own role.", Colors.FAIL)
        time.sleep(1.5)
        return
    new_role = ""
    while new_role not in ["admin", "user"]:
        new_role = input("New Role (admin/user): ").strip().lower()
    users[uname]["role"] = new_role
    save_users(users)
    cprint(f"User '{uname}' role changed to {new_role}.", Colors.OKGREEN)
    input("Press Enter to continue...")

def edit_userid(admin_user):
    """Allow admin to change a user's UserID."""
    if admin_user["role"] != "admin":
        cprint("Only admins can change UserIDs.", Colors.FAIL)
        time.sleep(1.5)
        input("Press Enter to continue...")
        return
    users = load_users()
    clear_screen()
    cprint("===== Edit UserID =====", Colors.HEADER)
    print("Current Users:")
    print("{:<15} {:<10} {:<20}".format("Username", "UserID", "Name"))
    print("-" * 50)
    for username, user_data in users.items():
        print("{:<15} {:<10} {:<20}".format(
            username, user_data.get("userid", ""), f"{user_data['first_name']} {user_data['last_name']}"
        ))
    uname = input("\nEnter Username or UserID to change UserID: ").strip()
    uname = find_username(users, uname)
    if not uname:
        cprint("User not found.", Colors.FAIL)
        time.sleep(1.5)
        return
    new_id = input(f"Enter new UserID for {uname} (4-7 digits): ").strip()
    if not new_id.isdigit() or not (4 <= len(new_id) <= 7):
        cprint("Invalid UserID. Must be 4-7 digits.", Colors.FAIL)
        time.sleep(1.5)
        return
    users[uname]["userid"] = new_id
    save_users(users)
    cprint(f"UserID for {uname} changed to {new_id}.", Colors.OKGREEN)
    input("Press Enter to continue...")  # <-- This line ensures a pause

def reset_user_password(admin_user):
    """Allow admin to reset a user's password (forces change on next login)."""
    if admin_user["role"] != "admin":
        cprint("Only admins can reset passwords.", Colors.FAIL)
        time.sleep(1.5)
        input("Press Enter to continue...")
        return
    users = load_users()
    clear_screen()
    cprint("===== Reset User Password =====", Colors.HEADER)
    print("Current Users:")
    print("{:<15} {:<10} {:<20}".format("Username", "UserID", "Name"))
    print("-" * 50)
    for username, user_data in users.items():
        print("{:<15} {:<10} {:<20}".format(
            username, user_data.get("userid", ""), f"{user_data['first_name']} {user_data['last_name']}"
        ))
    uname = input("\nEnter Username or UserID to reset password: ").strip()
    uname = find_username(users, uname)
    if not uname:
        cprint("User not found.", Colors.FAIL)
        time.sleep(1.5)
        return
    confirm = input(f"Are you sure you want to reset the password for '{uname}'? (y/n): ").strip().lower()
    if confirm == 'y':
        users[uname]["password"] = hash_password("12345")
        users[uname]["password_changed"] = False
        save_users(users)
        cprint(f"Password for {uname} reset to default. User must change it on next login.", Colors.OKGREEN)
    else:
        cprint("Password reset cancelled.", Colors.WARNING)
    input("Press Enter to continue...")  # <-- This line ensures a pause

def user_management_menu(admin_user, current_username):
    """Display the user management menu and handle admin choices."""
    global SESSION_TIMEOUT
    while True:
        clear_screen()
        cprint("===== KC-Parts - User Management =====", Colors.HEADER)
        print("1. List Users")
        print("2. Create User")
        print("3. Remove User")
        print("4. Disable/Enable User")
        print("5. Change User Role")
        print("6. Edit UserID")
        print("7. Reset User Password")
        print("8. Set Session Timeout")
        print("9. Return to Main Menu")
        
        choice = timeout_input("\nEnter your choice: ").strip()
        
        if choice == "1":
            list_users(admin_user)
        elif choice == "2":
            create_user(admin_user)
        elif choice == "3":
            remove_user(admin_user, current_username)
        elif choice == "4":
            disable_enable_user(admin_user, current_username)
        elif choice == "5":
            change_user_role(admin_user, current_username)
        elif choice == "6":
            edit_userid(admin_user)
        elif choice == "7":
            reset_user_password(admin_user)
        elif choice == "8":
            # Set session timeout
            try:
                new_timeout = int(timeout_input("Enter new session timeout in seconds (30-3600): ").strip())
                if 30 <= new_timeout <= 3600:
                    save_timeout(new_timeout)
                    SESSION_TIMEOUT = new_timeout
                    cprint(f"Session timeout set to {new_timeout} seconds.", Colors.OKGREEN)
                else:
                    cprint("Timeout must be between 30 and 3600 seconds.", Colors.FAIL)
            except ValueError:
                cprint("Invalid input. Timeout not changed.", Colors.FAIL)
            input("Press Enter to continue...")
        elif choice == "9":
            return
        else:
            cprint("Invalid choice. Please try again.", Colors.WARNING)
            time.sleep(1)

def add_part():
    """Add a new Lego part."""
    clear_screen()
    cprint("===== Add Lego Part =====", Colors.HEADER)
    
    part_id = input("Part ID (Short Code/Design ID) [Required]: ").strip()
    if not part_id:
        cprint("Part ID is required.", Colors.FAIL)
        time.sleep(1.5)
        return
    
    # Check if the part already exists
    parts = load_parts()
    for part in parts:
        if part["part_id"] == part_id:
            cprint(f"Part with ID {part_id} already exists. Use Edit instead.", Colors.WARNING)
            time.sleep(1.5)
            return
    
    long_part_id = input("Long Part ID (Element ID): ").strip()
    part_name = input("Part Name (excluding color or category) [Required]: ").strip()
    if not part_name:
        cprint("Part Name is required.", Colors.FAIL)
        time.sleep(1.5)
        return

    # --- Category picker (was theme picker) ---
    print("\nSelect Part Category:")
    part_category = pick_category_section()
    if not part_category:
        cprint("Part Category is required.", Colors.FAIL)
        time.sleep(1.5)
        return
    # ------------------------------------------

    while True:
        try:
            part_qty = int(input("Part Quantity [Required]: ").strip())
            if part_qty < 0:
                raise ValueError
            break
        except ValueError:
            cprint("Please enter a valid quantity (positive number).", Colors.FAIL)
    
    print("\nSelect Part Color:")
    part_color = pick_color_section()
    if not part_color:
        cprint("Part Color is required.", Colors.FAIL)
        time.sleep(1.5)
        return
    
    new_part = {
        "part_id": part_id,
        "long_part_id": long_part_id,
        "part_name": part_name,
        "part_category": part_category,  # <-- Use part_category here
        "part_qty": part_qty,
        "part_color": part_color,
        "created_at": datetime.now().isoformat(),
        "updated_at": datetime.now().isoformat()
    }
    
    parts.append(new_part)
    save_parts(parts)
    
    cprint(f"Part {part_id} ({part_name}) added successfully.", Colors.OKGREEN)
    input("Press Enter to continue...")

def edit_part():
    """Edit an existing Lego part."""
    clear_screen()
    cprint("===== Edit Lego Part =====", Colors.HEADER)
    
    part_id = input("Enter Part ID to edit: ").strip()
    
    parts = load_parts()
    part_index = None
    
    for i, part in enumerate(parts):
        if part["part_id"] == part_id:
            part_index = i
            break
    
    if part_index is None:
        cprint(f"Part with ID {part_id} not found.", Colors.FAIL)
        time.sleep(1.5)
        return
    
    part = parts[part_index]
    print(f"\nEditing Part: {part['part_name']} (ID: {part['part_id']})")
    
    # Display current values and get new values
    long_part_id = input(f"Long Part ID [{part['long_part_id']}]: ").strip()
    if long_part_id:
        part["long_part_id"] = long_part_id
    
    part_name = input(f"Part Name [{part['part_name']}]: ").strip()
    if part_name:
        part["part_name"] = part_name
    
    qty_input = input(f"Part Quantity [{part['part_qty']}]: ").strip()
    if qty_input:
        try:
            qty = int(qty_input)
            if qty >= 0:
                part["part_qty"] = qty
            else:
                cprint("Quantity must be a positive number.", Colors.FAIL)
        except ValueError:
            cprint("Invalid quantity. Keeping previous value.", Colors.WARNING)

    print("\nSelect Part Category (or press Enter to keep current):")
    change_cat = input("Change category? (y/N): ").strip().lower()
    if change_cat == "y":
        part["part_category"] = pick_category_section()

    print("\nSelect Part Color (or press Enter to keep current):")
    change_col = input("Change color? (y/N): ").strip().lower()
    if change_col == "y":
        part["part_color"] = pick_color_section()
    
    part["updated_at"] = datetime.now().isoformat()
    save_parts(parts)
    
    cprint(f"Part {part_id} updated successfully.", Colors.OKGREEN)
    input("Press Enter to continue...")

def remove_part(current_user):
    """Remove a Lego part (admin override required for all users)."""
    clear_screen()
    cprint("===== Remove Lego Part =====", Colors.HEADER)
    
    part_id = input("Enter Part ID to remove: ").strip()
    parts = load_parts()
    part_index = None
    part_to_remove = None

    for i, part in enumerate(parts):
        if part["part_id"] == part_id:
            part_index = i
            part_to_remove = part
            break

    if part_index is None:
        cprint(f"Part with ID {part_id} not found.", Colors.FAIL)
        time.sleep(1.5)
        return

    print(f"\nPart Details:")
    print(f"Name: {part_to_remove['part_name']}")
    print(f"Category: {part_to_remove['part_category']}")
    print(f"Color: {part_to_remove['part_color']}")
    print(f"Quantity: {part_to_remove['part_qty']}")

    # Admin override required
    cprint("\nAdmin override required to remove this part.", Colors.WARNING)
    users = load_users()
    admin_username = input("Admin Username or UserID: ").strip()
    admin_user = users.get(admin_username)
    if not admin_user:
        # Try to find by userID
        for uname, udata in users.items():
            if udata.get("userid") == admin_username:
                admin_user = udata
                break
    if not admin_user or admin_user.get("role") != "admin":
        cprint("Admin user not found or not an admin.", Colors.FAIL)
        input("Press Enter to continue...")
        return
    admin_pass = getpass.getpass("Admin Password: ")
    if admin_user["password"] != hash_password(admin_pass):
        cprint("Incorrect admin password.", Colors.FAIL)
        input("Press Enter to continue...")
        return

    confirm = input("\nAre you sure you want to remove this part? (y/n): ").strip().lower()
    if confirm == 'y':
        parts.pop(part_index)
        save_parts(parts)
        cprint(f"Part {part_id} removed successfully.", Colors.OKGREEN)
    else:
        cprint("Removal cancelled.", Colors.WARNING)

    input("Press Enter to continue...")

def search_parts():
    """Search for Lego parts with paging, refresh, and total summary."""
    def get_filtered_results(parts, search_term, cat_filter, col_filter):
        results = []
        for part in parts:
            if ((search_term in part["part_id"].lower() or search_term in part["part_name"].lower()) and
                (not cat_filter or part["part_category"] == cat_filter) and
                (not col_filter or part["part_color"] == col_filter)):
                results.append(part)
        return results

    clear_screen()
    cprint("===== Search Lego Parts =====", Colors.HEADER)
    search_term = input("Enter part name or ID to search: ").strip().lower()
    parts = load_parts()

    print("\nFilter by Part Category? (leave blank to skip)")
    cat_filter = ""
    if input("Filter by category? (y/N): ").strip().lower() == "y":
        cat_filter = pick_category_section()

    print("\nFilter by Part Color? (leave blank to skip)")
    col_filter = ""
    if input("Filter by color? (y/N): ").strip().lower() == "y":
        col_filter = pick_color_section()

    results = get_filtered_results(parts, search_term, cat_filter, col_filter)

    if not results:
        cprint("No parts found.", Colors.WARNING)
        input("\nPress Enter to continue...")
        return

    page_size = 10
    page = 0

    while True:
        total_parts = len(results)
        total_qty = sum(part.get("part_qty", 0) for part in results)
        clear_screen()
        cprint("===== Search Results =====", Colors.OKCYAN)
        start = page * page_size
        end = start + page_size
        page_results = results[start:end]

        print("{:<10} {:<10} {:<30} {:<8} {:<15} {:<15}".format(
            "Part ID", "Long ID", "Name", "Qty", "Category", "Color"))
        print("-" * 90)
        for part in page_results:
            print("{:<10} {:<10} {:<30} {:<8} {:<15} {:<15}".format(
                part["part_id"],
                part["long_part_id"],
                part["part_name"][:30],
                part["part_qty"],
                part["part_category"][:15],
                part["part_color"][:15]
            ))

        # Show summary table at the bottom
        print("\n" + "-" * 40)
        print("{:<20} {:<10}".format("Total Results:", total_parts))
        print("{:<20} {:<10}".format("Total Quantity:", total_qty))
        print("-" * 40)

        # Paging controls
        print("\n[n] Next page | [p] Previous page | [r] Refresh | [q] Quit")
        action = input("Action: ").strip().lower()
        if action == "n":
            if end < total_parts:
                page += 1
            else:
                cprint("Already at last page.", Colors.WARNING)
                time.sleep(1)
        elif action == "p":
            if page > 0:
                page -= 1
            else:
                cprint("Already at first page.", Colors.WARNING)
                time.sleep(1)
        elif action == "r":
            # Reload parts and re-apply filter
            parts = load_parts()
            results = get_filtered_results(parts, search_term, cat_filter, col_filter)
            page = 0
            cprint("Results refreshed.", Colors.OKGREEN)
            time.sleep(1)
            if not results:
                cprint("No parts found after refresh.", Colors.WARNING)
                input("\nPress Enter to continue...")
                return
        elif action == "q":
            break
        else:
            cprint("Invalid action.", Colors.WARNING)
            time.sleep(1)

def pick_from_list(options, prompt="Choose an option:"):
    """Display a numbered picker for a list and return the selected value."""
    while True:
        for i, opt in enumerate(options, 1):
            print(f"{i}. {opt}")
        choice = input(f"{prompt} [1-{len(options)}]: ").strip()
        if choice.isdigit() and 1 <= int(choice) <= len(options):
            return options[int(choice) - 1]
        else:
            cprint("Invalid selection. Please try again.", Colors.FAIL)

def pick_category_section():
    """Pick a section, then a category within that section."""
    sections = list(PART_CATEGORY_SECTIONS.keys())
    print("\nSections:")
    for i, sec in enumerate(sections, 1):
        print(f"{i}. {sec}")
    while True:
        sec_choice = input("Select section number: ").strip()
        if sec_choice.isdigit() and 1 <= int(sec_choice) <= len(sections):
            section = sections[int(sec_choice) - 1]
            break
        else:
            cprint("Invalid section. Try again.", Colors.FAIL)
    categories = PART_CATEGORY_SECTIONS[section]
    print(f"\nCategories in {section}:")
    for i, cat in enumerate(categories, 1):
        print(f"{i}. {cat}")
    while True:
        cat_choice = input("Select category number: ").strip()
        if cat_choice.isdigit() and 1 <= int(cat_choice) <= len(categories):
            return categories[int(cat_choice) - 1]
        else:
            cprint("Invalid category. Try again.", Colors.FAIL)

def pick_color_section():
    """Pick a color section, then a color within that section."""
    sections = list(PART_COLOR_SECTIONS.keys())
    print("\nColor Sections:")
    for i, sec in enumerate(sections, 1):
        print(f"{i}. {sec}")
    while True:
        sec_choice = input("Select color section number: ").strip()
        if sec_choice.isdigit() and 1 <= int(sec_choice) <= len(sections):
            section = sections[int(sec_choice) - 1]
            break
        else:
            cprint("Invalid section. Try again.", Colors.FAIL)
    colors = PART_COLOR_SECTIONS[section]
    print(f"\nColors in {section}:")
    for i, color in enumerate(colors, 1):
        print(f"{i}. {color}")
    while True:
        color_choice = input("Select color number: ").strip()
        if color_choice.isdigit() and 1 <= int(color_choice) <= len(colors):
            return colors[int(color_choice) - 1]
        else:
            cprint("Invalid color. Try again.", Colors.FAIL)

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
        cprint(f"===== KC-Parts - Logged in as {current_user['first_name']} {current_user['last_name']} ({current_user['role']}) =====", Colors.OKCYAN)
        print("1. Add Lego Part")
        print("2. Edit Lego Part")
        print("3. Search Lego Parts")
        print("4. Export Parts")
        print("5. Remove Lego Part")  # <-- Always show this option
        print("6. Logout")
        print("7. Exit")
        
        choice = input("\nEnter your choice: ").strip()
        
        if choice == "1":
            add_part()
        elif choice == "2":
            edit_part()
        elif choice == "3":
            search_parts()
        elif choice == "4":
            export_parts()
        elif choice == "5":
            remove_part(current_user)
        elif choice == "6":
            cprint("Logging out...", Colors.WARNING)
            time.sleep(1)
            return True
        elif choice == "7":
            cprint("Exiting KC-Parts. Goodbye!", Colors.OKGREEN)
            return False
        else:
            cprint("Invalid choice. Please try again.", Colors.WARNING)
            time.sleep(1)

def run_app():
    """Run the KC-Parts application."""
    continue_to_login = True

    while continue_to_login:
        current_user = login()

        if current_user == "__EXIT__":
            cprint("Exiting KC-Parts. Goodbye!", Colors.OKGREEN)
            sys.exit(0)
        elif current_user:
            continue_to_login = main_menu(current_user)
        else:
            # Login failed, but we'll loop back to the login screen
            continue_to_login = True

# Timeout handling
class TimeoutException(Exception):
    pass

def timeout_handler(signum, frame):
    raise TimeoutException

def timeout_input(prompt, timeout=SESSION_TIMEOUT):
    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(timeout)
    try:
        value = input(prompt)
        signal.alarm(0)
        return value
    except TimeoutException:
        print("\nSession timed out due to inactivity.")
        sys.exit(0)

if __name__ == "__main__":
    print("Welcome to KC-Parts!")
    run_app()