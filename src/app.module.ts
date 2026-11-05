import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module.js';
import { TenantModule } from './modules/tenant/tenant.module.js';

@Module({
  imports: [
    TenantModule,
    PrismaModule,
    ConfigModule.forRoot({
      isGlobal: true,
    })
  ]
})
export class AppModule {}
