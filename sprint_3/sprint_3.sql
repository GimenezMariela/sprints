#Nivel 1 
/*
Exercici 1
La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit. 
La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules 
("transaction" i "company"). Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit". 
Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.
*/
#id, iban, pan, pin, cvv, expiring_date
CREATE TABLE IF NOT EXISTS credit_card (
id CHAR(20) PRIMARY KEY,
iban VARCHAR(50),
pan varchar(25),
pin VARCHAR(4),
cvv INT,
expiring_date VARCHAR(250),
fecha_anual DATE
);
#cargar los datos de "dades_introduir_credit".
select count(*) from credit_card;
# EJErcicio 2
/*
El departament de Recursos Humans ha identificat un error en el número de compte associat a 
la targeta de crèdit amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és:
TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar

'TR301950312213576817638661'
*/
select * from credit_card
where id = "CcU-2938"
;
UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = "CcU-2938";
show create table user;

/*
Exercici 3
En la taula "transaction" ingressa un nou usuari amb la següent informació:
Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id	CcU-9999
company_id	b-9999
user_id	9999
lat	829.999
longitude	-117.999
amount	111.11
declined	0
una duda de donde saco los datos que necesito para crear en la tabla de user y company y credit_card
*/
insert into company(id)
values('b-9999');

insert into credit_card(id)
values('CcU-9999');

select * from company where id = 'b-9999';

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', '111.11', '0');
/* Exercici 4
Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.*/
ALTER TABLE credit_card
DROP COLUMN pan;
select * from credit_card limit 5;

#NIVEL 2
/*Exercici 1
Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades. */
select * from transaction where id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';
DELETE FROM transaction WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

/* Exercici 2
La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives.
S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions.
Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. 
Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, 
ordenant les dades de major a menor mitjana de compra. */
CREATE VIEW VistaMarketing 
AS 
SELECT c.company_name, c.phone, c.country,  
       AVG(t.amount) AS mediana_compra_por_compañia
FROM company c
LEFT JOIN transaction t ON c.id = t.company_id
group by c.company_name, c.phone, c.country
order by mediana_compra_por_compañia desc;

select * from VistaMarketing;
/*Exercici 3
Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany" */
select * from VistaMarketing where country like 'Germany'; 

#NIVEL 3
/* Exercici 1
La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. 
Un company del teu equip va realitzar modificacions en la base de dades,
però no recorda com les va realitzar. 
Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama: */

SHOW CREATE TABLE transaction; #mirar los datos de la tabla
SHOW COLUMNS FROM transaction; # ver que columnas contiene el 
#ALTER TABLE transaction DROP COLUMN user_id; #Eliminar la columna user_id

#ALTER TABLE transaction DROP COLUMN credit_card;#eliminar la columna credit_card
ALTER TABLE transaction
ADD COLUMN credit_card_id VARCHAR(255);

ALTER TABLE transaction
ADD CONSTRAINT credit_card_id
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

ALTER TABLE transaction
ADD COLUMN user_id Char(10);

ALTER TABLE transaction
ADD CONSTRAINT user_id
FOREIGN KEY (user_id)
REFERENCES user(id);



/* Exercici 2
L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui la següent informació:
ID de la transacció
Nom de l'usuari/ària
Cognom de l'usuari/ària
IBAN de la targeta de crèdit usada.
Nom de la companyia de la transacció realitzada.
Assegureu-vos d'incloure informació rellevant de les taules que coneixereu i utilitzeu àlies per canviar de nom columnes segons calgui.
Mostra els resultats de la vista, ordena els resultats de forma descendent en funció de la variable ID de transacció. */

CREATE VIEW InformeTecnico
AS 
SELECT t.id, u.name, u.surname, cc.iban, c.company_name
FROM transaction t
LEFT JOIN company c ON c.id = t.company_id 
left join user u on t.user_id = u.id
left join credit_card cc on cc.id = t.credit_card_id
order by t.id desc;

select cc.id from credit_card cc left join transaction t on cc.id = t.credit_card_id;

select u.id, t.user_id from user u left join transaction t on u.id = t.user_id;

select * from transaction;
select name, surname from user;
select * from InformeTecnico;