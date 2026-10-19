import { DynamicModule, Global, Module } from '@nestjs/common';
import { AppConfigService, CONFIG_OPTIONS } from './config.service.js';
import { validateEnv } from './env.schema.js';

@Global()
@Module({})
export class ConfigModule {
  static forRoot(customEnv?: Record<string, unknown>): DynamicModule {
    const validatedConfig = validateEnv(customEnv ?? process.env);

    return {
      module: ConfigModule,
      providers: [
        {
          provide: CONFIG_OPTIONS,
          useValue: validatedConfig,
        },
        AppConfigService,
      ],
      exports: [AppConfigService, CONFIG_OPTIONS],
    };
  }
}
