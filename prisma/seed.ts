import 'dotenv/config';
import argon2 from 'argon2';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../src/generated/prisma/client.js';
import { EnvHandler } from '../src/utils/env-handler.js';

const envHandler = new EnvHandler();
const prisma = new PrismaClient({
  adapter: new PrismaPg({ connectionString: process.env.DATABASE_URL }),
});

const PLATFORM_CNPJ = process.env.SEED_PLATFORM_CNPJ ?? '11222333000181';

function assertStrongPassword(password: string): void {

  if (password.length < 10 || !/[A-Za-z]/.test(password) || !/\d/.test(password)) {
    throw new Error('SEED_ADMIN_PASSWORD precisa ter 10+ caracteres, com letras e números');
  }
}

async function main(): Promise<void> {
  const name = envHandler.requireEnv('SEED_ADMIN_NAME');
  const email = envHandler.requireEnv('SEED_ADMIN_EMAIL').trim().toLowerCase();
  const password = envHandler.requireEnv('SEED_ADMIN_PASSWORD');

  assertStrongPassword(password);

  const tenant = await prisma.tenant.upsert({
    where: { cnpj: PLATFORM_CNPJ },
    update: {}, // se já existe, não altera nada
    create: {
      type: 'LOGISTICS_OPERATOR',
      legalName: 'LogiFlow',
      cnpj: PLATFORM_CNPJ,
      contactEmail: email,
      contactPhone: '+5511900000000', // troque pelo telefone real
    },
  });

  const passwordHash = await argon2.hash(password, { type: argon2.argon2id });

  await prisma.user.upsert({
    where: { tenantId_email: { tenantId: tenant.id, email } },
    update: {}, // não sobrescreve a senha de um admin que já existe
    create: { tenantId: tenant.id, name, email, passwordHash, role: 'ADMIN' },
  });
}

main()
  .catch((error) => {
    console.error(error);
    
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());