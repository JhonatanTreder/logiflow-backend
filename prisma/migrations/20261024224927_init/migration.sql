-- CreateEnum
CREATE TYPE "tipo_tenant" AS ENUM ('OPERADOR_LOGISTICO', 'LOJISTA');

-- CreateEnum
CREATE TYPE "status_tenant" AS ENUM ('ATIVO', 'INATIVO', 'BLOQUEADO');

-- CreateEnum
CREATE TYPE "papel_usuario" AS ENUM ('USER', 'ADMIN', 'DONO_EMPRESA', 'OPERADOR_EMPRESA', 'OPERADOR_ARMAZEM', 'DESPACHANTE', 'ROTEIRIZADOR', 'ENTREGADOR', 'CONTADOR', 'SUPORTE', 'CLIENTE');

-- CreateEnum
CREATE TYPE "status_usuario" AS ENUM ('ATIVO', 'INATIVO', 'CONVIDADO', 'BLOQUEADO');

-- CreateTable
CREATE TABLE "tenants" (
    "id" UUID NOT NULL,
    "tipo" "tipo_tenant" NOT NULL,
    "razaoSocial" TEXT NOT NULL,
    "nomeFantasia" TEXT,
    "cnpj" TEXT NOT NULL,
    "status" "status_tenant" NOT NULL DEFAULT 'ATIVO',
    "contatoEmail" TEXT NOT NULL,
    "contatoTelefone" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "tenants_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "tenantId" UUID NOT NULL,
    "nome" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "senhaHash" TEXT NOT NULL,
    "papel" "papel_usuario" NOT NULL DEFAULT 'USER',
    "status" "status_usuario" NOT NULL DEFAULT 'ATIVO',
    "totpAtivo" BOOLEAN NOT NULL DEFAULT false,
    "totpSecretCifrado" TEXT,
    "tentativasFalhas" INTEGER NOT NULL DEFAULT 0,
    "bloqueadoAte" TIMESTAMP(3),
    "ultimoAcessoEm" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "tenants_cnpj_key" ON "tenants"("cnpj");

-- CreateIndex
CREATE UNIQUE INDEX "users_tenantId_email_key" ON "users"("tenantId", "email");

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
