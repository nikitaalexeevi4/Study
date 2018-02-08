CREATE OR REPLACE FUNCTION public.check_add_id_prd() 
RETURNS trigger AS 
$BODY$ 
DECLARE id_prd integer; 
BEGIN 
SELECT INTO id_prd cod_product FROM product
WHERE cod_product = NEW.cod_product; 
IF id_prd IS NULL
THEN RAISE EXCEPTION ' Продукта с кодом % не существует',  
NEW.cod_product; 
ELSE
SELECT INTO id_prd cod_product FROM store
WHERE cod_product = NEW.cod_product; 
	IF id_prd IS NULL
		THEN INSERT INTO store(cod_product, amount)
			VALUES(NEW.cod_product, NEW.amount);
	ELSE
		UPDATE store 
	SET amount = amount + NEW.amount 
	WHERE cod_product = NEW.cod_product; 
	END IF;
END IF; 
RETURN NEW; 
END; 
$BODY$ 
LANGUAGE 'plpgsql' VOLATILE;