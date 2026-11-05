import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service.js';
import { EnvHandler } from '../../utils/env-handler.js';

@Injectable()
export class TenantRepository {
    constructor(
        private readonly prisma: PrismaService,
        private readonly envHandler: EnvHandler
    ) {}

    async findAdminByEmailAsync() {
        const adminEmail = this.envHandler.requireEnv('SEED_ADMIN_EMAIL').trim().toLowerCase();

        return this.prisma.user.findFirst({
            where: { email: adminEmail, role: 'ADMIN'}
        })
    }
}