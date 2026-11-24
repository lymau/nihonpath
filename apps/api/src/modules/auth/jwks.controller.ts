import { Controller, Get } from '@nestjs/common';
import { AuthTokenService } from './auth-token.service.js';

@Controller()
export class JwksController {
  constructor(private readonly tokenService: AuthTokenService) {}

  @Get('.well-known/jwks.json')
  getJwks() {
    return this.tokenService.jwks();
  }
}
