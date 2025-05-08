#NIVEL 1
#Exercici 1
#A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules. 
#Mostra les característiques principals de l'esquema creat i explica les diferents taules i variables 
#que existeixen. 
#Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.

SELECT * FROM company;
SELECT * FROM transaction;

DELETE FROM company 
WHERE id = "b-9999";
DELETE FROM transaction
WHERE company_id = "b-9999";

#Exercici 2
#Utilitzant JOIN realitzaràs les següents consultes:
#Llistat dels països que estan fent compres.

SELECT distinct country
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE declined = 0;

#Des de quants països es realitzen les compres.

SELECT count(distinct country) as paises
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE declined = 0;

#Identifica la companyia amb la mitjana més gran de vendes.

#Opcion 1 con round
SELECT company_name, round(avg(amount),2) mediadeventas
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY company_name
ORDER BY avg(amount) DESC
LIMIT 1;

#Opcion 2 con Format
SELECT company_name, Format(avg(amount),2) mediadeventas
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY company_name
ORDER BY avg(amount) DESC
LIMIT 1;

#Exercici 3
#Utilitzant només subconsultes (sense utilitzar JOIN):
#Mostra totes les transaccions realitzades per empreses d'Alemanya.

#Opcion 1 con Exists
SELECT id
FROM transaction
WHERE EXISTS 
(SELECT id FROM company WHERE transaction.company_id = company.id AND country IN ("Germany"))
AND declined = 0;

#Opcion 2 con ANY 
SELECT id
FROM transaction
WHERE company_id  = ANY (SELECT id FROM company WHERE country = "Germany")
AND declined = 0;

#Llista les empreses que han realitzat transaccions per un 
#amount superior a la mitjana de totes les transaccions.

SELECT company_id, amount
FROM transaction
HAVING amount > (SELECT avg(amount)
FROM transaction
WHERE declined = 0);

#Eliminaran del sistema les empreses que no tenen transaccions registrades, 
#entrega el llistat d'aquestes empreses.

SELECT company_name
FROM company
WHERE id NOT IN (SELECT company_id
    FROM transaction);
    
#NIVEL 2
#Exercici 1
#Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes.
#Mostra la fecha de cada transacció juntament amb el total de les vendes.

SELECT DATE(timestamp) AS fechasmax, round(SUM(amount),2) AS suma
FROM transaction
WHERE declined = 0
GROUP BY fechasmax
ORDER BY suma DESC
LIMIT 5;

#Exercici 2
#Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

SELECT country, round(avg(amount),2) as mediaventas
FROM transaction
JOIN company 
ON transaction.company_id = company.id
WHERE declined = 0
GROUP BY country
ORDER BY mediaventas DESC;

#Exercici 3
#En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer 
#competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions 
#realitzades per empreses que estan situades en el mateix país que aquesta companyia.
#Mostra el llistat aplicant JOIN i subconsultes.

SELECT company_name, transaction.id, country, timestamp, amount, phone, email, website, user_id
FROM transaction
JOIN company ON transaction.company_id = company.id
WHERE company_id != "b-2618"
AND country = (SELECT country
FROM company 
WHERE id = "b-2618")
AND declined = 0
ORDER BY company_id;

#Mostra el llistat aplicant solament subconsultes.

SELECT *
FROM transaction
WHERE company_id IN (SELECT id
FROM company
WHERE id != "b-2618"
AND country IN (SELECT country
FROM company 
WHERE id = "b-2618"))
AND declined = 0;
      
#Nivell 3
#Exercici 1
#Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès 
#entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. 
#Ordena els resultats de major a menor quantitat.

SELECT company_name, phone, country, DATE(timestamp) as fecha, amount
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE amount between 100 and 200
AND declined = 0
AND DATE(timestamp) IN ("2021-04-29", "2021-07-20", "2022-03-13")
ORDER BY amount DESC;

#Exercici 2
#Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa 
#que es requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions 
#que realitzen les empreses, però el departament de recursos humans és exigent i vol un 
#llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.

SELECT company_name, 
IF (COUNT(transaction.id) > 4, 'masque4', 'menosque4') AS etiqueta
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY company_name;