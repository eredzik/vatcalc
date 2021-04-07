-- upgrade --
CREATE TABLE IF NOT EXISTS "tradingpartner" (
    "id" SERIAL NOT NULL PRIMARY KEY,
    "nip_number" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "adress" TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS "user" (
    "id" SERIAL NOT NULL PRIMARY KEY,
    "username" VARCHAR(50) NOT NULL,
    "password_hash" VARCHAR(128) NOT NULL
);
CREATE TABLE IF NOT EXISTS "invoice" (
    "id" SERIAL NOT NULL PRIMARY KEY,
    "invoice_id" VARCHAR(50) NOT NULL,
    "invoice_date" DATE NOT NULL,
    "invoice_type" VARCHAR(3) NOT NULL,
    "partner_id" INT NOT NULL REFERENCES "tradingpartner" ("id") ON DELETE CASCADE
);
COMMENT ON COLUMN "invoice"."invoice_type" IS 'Inbound: IN\nOutbound: OUT';
CREATE TABLE IF NOT EXISTS "vatrates" (
    "id" SERIAL NOT NULL PRIMARY KEY,
    "vat_rate" DOUBLE PRECISION NOT NULL,
    "comment" VARCHAR(200) NOT NULL
);
CREATE TABLE IF NOT EXISTS "invoiceposition" (
    "id" SERIAL NOT NULL PRIMARY KEY,
    "name" VARCHAR(200) NOT NULL,
    "num_items" DOUBLE PRECISION NOT NULL,
    "price_net" DOUBLE PRECISION NOT NULL,
    "invoice_id" INT NOT NULL REFERENCES "invoice" ("id") ON DELETE CASCADE,
    "vat_rate_id" INT NOT NULL REFERENCES "vatrates" ("id") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "aerich" (
    "id" SERIAL NOT NULL PRIMARY KEY,
    "version" VARCHAR(255) NOT NULL,
    "app" VARCHAR(20) NOT NULL,
    "content" JSONB NOT NULL
);
