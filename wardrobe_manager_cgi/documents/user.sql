CREATE DATABASE IF NOT EXISTS wardrobe;
CREATE USER 'wardrobe'@'localhost' IDENTIFIED BY 'StRaW101';
GRANT SELECT, INSERT, UPDATE ON wardrobe.* TO 'wardrobe'@'localhost';
