import { Controller, Get, Res, HttpStatus } from '@nestjs/common';
import type { FastifyReply } from 'fastify';
import { HealthService, type LivenessResult } from './health.service.js';

@Controller()
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get('healthz')
  getLiveness(): LivenessResult {
    return this.healthService.checkLiveness();
  }

  @Get('readyz')
  async getReadiness(@Res() res: FastifyReply): Promise<void> {
    const result = await this.healthService.checkReadiness();
    const httpStatus = result.status === 'ok' ? HttpStatus.OK : HttpStatus.SERVICE_UNAVAILABLE;
    res.status(httpStatus).send(result);
  }
}
