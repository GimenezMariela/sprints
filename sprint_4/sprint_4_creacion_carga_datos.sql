Create database american;
-- Creación de tablas 

-- 1. Tabla AMERICAN_USERS
#id	name	surname	phone				email						birth_date			country		city		postal_code			address	
#1	Zeus	Gamble	1-282-581-0551	interdum.enim@protonmail.edu	nov 17, 1985	United States	New York	10001			348-7818 Sagittis St.	

CREATE TABLE american_users_raw (
    id INT,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(150),
    birth_date VARCHAR(50), -- formato tipo 'Nov 17, 1985'
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255)
);

#cargar datos...
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/american_users.csv'
INTO TABLE american_users_raw
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE american_users (
    id INT,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(150),
    birth_date DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255)
);

#Insertar los datos de american_users_raw a american_users
INSERT INTO american_users
SELECT
    id,
    name,
    surname,
    phone,
    email,
    STR_TO_DATE(birth_date, '%b %d, %Y') AS birth_date,
    country,
    city,
    postal_code,
    address
FROM american_users_raw;

-- 2. Tabla EUROPEAN_USERS
#id		name	surname	phone				email				birth_date		country			city	postal_code		address	
#151	Meghan	Hayden	0800 746 6747	arcu.vel@hotmail.ca		jul 2, 1980		United Kingdom	London	EC1A 1BB		Ap #432-4493 Aliquet Rd.	
CREATE TABLE european_users_raw (
    id INT,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(150),
    birth_date VARCHAR(50), -- fecha como texto
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255)
);
 #cargar los datos 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/european_users.csv'
INTO TABLE european_users_raw
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


CREATE TABLE european_users (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    surname VARCHAR(50),
    phone VARCHAR(50),
    email VARCHAR(100),
    birth_date DATE,
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(30),
    address VARCHAR(150)
);

#insertar datos
INSERT INTO european_users
SELECT
    id,
    name,
    surname,
    phone,
    email,
    STR_TO_DATE(birth_date, '%b %e, %Y') AS birth_date,
    country,
    city,
    postal_code,
    address
FROM european_users_raw;

-- 3. Tabla AMERICAN_EUROPEAN_USERS (fusión de usuarios)
CREATE TABLE american_european_users (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    surname VARCHAR(50),
    phone VARCHAR(50),
    email VARCHAR(100),
    birth_date DATE,
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(30),
    address VARCHAR(150)
);

-- 3. Insertar ambos en AMERICAN_EUROPEAN_USERS:
INSERT INTO american_european_users
SELECT * FROM american_users;

INSERT INTO american_european_users
SELECT * FROM european_users;
select count(*) from american_european_users;

-- 4. Tabla CREDIT_CARDS
#	id		user_id		iban					pan					pin		cvv		track1										track2							expiring_date
#CcU-2938	275		TR301950312213576817638661	5424465566813633	3257	984	  %B8383712448554646^WovsxejDpwiev^86041142?7	%B7653863056044187=8007163336?3	10/30/22
#creando tabla temporal por el expiring_date 
CREATE TABLE credit_card_raw (
    id VARCHAR(10),
    user_id INT,
    iban VARCHAR(34),
    pan VARCHAR(25),
    pin CHAR(4),
    cvv CHAR(3),
    track1 TEXT,
    track2 TEXT,
    expiring_date VARCHAR(10)  -- fecha como texto, ej: 10/30/22
);

#cargar datos 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/credit_cards.csv'
INTO TABLE credit_card_raw
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE credit_card (
    id VARCHAR(10) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(34),
    pan VARCHAR(25),
    pin CHAR(4),
    cvv CHAR(3),
    track1 TEXT,
    track2 TEXT,
    expiring_date DATE
);

INSERT INTO credit_card
SELECT
    id,
    user_id,
    iban,
    pan,
    pin,
    cvv,
    track1,
    track2,
    STR_TO_DATE(expiring_date, '%m/%d/%y') AS expiring_date
FROM credit_card_raw;

-- 5. Tabla COMPANIES
#company_id		company_name				phone				email							country		website	
#b-2222			Ac Fermentum Incorporated	06 85 56 52 33	donec.porttitor.tellus@yahoo.net	Germany		https://instagram.com/site	
CREATE TABLE companies (
    company_id VARCHAR(50) PRIMARY KEY,
    company_name VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(100),
    country VARCHAR(50),
    website VARCHAR(200)
);

#cargar datos 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 7. Tabla TRANSACTIONS
#id										card_id		business_id		timestamp			 amount		declined	product_ids	  user_id			lat					longitude
#CDDA7E40-544D-47BB-A4ED-671DD8A950D9	CcS-6894	b-2466			2018-12-12 8:05:17	 161.88			0		75, 73, 98		2313	5.962.050.974.356.140	16.559.977.155.728.400

CREATE TABLE transaction (
    id VARCHAR(100) PRIMARY KEY,                 
    card_id VARCHAR(10),                         
    business_id VARCHAR(50),                     
    timestamp DATETIME,                          
    amount DECIMAL(10,2),                        
    declined BOOLEAN,                            
    product_ids VARCHAR(255),                    
    user_id INT,                                 
    lat VARCHAR(150),                           
    longitude VARCHAR(150),                     
    FOREIGN KEY (card_id) REFERENCES credit_card(id),
    FOREIGN KEY (business_id) REFERENCES companies(company_id),
    FOREIGN KEY (user_id) REFERENCES american_european_users(id)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/transactions.csv'
INTO TABLE transaction
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

