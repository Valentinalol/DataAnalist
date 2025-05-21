#Nivell 1
#Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema 
#d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les 
#següents consultes: (Mas tarde)

CREATE DATABASE db_companies;

CREATE TABLE db_companies.companies
(company_id CHAR (6) PRIMARY KEY,
company_name VARCHAR (100),
phone VARCHAR (15),
email VARCHAR (100),
country VARCHAR (100),
website VARCHAR (100));

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv"
INTO TABLE db_companies.companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 LINES;

SELECT * FROM companies;

CREATE TABLE db_companies.user
(id INT PRIMARY KEY,
name VARCHAR (100),
surname VARCHAR (100),
phone VARCHAR (100),
email VARCHAR (100),
birth_date VARCHAR (100),
country VARCHAR (100),
city VARCHAR (100),
postal_code VARCHAR (100),
address VARCHAR (100));

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv"
INTO TABLE db_companies.user
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv"
INTO TABLE db_companies.user
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv"
INTO TABLE db_companies.user
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SELECT *
FROM user;

CREATE TABLE db_companies.credit_cards
(id VARCHAR (100) PRIMARY KEY,
user_id INT,
iban VARCHAR (100), 
pan VARCHAR (100), 
pin VARCHAR (100), 
cvv INT, 
track1 VARCHAR (100),
track2 VARCHAR (100),
expiring_date VARCHAR (100));

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv"
INTO TABLE db_companies.credit_cards
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

SELECT*
FROM credit_cards;

CREATE TABLE db_companies.transactions
(id varchar(100) Primary Key,
card_id varchar(15),
business_id varchar(20),
timestamp timestamp,
amount decimal(10,2),
declined tinyint(1),
product_ids varchar(100),
user_id INT,
lat float,
longitude float);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv"
INTO TABLE db_companies.transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SELECT *
FROM transactions;

#Se conectan las Keys

ALTER TABLE transactions
ADD CONSTRAINT `transactionycredit`
FOREIGN KEY (`card_id`)
REFERENCES `credit_cards` (`id`);
  
ALTER TABLE transactions
ADD CONSTRAINT `transactionycompany`
FOREIGN KEY (`business_id`)
REFERENCES `companies` (`company_id`);

ALTER TABLE transactions
ADD CONSTRAINT `transactionyuser`
FOREIGN KEY (`user_id`)
REFERENCES `user` (`id`);

ALTER TABLE transactions
MODIFY COLUMN timestamp date;

SELECT *
FROM transactions;

UPDATE credit_cards
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%Y');

ALTER TABLE credit_cards
MODIFY COLUMN expiring_date date;

SELECT *
FROM credicredit_cardst_cards;

UPDATE USER
SET birth_date = STR_TO_DATE(birth_date, '%b %d, %Y'); 

ALTER TABLE user
MODIFY COLUMN birth_date date;










SELECT *
FROM user;

#- Exercici 1
#Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions 
#utilitzant almenys 2 taules.

SELECT *
FROM user
WHERE user.id IN ( SELECT user_id
    FROM transactions
    WHERE declined = 0
    GROUP BY user_id
    HAVING COUNT(id) > 30);
    
#- Exercici 2
#Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia 
#Donec Ltd, utilitza almenys 2 taules.

WITH laempresa AS (SELECT *
FROM companies
WHERE company_name = "Donec Ltd")
SELECT company_name, business_id, round(avg(amount),2) as promedio, card_id, iban
FROM transactions
JOIN laempresa ON laempresa.company_id = transactions.business_id
JOIN credit_cards ON credit_cards.id = transactions.card_id
WHERE declined = 0
GROUP BY card_id, business_id, iban, company_name;

#Nivell 2
#Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat
#en si les últimes tres transaccions van ser declinades i genera la següent consulta¡

CREATE TABLE estado_tarjetas AS
SELECT card_id,
  CASE
    WHEN COUNT(*) = 3 AND SUM(declined = 1) = 3 THEN 'Inactiva'
    ELSE 'Activa'
  END AS estado
FROM (SELECT card_id, declined,
    ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS rn
  FROM transactions
) AS ultimasestado_tarjetas
WHERE rn <= 3
GROUP BY card_id;

ALTER TABLE estado_tarjetas
ADD CONSTRAINT `creditcardyestado`
FOREIGN KEY (`card_id`) 
REFERENCES `credit_cards` (`id`);

#Exercici 1
#Quantes targetes estan actives?
SELECT count(*)
FROM estado_tarjetas
WHERE estado = "Activa";

#Nivell 3
#Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, 
#tenint en compte que des de transaction tens product_ids. Genera la següent consulta:
#Exercici 1
#Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

CREATE TABLE productos
(id INT PRIMARY KEY,
product_name VARCHAR (100),
price DECIMAL (10,2),
colour VARCHAR (100),
weight DECIMAL (10,1),
warehouse_id VARCHAR (100));

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv"
INTO TABLE db_companies.productos
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, product_name, @precio, colour, weight, warehouse_id)
SET price = REPLACE(@precio, '$', '');

CREATE TABLE transactions_products
(transaction_id VARCHAR(100),
producto_id INT,
FOREIGN KEY (transaction_id) REFERENCES transactions(id),
FOREIGN KEY (producto_id) REFERENCES productos(id)
);

INSERT INTO transactions_products (transaction_id, producto_id)
SELECT transactions.id AS transaction_id,
productos.id AS producto_id
FROM transactions
JOIN productos
ON FIND_IN_SET(productos.id, REPLACE(transactions.product_ids, ' ', ''))
WHERE declined = 0;

SELECT * 
FROM transactions_products;

SELECT *
FROM transactions
WHERE declined = 0;
SELECT producto_id, count(transaction_id)
FROM transactions_products
GROUP BY producto_id
ORDER BY producto_id ASC;
