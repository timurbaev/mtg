CREATE TABLE Users (
    id INTEGER auto_increment,  
    login VARCHAR(16) DEFAULT NULL,
    password VARCHAR(16) DEFAULT NULL,
    balance INTEGER,
    PRIMARY KEY (id),
    UNIQUE KEY (login)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB;

CREATE TABLE Cards (
    id INTEGER,
    name VARCHAR(50) DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY (name)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB;

CREATE TABLE Cards_has_Users (
    Card_id INTEGER,
    User_id INTEGER,
    FOREIGN KEY (Card_id) REFERENCES Cards (id),
    FOREIGN KEY (User_id) REFERENCES Users (id),
    UNIQUE (Card_id, User_id)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB;
