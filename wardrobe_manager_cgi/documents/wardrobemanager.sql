    --
    -- Create mysql database with the relevant tables
    --

    DROP DATABASE IF EXISTS wardrobe;
    CREATE DATABASE IF NOT EXISTS wardrobe DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

    USE wardrobe;

    DROP TABLE IF EXISTS clothing;
    DROP TABLE IF EXISTS category;
    DROP TABLE IF EXISTS outfit;
    DROP TABLE IF EXISTS clothing_outfit;

    CREATE TABLE category (
           id          INT  NOT NULL PRIMARY KEY AUTO_INCREMENT,
           name        VARCHAR(255) NOT NULL,
           INDEX (name)
    ) ENGINE=InnoDB;
    CREATE TABLE clothing (
           id          INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
           name        VARCHAR(255) NOT NULL,
           category    INT NOT NULL,
           FOREIGN KEY (category) references category(id),
           INDEX (name)
    ) ENGINE=InnoDB;
    CREATE TABLE outfit (
           id          INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
           name        VARCHAR(255) NOT NULL,
       INDEX (name)
           
    ) ENGINE=InnoDB;
    CREATE TABLE clothing_outfit (
           clothing     INT NOT NULL,
           outfit       INT NOT NULL,
           PRIMARY KEY (clothing, outfit)
    ) ENGINE=InnoDB;

    INSERT INTO outfit VALUES (NULL, 'Casual outfit 1');
    INSERT INTO outfit VALUES (NULL, 'Casual outfit 2');
    INSERT INTO outfit VALUES (NULL, 'Casual outfit 3');
    INSERT INTO outfit VALUES (NULL, 'Smart outfit 1');
    INSERT INTO outfit VALUES (NULL, 'Smart outfit 2');
    INSERT INTO outfit VALUES (NULL, 'Smart outfit 3');

    GRANT ALL PRIVILEGES ON wardrobe.* TO wardrobe@'%' IDENTIFIED BY 'StRaW101'; 
