import { Module } from '@nestjs/common';
import { AuthController } from './auth.controller.js';
import { AuthDatabase } from './auth-database.js';
import { AuthMetrics } from './auth-metrics.js';
import { AuthService } from './auth.service.js';
import { AuthTokenService } from './auth-token.service.js';
import { JwksController } from './jwks.controller.js';

@Module({
  controllers: [AuthController, JwksController],
  providers: [AuthDatabase, AuthMetrics, AuthService, AuthTokenService],
})
export class AuthModule {}
