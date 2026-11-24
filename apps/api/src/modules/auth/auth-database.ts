import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { AppConfigService } from '../../common/config/config.service.js';
import { createDatabasePool, createKysely } from '../../db/client.js';

@Injectable()
export class AuthDatabase implements OnModuleDestroy {
  private readonly pool;
  readonly db;

  constructor(config: AppConfigService) {
    this.pool = createDatabasePool({ connectionString: config.get('DATABASE_URL') });
    this.db = createKysely(this.pool);
  }

  async onModuleDestroy(): Promise<void> {
    await this.db.destroy();
  }
}
