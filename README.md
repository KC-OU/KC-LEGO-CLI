# LEGO MANAGEMENT


Create script that merges kc-parts and kc-sets in to one script and with a main menu with sectin 1 for parts and 2 for sets. not python bash only

- make only the main screen centred for more look pleasing

still keep the same login screen for each script, implement a UserID so the user user ID or username for ease of use, have the ID either auto generated or have the admin change it mainly 4 - 7 digits.

have a section in user mangament, so the admin can reset users password on logon.

allow the user-mangaemnt screen use the username and userid

- for listing as specific user
- remove user
- disable user
- change user role
- edit user id
- resest user passowrd

in the user login screen, allow the user to tap enter 2 times and it comes up with a promt saying do you want to go back to the main menu or no and it repett

- chnage user ID
- Force change user password
- create user

---

still keep the same login screen for each script, implement a UserID so the user user ID or username for ease of use, have the ID either auto generated or have the admin change it mainly 4 - 7 digits.

have a section in user mangament, so the admin can reset users password on logon.


allow the user-mangaemnt screen use the userID

for listing as specific user
remove user
disable user
change user role
edit user id
resest user passowrd


in the user login screen, allow the user to tap enter 2 times and it comes up with a promt saying do you want to go back to the main menu or no and it repets. and a change for exiting the script


In the search tab, when it shows all the sets, allow the user to refresh the screen to show more results and have a total at the bottlem of the screen like a another table

create a r for refresh page

Here’s how to add an [r] Refresh option to your search results paging in search_sets().
This allows the user to refresh the current page by pressing r (or Enter), in addition to n (next), p (previous), and q (quit).
It also adds a summary table at the bottom.


the r refresh does not refresh the page or show new results, i have to exit and go back in to the seach



Allow in Add Lego Set, Edit Lego Sets, and search, have checklist or interactive, for the set themes, so but some sections will have sub sections for ease of use and better understaning, sepfrom typing the theme the user can just a [x] in the box and if it has a subsection, the user can select the main section and subsection - (Required) 



---

```bash
{
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
{
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
{
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
}
```

