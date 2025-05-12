#- Exercici 1
#La teva tasca és dissenyar i crear una taula anomenada "credit_card" 
#que emmagatzemi detalls crucials sobre les targetes de crèdit. La nova taula ha de 
#ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb 
#les altres dues taules ("transaction" i "company"). Després de crear la taula serà necessari que 
#ingressis la informació del document denominat "dades_introduir_credit". Recorda mostrar el diagrama 
#i realitzar una breu descripció d'aquest.

CREATE TABLE transactions.credit_card
(id VARCHAR (15) PRIMARY KEY,
iban VARCHAR (34) NOT NULL, 
pan VARCHAR (19) NOT NULL, 
pin CHAR (4) NOT NULL, 
cvv CHAR (3) NOT NULL, 
expiring_date VARCHAR (10) NOT NULL,
CONSTRAINT chk_pin_format CHECK (pin REGEXP "^[0-9]{4}$"),
CONSTRAINT chk_cvv_format CHECK (cvv REGEXP "^[0-9]{3}$")
);

SELECT *
FROM credit_card;

#- Exercici 2
#El departament de Recursos Humans ha identificat un error en el número de compte 
#de l'usuari amb ID CcU-2938. La informació que ha de mostrar-se per a aquest 
#registre és: R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.

SELECT *
FROM credit_card
WHERE id = "CcU-2938";

UPDATE credit_card SET iban = "R323456312213576817699999" WHERE id = "CcU-2938";
SELECT * 
FROM credit_card
WHERE id = "CcU-2938";

# Exercici 3
#En la taula "transaction" ingressa un nou usuari amb la següent informació:
#Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
#credit_card_id	CcU-9999
#company_id	b-9999
#user_id	9999
#lat	829.999
#longitude	-117.999
#amount	111.11
#declined	0

USE company;
INSERT INTO company (id)
VALUES ("b-9999");
USE transactions;
INSERT INTO transaction (Id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", "9999", "829.999", "-117.999",
111.11, 0);
SELECT *
FROM transaction
WHERE company_id = "b-9999";

#Exercici 4
#Des de recursos humans et sol·liciten eliminar la columna "pan" 
#de la taula credit_*card. Recorda mostrar el canvi realitzat.

Alter table credit_card drop pan;
SELECT *
FROM credit_card;

#Nivell 2
#Exercici 1
#Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de 
#la base de dades.

delete from transaction where id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";
SELECT *
FROM transaction where id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

#Exercici 2
#La secció de màrqueting desitja tenir accés a informació específica per a realitzar 
#anàlisi i estratègies efectives. S'ha sol·licitat crear una vista que proporcioni detalls 
#clau sobre les covistamarketingmpanyies i les seves transaccions. Serà necessària que creïs una vista anomenada 
#VistaMarketing que contingui la següent informació: Nom de la companyia. Telèfon de contacte. 
#País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, 
#ordenant les dades de major a menor mitjana de compra.

SELECT company_name as nombrecompañia, phone as telefono, country as pais, 
round(avg(amount),2) as compramedia
FROM company
JOIN transaction ON company_id = company.id
WHERE declined = 0
GROUP BY nombrecompañia, telefono, pais
ORDER BY compramedia DESC;

SELECT *
FROM vistamarketing;

#Exercici 3
#Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu 
#país de residència en "Germany"

SELECT *
FROM Vistamarketing
WHERE pais IN ("Germany");

#Nivell 3
#Exercici 1
#La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. 
#Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com 
#les va realitzar. Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent 
#diagrama:
#Mirar Sprint 3 Doc

SELECT *
FROM user;

#Exercici 2
#L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui
#la següent informació:
#ID de la transacció
#Nom de l'usuari/ària
#Cognom de l'usuari/ària
#IBAN de la targeta de crèdit usada.
#Nom de la companyia de la transacció realitzada.
#Assegura't d'incloure informació rellevant de totes dues taules
#i utilitza àlies per a canviar de nom columnes segons sigui necessari.
#Mostra els resultats de la vista, ordena els resultats de manera descendent
#en funció de la variable ID de transaction.

SELECT transaction.id as Idtransaccion, name as NombreUsuaria, surname as Apellido, 
iban, company_name AS nombrecompañia
FROM transaction
JOIN company ON company_id = company.id
JOIN data_user ON user_id = data_user.id
JOIN credit_card ON  credit_card_id = credit_card.id
ORDER BY Idtransaccion DESC;
SELECT*
FROM informetecnico;
