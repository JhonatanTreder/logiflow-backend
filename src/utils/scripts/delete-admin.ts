import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../../generated/prisma/client.js';
import { EnvHandler } from '../env-handler.js';

const envHandler = new EnvHandler();

const prisma = new PrismaClient({
    adapter: new PrismaPg({ connectionString: process.env.DATABASE_URL })
});


async function main(): Promise<void> {
    const email = envHandler.requireEnv('SEED_ADMIN_EMAIL').trim().toLowerCase();
    const admin = await prisma.user.findFirst({
        where: { email: email, role: 'ADMIN' }
    });

    if (!admin) throw new Error('O admin não foi encontrado. Execute o seed para criar o admin antes de tentar excluí-lo.');

    try {
        await prisma.user.delete({
            where: { id: admin.id }
        })
    }
    catch (error) {
        console.error('Erro ao excluir o admin:', error);
    }

    console.log(`O admin com o id ${admin.id} excluído com sucesso.`);
}

main()
  .catch((error) => {
    console.error(error);
    
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());