#Exercici 1
-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.
SELECT u.name
FROM american_european_users u 
WHERE id IN (
    SELECT COUNT(t.user_id) AS total_transactions
    FROM transaction t
    #where t.amount >= 80
    GROUP BY t.user_id
    having total_transactions >= 80
    order by total_transactions desc
) ;

# Exercici 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
SELECT 
    cc.iban, round(AVG(t.amount),2) as mediana_iban 
FROM transaction t
JOIN credit_card cc ON t.card_id = cc.id
JOIN companies c ON t.business_id = c.company_id
WHERE c.company_name = 'Donec Ltd'
group by cc.iban
#having round(AVG(t.amount),2)
;

#Nivell 2
-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:
CREATE TABLE card_status (
    card_id varchar(10) PRIMARY KEY,
    status VARCHAR(10),
    FOREIGN KEY (card_id) REFERENCES credit_card(id)
);

SHOW COLUMNS FROM credit_card; # mirar los nombres y tipos de la tabla

INSERT INTO card_status (card_id, status)
SELECT 
    card_id AS credit_card_id,
    CASE 
        WHEN SUM(CASE WHEN declined = 1 THEN 1 ELSE 0 END) = 3 THEN 'bloqueada'
        ELSE 'activa'
    END AS status
FROM (
    SELECT 
        card_id,
        declined,
        ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS fila
    FROM transaction
) t
WHERE fila <= 3
GROUP BY card_id;

select count(*) from card_status;
	#Exercici 1
-- Quantes targetes estan actives?
select count(*) from card_status where status = "activa";

#Nivell 3
-- Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, 
-- tenint en compte que des de transaction tens product_ids. Genera la següent consulta:
#creando tabla temporal para cargar los datos alter
CREATE TABLE products_temp (
    id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price VARCHAR(20),
    colour VARCHAR(50),
    weight DECIMAL(10,2),
	warehouse_id VARCHAR(10)
);

#cargando los datos a la tabla temporal 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/products.csv' 
INTO TABLE products_temp
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'  
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

#crear la tabla de products 
CREATE TABLE products (
    id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2),
    colour VARCHAR(50),
    weight DECIMAL(10,2),
    warehouse_id varchar(10)
);
#insertar los datos de la tabla temporal a la tabla de products 
INSERT INTO products (id, product_name, price, colour, weight, warehouse_id)
SELECT 
    id,
    product_name,
    CAST(REPLACE(price, '$', '') AS DECIMAL(10,2)) AS price,
    colour,
    weight,
    warehouse_id
FROM products_temp;

#crear la tabla puente 
CREATE TABLE transaction_products (
    transaction_id varchar(100),
    product_id INT,
    FOREIGN KEY (transaction_id) REFERENCES transaction(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    PRIMARY KEY (transaction_id, product_id)
);

SHOW COLUMNS FROM products; # mirar los nombres y tipos de la tabla
#insertar los datos en la tabla puente 
# limpiar los datos de products ya que es una lista y puede haber espacios entre medios 
INSERT INTO transaction_products (transaction_id, product_id)
SELECT 
    t.id AS transaction_id,
    CAST(j.value AS UNSIGNED) AS product_id
FROM transaction t,
JSON_TABLE(
    CONCAT(
        '["',
        REPLACE(REPLACE(t.product_ids, ' ', ''), ',', '","'),
        '"]'
    ),
    '$[*]' COLUMNS (value VARCHAR(10) PATH '$')
) AS j;

# Exercici 1.
-- Necesitamos conocer el numero de veces que se han vendido cada producto.
select p.id, count(pt.product_id) as product_sold, p.product_name 
from transaction_products pt join products p 
on pt.product_id = p.id
group by p.id, p.product_name
order by product_sold Desc;

SHOW COLUMNS FROM transaction_products; # mirar los nombres y tipos de la tabla