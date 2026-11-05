import { Module } from "@nestjs/common";
import { TenantRepository } from "./tenant.repository.js";
import { TenantController } from "./tenant.controller.js";
import { PrismaModule } from "../../prisma/prisma.module.js";
import { EnvHandler } from "../../utils/env-handler.js";

@Module({
    imports: [PrismaModule],
    controllers: [TenantController],
    providers: [TenantRepository, EnvHandler],
    exports: [TenantRepository]
})
export class TenantModule {}