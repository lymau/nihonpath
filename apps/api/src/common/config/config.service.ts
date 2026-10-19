import { Injectable, Inject } from '@nestjs/common';
import type { EnvConfig } from './env.schema.js';

export const CONFIG_OPTIONS = Symbol('CONFIG_OPTIONS');

@Injectable()
export class AppConfigService {
  constructor(
    @Inject(CONFIG_OPTIONS)
    private readonly config: EnvConfig,
  ) {}

  get<K extends keyof EnvConfig>(key: K): EnvConfig[K] {
    return this.config[key];
  }

  get all(): Readonly<EnvConfig> {
    return Object.freeze({ ...this.config });
  }

  get isProduction(): boolean {
    return this.config.NODE_ENV === 'production';
  }

  get isDevelopment(): boolean {
    return this.config.NODE_ENV === 'development';
  }

  get isTest(): boolean {
    return this.config.NODE_ENV === 'test';
  }
}
