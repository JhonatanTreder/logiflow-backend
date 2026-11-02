/*
  Warnings:

  - You are about to drop the column `contatoEmail` on the `tenants` table. All the data in the column will be lost.
  - You are about to drop the column `contatoTelefone` on the `tenants` table. All the data in the column will be lost.
  - You are about to drop the column `nomeFantasia` on the `tenants` table. All the data in the column will be lost.
  - You are about to drop the column `razaoSocial` on the `tenants` table. All the data in the column will be lost.
  - You are about to drop the column `tipo` on the `tenants` table. All the data in the column will be lost.
  - The `status` column on the `tenants` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - You are about to drop the column `bloqueadoAte` on the `users` table. All the data in the column will be lost.
  - You are about to drop the column `nome` on the `users` table. All the data in the column will be lost.
  - You are about to drop the column `papel` on the `users` table. All the data in the column will be lost.
  - You are about to drop the column `senhaHash` on the `users` table. All the data in the column will be lost.
  - You are about to drop the column `tentativasFalhas` on the `users` table. All the data in the column will be lost.
  - You are about to drop the column `totpAtivo` on the `users` table. All the data in the column will be lost.
  - You are about to drop the column `totpSecretCifrado` on the `users` table. All the data in the column will be lost.
  - You are about to drop the column `ultimoAcessoEm` on the `users` table. All the data in the column will be lost.
  - The `status` column on the `users` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - Added the required column `contactEmail` to the `tenants` table without a default value. This is not possible if the table is not empty.
  - Added the required column `contactPhone` to the `tenants` table without a default value. This is not possible if the table is not empty.
  - Added the required column `legalName` to the `tenants` table without a default value. This is not possible if the table is not empty.
  - Added the required column `type` to the `tenants` table without a default value. This is not possible if the table is not empty.
  - Added the required column `name` to the `users` table without a default value. This is not possible if the table is not empty.
  - Added the required column `passwordHash` to the `users` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "tenant_type" AS ENUM ('LOGISTICS_OPERATOR', 'MERCHANT');

-- CreateEnum
CREATE TYPE "tenant_status" AS ENUM ('ACTIVE', 'INACTIVE', 'BLOCKED');

-- CreateEnum
CREATE TYPE "user_role" AS ENUM ('USER', 'ADMIN', 'TENANT_OWNER', 'TENANT_OPERATOR', 'WAREHOUSE_OPERATOR', 'DISPATCHER', 'ROUTE_PLANNER', 'DELIVERY_DRIVER', 'ACCOUNTANT', 'SUPPORT', 'CUSTOMER');

-- CreateEnum
CREATE TYPE "user_status" AS ENUM ('ACTIVE', 'INACTIVE', 'INVITED', 'BLOCKED');

-- CreateEnum
CREATE TYPE "token_type" AS ENUM ('PASSWORD_RESET', 'INVITATION');

-- CreateEnum
CREATE TYPE "api_environment" AS ENUM ('PRODUCTION', 'TEST');

-- CreateEnum
CREATE TYPE "geo_precision" AS ENUM ('HIGH', 'MEDIUM', 'LOW', 'NOT_GEOCODED');

-- CreateEnum
CREATE TYPE "warehouse_type" AS ENUM ('WAREHOUSE', 'COLLECTION_HUB', 'SORTING_HUB', 'LAST_MILE_HUB');

-- CreateEnum
CREATE TYPE "warehouse_access_level" AS ENUM ('DEPOSITOR', 'OPERATOR');

-- CreateEnum
CREATE TYPE "access_status" AS ENUM ('ACTIVE', 'SUSPENDED');

-- AlterTable
ALTER TABLE "tenants" DROP COLUMN "contatoEmail",
DROP COLUMN "contatoTelefone",
DROP COLUMN "nomeFantasia",
DROP COLUMN "razaoSocial",
DROP COLUMN "tipo",
ADD COLUMN     "contactEmail" TEXT NOT NULL,
ADD COLUMN     "contactPhone" TEXT NOT NULL,
ADD COLUMN     "legalName" TEXT NOT NULL,
ADD COLUMN     "tradeName" TEXT,
ADD COLUMN     "type" "tenant_type" NOT NULL,
DROP COLUMN "status",
ADD COLUMN     "status" "tenant_status" NOT NULL DEFAULT 'ACTIVE';

-- AlterTable
ALTER TABLE "users" DROP COLUMN "bloqueadoAte",
DROP COLUMN "nome",
DROP COLUMN "papel",
DROP COLUMN "senhaHash",
DROP COLUMN "tentativasFalhas",
DROP COLUMN "totpAtivo",
DROP COLUMN "totpSecretCifrado",
DROP COLUMN "ultimoAcessoEm",
ADD COLUMN     "encryptedTotpKey" TEXT,
ADD COLUMN     "failedAttempts" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "lastAccessAt" TIMESTAMP(3),
ADD COLUMN     "lockedUntil" TIMESTAMP(3),
ADD COLUMN     "name" TEXT NOT NULL,
ADD COLUMN     "passwordHash" TEXT NOT NULL,
ADD COLUMN     "role" "user_role" NOT NULL DEFAULT 'USER',
ADD COLUMN     "totpEnabled" BOOLEAN NOT NULL DEFAULT false,
DROP COLUMN "status",
ADD COLUMN     "status" "user_status" NOT NULL DEFAULT 'ACTIVE';

-- DropEnum
DROP TYPE "papel_usuario";

-- DropEnum
DROP TYPE "status_tenant";

-- DropEnum
DROP TYPE "status_usuario";

-- DropEnum
DROP TYPE "tipo_tenant";

-- CreateTable
CREATE TABLE "stores" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "originAddressId" UUID,
    "name" TEXT NOT NULL,
    "domain" TEXT,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "stores_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "single_use_tokens" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "type" "token_type" NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "single_use_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "api_keys" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "prefix" TEXT NOT NULL,
    "hash" TEXT NOT NULL,
    "apiEnvironment" "api_environment" NOT NULL,
    "scopes" TEXT[],
    "lastUsedAt" TIMESTAMP(3),
    "revokedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "api_keys_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "addresses" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "postalCode" CHAR(8) NOT NULL,
    "street" TEXT NOT NULL,
    "number" TEXT NOT NULL,
    "complement" TEXT,
    "neighborhood" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "state" CHAR(2) NOT NULL,
    "ibgeCode" TEXT,
    "latitude" DECIMAL(9,6),
    "longitude" DECIMAL(9,6),
    "geoAccuracy" "geo_precision" NOT NULL DEFAULT 'NOT_GEOCODED',
    "validated" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "addresses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "receivers" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "document" TEXT,
    "email" TEXT,
    "phone" TEXT,
    "anonymizedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "receivers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "products" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "sku" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "barcode" TEXT,
    "parentProductId" UUID,
    "weightG" INTEGER,
    "heightCm" DECIMAL(9,2),
    "widthCm" DECIMAL(9,2),
    "lengthCm" DECIMAL(9,2),
    "valueCents" INTEGER NOT NULL,
    "fragile" BOOLEAN NOT NULL DEFAULT false,
    "dangerous" BOOLEAN NOT NULL DEFAULT false,
    "perishable" BOOLEAN NOT NULL DEFAULT false,
    "minimumStock" INTEGER NOT NULL DEFAULT 0,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "products_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "warehouses" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "type" "warehouse_type" NOT NULL,
    "addressId" UUID NOT NULL,
    "capacityVolumes" INTEGER,
    "operatingHours" JSONB NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "warehouses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "warehouse_accesses" (
    "id" UUID NOT NULL,
    "warehouseId" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "accessLevel" "warehouse_access_level" NOT NULL,
    "status" "access_status" NOT NULL DEFAULT 'ACTIVE',
    "grantedById" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "warehouse_accesses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "warehouse_coverages" (
    "id" UUID NOT NULL,
    "warehouseId" UUID NOT NULL,
    "startPostalCode" CHAR(8) NOT NULL,
    "endPostalCode" CHAR(8) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "warehouse_coverages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "warehouse_locations" (
    "id" UUID NOT NULL,
    "warehouseId" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "aisle" TEXT NOT NULL,
    "shelf" TEXT NOT NULL,
    "level" TEXT NOT NULL,
    "position" TEXT,
    "blocked" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "warehouse_locations_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "stores_tenantId_idx" ON "stores"("tenantId");

-- CreateIndex
CREATE INDEX "stores_originAddressId_idx" ON "stores"("originAddressId");

-- CreateIndex
CREATE UNIQUE INDEX "stores_tenantId_name_key" ON "stores"("tenantId", "name");

-- CreateIndex
CREATE INDEX "single_use_tokens_userId_idx" ON "single_use_tokens"("userId");

-- CreateIndex
CREATE INDEX "single_use_tokens_expiresAt_idx" ON "single_use_tokens"("expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "api_keys_hash_key" ON "api_keys"("hash");

-- CreateIndex
CREATE INDEX "api_keys_tenantId_idx" ON "api_keys"("tenantId");

-- CreateIndex
CREATE INDEX "addresses_tenantId_idx" ON "addresses"("tenantId");

-- CreateIndex
CREATE INDEX "receivers_tenantId_idx" ON "receivers"("tenantId");

-- CreateIndex
CREATE INDEX "products_tenantId_idx" ON "products"("tenantId");

-- CreateIndex
CREATE INDEX "products_parentProductId_idx" ON "products"("parentProductId");

-- CreateIndex
CREATE UNIQUE INDEX "products_tenantId_sku_key" ON "products"("tenantId", "sku");

-- CreateIndex
CREATE UNIQUE INDEX "warehouses_code_key" ON "warehouses"("code");

-- CreateIndex
CREATE INDEX "warehouses_tenantId_idx" ON "warehouses"("tenantId");

-- CreateIndex
CREATE INDEX "warehouses_addressId_idx" ON "warehouses"("addressId");

-- CreateIndex
CREATE INDEX "warehouse_accesses_tenantId_idx" ON "warehouse_accesses"("tenantId");

-- CreateIndex
CREATE INDEX "warehouse_accesses_grantedById_idx" ON "warehouse_accesses"("grantedById");

-- CreateIndex
CREATE UNIQUE INDEX "warehouse_accesses_warehouseId_tenantId_key" ON "warehouse_accesses"("warehouseId", "tenantId");

-- CreateIndex
CREATE INDEX "warehouse_coverages_warehouseId_idx" ON "warehouse_coverages"("warehouseId");

-- CreateIndex
CREATE INDEX "warehouse_coverages_startPostalCode_endPostalCode_idx" ON "warehouse_coverages"("startPostalCode", "endPostalCode");

-- CreateIndex
CREATE UNIQUE INDEX "warehouse_locations_warehouseId_code_key" ON "warehouse_locations"("warehouseId", "code");

-- CreateIndex
CREATE INDEX "users_tenantId_idx" ON "users"("tenantId");

-- AddForeignKey
ALTER TABLE "stores" ADD CONSTRAINT "stores_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stores" ADD CONSTRAINT "stores_originAddressId_fkey" FOREIGN KEY ("originAddressId") REFERENCES "addresses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "single_use_tokens" ADD CONSTRAINT "single_use_tokens_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "addresses" ADD CONSTRAINT "addresses_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receivers" ADD CONSTRAINT "receivers_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "products" ADD CONSTRAINT "products_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "products" ADD CONSTRAINT "products_parentProductId_fkey" FOREIGN KEY ("parentProductId") REFERENCES "products"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouses" ADD CONSTRAINT "warehouses_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouses" ADD CONSTRAINT "warehouses_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "addresses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouse_accesses" ADD CONSTRAINT "warehouse_accesses_warehouseId_fkey" FOREIGN KEY ("warehouseId") REFERENCES "warehouses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouse_accesses" ADD CONSTRAINT "warehouse_accesses_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouse_accesses" ADD CONSTRAINT "warehouse_accesses_grantedById_fkey" FOREIGN KEY ("grantedById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouse_coverages" ADD CONSTRAINT "warehouse_coverages_warehouseId_fkey" FOREIGN KEY ("warehouseId") REFERENCES "warehouses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouse_locations" ADD CONSTRAINT "warehouse_locations_warehouseId_fkey" FOREIGN KEY ("warehouseId") REFERENCES "warehouses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
