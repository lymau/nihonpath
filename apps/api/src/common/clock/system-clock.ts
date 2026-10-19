import { Injectable } from '@nestjs/common';
import type { Clock } from './clock.interface.js';

@Injectable()
export class SystemClock implements Clock {
  now(): Date {
    return new Date();
  }

  nowEpochMs(): number {
    return Date.now();
  }

  nowIso(): string {
    return this.now().toISOString();
  }
}
