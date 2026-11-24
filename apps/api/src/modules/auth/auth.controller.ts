import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { z } from 'zod';
import { AuthMetrics } from './auth-metrics.js';
import { AuthService } from './auth.service.js';

const guestRequestSchema = z.object({
  device_id: z.string().uuid(),
  platform: z.enum(['apple', 'google', 'android', 'ios']),
  app_version: z.string().optional(),
  os_version: z.string().optional(),
});
const refreshRequestSchema = z.object({
  refresh_token: z.string().regex(/^[A-Za-z0-9_-]{43}$/),
});

@Controller('v1/auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly metrics: AuthMetrics,
  ) {}

  @Post('guest')
  @HttpCode(HttpStatus.CREATED)
  createGuest(@Body() body: unknown) {
    const parsed = guestRequestSchema.safeParse(body);
    if (!parsed.success) {
      this.metrics.recordGuestLogin('failure');
      throw parsed.error;
    }
    return this.authService.createGuest(parsed.data);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  refresh(@Body() body: unknown) {
    const { refresh_token } = refreshRequestSchema.parse(body);
    return this.authService.refresh(refresh_token);
  }

  @Post('logout')
  @HttpCode(HttpStatus.NO_CONTENT)
  async logout(@Body() body: unknown): Promise<void> {
    const { refresh_token } = refreshRequestSchema.parse(body);
    await this.authService.logout(refresh_token);
  }
}
