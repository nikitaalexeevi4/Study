CREATE SEQUENCE amount_gen;
CREATE OR REPLACE FUNCTION Store_GEN_ID()
RETURN TRIGGER AS
$Store_GEN_ID$
BEGIN
	NEW.Cod_product = nextval('amount_gen'::regclass);
	return NEW;
END;
$Store_GEN_ID$
LANGUAGE plpgsql
CREATE TRIGGER Store_TRIG_ID 
BEFORE INSERT ON Store 
FOR EACH ROW EXECUTE PROCEDURE Store_GEN_ID();



CREATE TRIGGER add_count_store AFTER INSERT ON Store
FOR EACH ROW BEGIN
UPDATE Store SET Store.amount = Store.amount + 1 where Store.Cod_product
