def change_user_id(admin_user, current_username, mode):
    if admin_user["role"] != "admin":
        cprint("Only admins can change user IDs.", Colors.FAIL)
        time.sleep(1.5)
        return
    clear_screen()
    cprint("===== Change User ID =====", Colors.HEADER)
    users = load_users(mode)
    print("Current Users:")
    print("{:<15} {:<10} {:<20} {:<10}".format("Username", "User ID", "Name", "Role"))
    print("-" * 60)
    for username, user_data in users.items():
        print("{:<15} {:<10} {:<20} {:<10}".format(
            username,
            user_data.get("user_id", ""),
            f"{user_data['first_name']} {user_data['last_name']}",
            user_data['role']
        ))
    print("\nEnter the username or user ID to change (or leave blank to cancel):")
    input_value = input("Username or User ID: ").strip()
    if not input_value:
        cprint("Operation cancelled.", Colors.WARNING)
        time.sleep(1)
        return
    username_to_change, user_to_change = find_user_by_username_or_id(users, input_value)
    if not user_to_change:
        cprint(f"User '{input_value}' not found.", Colors.FAIL)
        time.sleep(1.5)
        return
    if username_to_change == current_username:
        cprint("You cannot change your own user ID.", Colors.FAIL)
        time.sleep(1.5)
        return
    while True:
        new_user_id = input("Enter new User ID (4-7 digits): ").strip()
        if not new_user_id.isdigit() or not (4 <= len(new_user_id) <= 7):
            cprint("User ID must be 4 to 7 digits.", Colors.FAIL)
            continue
        # Check if new_user_id is already used
        if any(udata.get("user_id") == new_user_id for uname, udata in users.items()):
            cprint("This User ID is already in use.", Colors.FAIL)
            continue
        break
    users[username_to_change]["user_id"] = new_user_id
    save_users(users, mode)
    cprint(f"User ID for '{username_to_change}' changed to '{new_user_id}'.", Colors.OKGREEN)
    input("Press Enter to continue...")
