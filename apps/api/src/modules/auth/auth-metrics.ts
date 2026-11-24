import { Injectable } from '@nestjs/common';
import { metrics } from '@opentelemetry/api';

@Injectable()
export class AuthMetrics {
  private readonly loginCounter = metrics
    .getMeter('nihonpath-api')
    .createCounter('auth_login_total', {
      description: 'Authentication attempts by provider and result',
    });
  private readonly refreshReuseCounter = metrics
    .getMeter('nihonpath-api')
    .createCounter('auth_refresh_reuse_detected_total', {
      description: 'Refresh token reuse events that revoke a token family',
    });

  recordGuestLogin(result: 'success' | 'failure'): void {
    this.loginCounter.add(1, { provider: 'guest', result });
  }

  recordRefreshReuse(): void {
    this.refreshReuseCounter.add(1);
  }
}
