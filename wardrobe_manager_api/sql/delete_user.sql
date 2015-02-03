GRANT SELECT ON *.* TO 'wardrobe'@'localhost';
DROP USER 'wardrobe'@'localhost';
GRANT SELECT ON *.* TO 'wardrobeapi'@'localhost';
DROP USER 'wardrobeapi'@'localhost';
FLUSH PRIVILEGES;
