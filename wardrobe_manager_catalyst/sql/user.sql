CREATE DATABASE IF NOT EXISTS wardrobe;
DROP USER 'wardrobe'@'localhost';
FLUSH PRIVILEGES;
CREATE USER 'wardrobe'@'localhost' IDENTIFIED BY 'StRaW101';
GRANT SELECT, INSERT, UPDATE, DELETE ON wardrobe.* TO 'wardrobe'@'localhost';
