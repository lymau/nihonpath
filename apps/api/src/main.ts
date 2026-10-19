import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { FastifyAdapter, NestFastifyApplication } from '@nestjs/platform-fastify';
import { AppModule } from './app.module.js';
import { AppConfigService } from './common/config/config.service.js';
import { PinoLoggerService } from './common/logging/pino.logger.js';
import { initTelemetry } from './common/telemetry/otel.js';

export async function createApp(): Promise<NestFastifyApplication> {
  const fastifyAdapter = new FastifyAdapter({
    logger: false,
  });

  const app = await NestFactory.create<NestFastifyApplication>(AppModule, fastifyAdapter, {
    bufferLogs: true,
  });

  const logger = app.get(PinoLoggerService);
  app.useLogger(logger);
  app.enableShutdownHooks();

  const config = app.get(AppConfigService);
  const corsOrigin = config.get('CORS_ORIGIN');
  if (corsOrigin) {
    app.enableCors({
      origin: corsOrigin === '*' ? true : corsOrigin,
      credentials: true,
    });
  }

  return app;
}

export async function bootstrap(): Promise<void> {
  // Initialize OpenTelemetry SDK before starting application listeners (§10.4)
  const serviceName = process.env.SERVICE_NAME || 'nihonpath-api';
  const otlpEndpoint = process.env.OTEL_EXPORTER_OTLP_ENDPOINT;

  initTelemetry({
    serviceName,
    otlpEndpoint,
  });

  const app = await createApp();
  const config = app.get(AppConfigService);
  const logger = app.get(PinoLoggerService);

  const port = config.get('PORT');
  const host = config.get('HOST');

  await app.listen(port, host);
  logger.log(`NihonPath API server successfully listening on http://${host}:${port}`);
}

// Auto-bootstrap if executed directly
if (process.env.NODE_ENV !== 'test' && import.meta.url.endsWith(process.argv[1] ?? '')) {
  bootstrap().catch((err) => {
    console.error('Fatal bootstrapping error:', err);
    process.exit(1);
  });
}
