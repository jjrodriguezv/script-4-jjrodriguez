-- estructura datos script4_transactions

-- Creamos la base de datos
    CREATE DATABASE IF NOT EXISTS script4_transactions;
    USE script4_transactions;


    -- Creamos la tabla companies
       CREATE TABLE IF NOT EXISTS companies (
        company_id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );
    
    
     -- Creamos la tabla users
     -- id,name,surname,phone,email,birth_date,country,city,postal_code,address
     
    CREATE TABLE IF NOT EXISTS users (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255)
    );
    
    
    -- creamos la tabla credit_cards
       
    CREATE TABLE IF NOT EXISTS credit_cards (
        id VARCHAR(20) PRIMARY KEY,
        user_id INT,
        iban VARCHAR(50),
		pan VARCHAR(20),
        pin VARCHAR(20), 
        cvv INT,
        track1 VARCHAR(255),
        track2 VARCHAR(255),
        expiring_date VARCHAR(20));
	
    
    
    -- creamos la tabla productos
      
    CREATE TABLE IF NOT EXISTS products (
        id VARCHAR(20) PRIMARY KEY,
        product_name VARCHAR(20),
        price DECIMAL (5,2),
        colour VARCHAR(20),
		weight DECIMAL (5,2),
        warehouse_id VARCHAR(15)
	);
        
    -- Creamos la tabla transaction
      
    CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) PRIMARY KEY,
        card_id VARCHAR(15),
        business_id VARCHAR(15), 
		timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
		declined BOOLEAN,
        product_ids VARCHAR(20),
        user_id INT REFERENCES users(id),
        lat FLOAT,
        longitude FLOAT,
        FOREIGN KEY (card_id)     REFERENCES credit_cards(id),
        FOREIGN KEY (business_id) REFERENCES companies(company_id),
        FOREIGN KEY (user_id)    REFERENCES users(id),
        FOREIGN KEY (product_ids) REFERENCES products(id)
    );
    
    RENAME TABLE transaction TO transactions;
    SHOW VARIABLES LIKE'secure_file_priv';
    SHOW VARIABLES LIKE'local_infile';
    SET GLOBAL local_infile = 1;
   
    -- cargamos la tabla companies
	LOAD DATA LOCAL
	INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv'
    INTO TABLE companies
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    IGNORE 1 ROWS;
    
  -- cargamos la tabla users
	LOAD DATA
	INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv'
    INTO TABLE users
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS;
    
    LOAD DATA
	INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv'
    INTO TABLE users
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS;
    
    LOAD DATA
	INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv'
    INTO TABLE users
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS;

-- cargamos la tabla credit_cards
	LOAD DATA
	INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
    INTO TABLE credit_cards
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;
    
    SET SQL_MODE = ''; -- para evitar el chequeo del formato en los campos decimales.
    -- cargamos la tabla products
	LOAD DATA
	INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
    INTO TABLE products
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;
    
    
	SET FOREIGN_KEY_CHECKS = 0; -- Se desactiva el chequeo de claves foráneas
	SET SQL_SAFE_UPDATES = 0;  --  Se desactivan las actualizaciones
-- cargamos la tabla transactions
  	LOAD DATA
	INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
    INTO TABLE transactions
    FIELDS TERMINATED BY ';'
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;
    
    SET FOREIGN_KEY_CHECKS = 1; -- Se activa el chequeo de claves foráneas
	SET SQL_SAFE_UPDATES = 1;   -- Se desactivan las actualizacioness
    select * from  transactions;
   
    
    
/*********************************************************************************
    Exercici 1
	Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.
    ********************************************************************************/
    SELECT u.name as nombre, u.surname as apellido
    FROM users u
    WHERE u.id IN (                      -- Para realizar la consulta, se utiliza la cláusula IN
			SELECT user_id 			     -- Generar tabla con los user_id que tengas mas de 30 transacciones
            FROM transactions t          -- La subconsulta se basa en un Select de la tabla transactions
            WHERE t.declined = 0         -- Se verifica que las transacciones no sea declinadas
            GROUP BY user_id
            HAVING COUNT(t.user_id) > 30 -- se usa la cláusula HAVING para revisar la condición del COUNT
            );
            
            
   /*********************************************************************
   - Exercici 2
     Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd,
     utilitza almenys 2 taules.
   **********************************************************************/
    
    SELECT ROUND(AVG(t.amount),2)   -- Se calcula la media del amount
    FROM transactions t
    JOIN credit_cards cc			-- Se hace le JOIN entre las tablas transaccions y credit_cards
		ON t.card_id = cc.id  
	JOIN companies c                                                           
		ON t.business_id = c.company_id
	WHERE t.declined = 0 AND 		-- Se verifica que las transacciones sean válidas
      c.company_name = 'Donec Ltd'	-- Se verifica la condición del cáculo en la empresa Donec Ltd.
	GROUP BY cc.iban;
    
    
    /******************************************************************************************
    Nivell 2
	Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes
	tres transaccions van ser declinades i genera la següent consulta:
	Exercici 1 - Quantes targetes estan actives?
    *******************************************************************************************/
  -- Crear la tabla de estado de tarjetas (estado_tarjetas) e insertar los datos
CREATE TABLE IF NOT EXISTS estado_tarjetas AS
SELECT *
FROM 
	(SELECT 
        card_id tarjeta,
        declined estado,
        ROW_NUMBER() OVER (PARTITION BY card_id, declined ORDER BY timestamp DESC) num_filas
	 FROM transactions) t;
-- WHERE t.estado = 1 and t.num_filas = 3; -- Con esta condición ya se evidencia que no hay tarjetas con las últimas 3
                                           -- transacciones rechazadas
 -- drop table estado_tarjetas;
    -- Indicar cuántas tarjetas están activas  
   
   SELECT SUM(tarjetas) as TOTAL_ACTIVAS
   FROM
	  (SELECT estado, COUNT(tarjeta) as tarjetas,
		CASE
			WHEN estado = 1 and num_filas = 3 THEN "inactivas"
            WHEN estado = 1 and num_filas < 3 THEN "activas, con menos de 3 rechazos consecutivos"
			ELSE "activas sin rechazos"
		END AS texto
		FROM estado_tarjetas
		GROUP BY estado, texto) t;
	
    SELECT estado, COUNT(tarjeta) as tarjetas,
		CASE
			WHEN estado = 1 and num_filas = 3 THEN "inactivas"
            WHEN estado = 1 and num_filas < 3 THEN "activas, con menos de 3 rechazos consecutivos"
			ELSE "activas sin rechazos"
		END AS texto
		FROM estado_tarjetas
		GROUP BY estado, texto;
    
     
    
 /*****************************************************************************************
    Nivell 3
Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada,
tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

Exercici 1
Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
    
**********************************************************************************************/
  -- Esta tabla servirá para dividir las cadenas de productos.
  CREATE TABLE tabla_cantidad (
    cantidad_productos_separados_coma INT PRIMARY KEY
);

-- Insertar números secuenciales
INSERT INTO tabla_cantidad (cantidad_productos_separados_coma)
VALUES (1), (2), (3), (4), (5), (6)
;

-- Creamos la tabla detalle_transacciones para almacenar los valores divididos:
CREATE TABLE detalle_transacciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaccion_id VARCHAR(255),
    producto_id VARCHAR(20)
);

-- Insertar en detalle_transacciones los codigos de productos de forma separada
-- Usamos una consulta basada en JOIN con la tabla tabla_cantidad para dividir
-- los valores separados por comas e insertarlos en la tabla detalle_transacciones
-- que usará como tabl asecundaria

INSERT INTO detalle_transacciones (transaccion_id, producto_id)
SELECT
	t.id AS transaccion_id,
	CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.product_ids, ',', tc.cantidad_productos_separados_coma), ',',
	-1)) AS UNSIGNED) AS producto_id
FROM
    transactions t
JOIN
tabla_cantidad tc ON tc.cantidad_productos_separados_coma <= 
									(1 + CHAR_LENGTH(t.product_ids) - CHAR_LENGTH(REPLACE(t.product_ids, ',', '')))
WHERE
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.product_ids, ',', tc.cantidad_productos_separados_coma), ',', -1)) <> ''
    AND t.declined = 0;


-- Se hace el JOIN entre la tabla creada (detalle_transacciones y la tabla de productos para el conteo
SELECT 
	p.product_name AS nombre_producto,
    COUNT(dt.transaccion_id) as cantidad_veces_comprado
FROM 
    detalle_transacciones dt
JOIN 
    products p ON dt.producto_id = p.id
GROUP BY
	p.product_name
ORDER BY
	Cantidad_veces_comprado DESC;
    







     
