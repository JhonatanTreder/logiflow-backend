import { Controller, Get } from "@nestjs/common";
import { TenantRepository } from "./tenant.repository.js";

@Controller('tenant')
export class TenantController {
    constructor(
        private readonly tenantRepository: TenantRepository
    ) { }

    @Get('tenant-admin')
    async findTenantAdminAsync() {
        const tenantAdmin = await this.tenantRepository.findAdminByEmailAsync();

        return tenantAdmin?.id;
    }
}