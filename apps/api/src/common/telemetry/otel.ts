import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';

export interface TelemetryConfig {
  serviceName: string;
  otlpEndpoint?: string;
  enabled?: boolean;
}

let sdkInstance: NodeSDK | null = null;

export function initTelemetry(config: TelemetryConfig): NodeSDK | null {
  if (config.enabled === false) {
    return null;
  }

  const traceExporter = config.otlpEndpoint
    ? new OTLPTraceExporter({
        url: config.otlpEndpoint.endsWith('/v1/traces')
          ? config.otlpEndpoint
          : `${config.otlpEndpoint.replace(/\/+$/, '')}/v1/traces`,
      })
    : undefined;

  sdkInstance = new NodeSDK({
    serviceName: config.serviceName,
    traceExporter,
    instrumentations: [
      getNodeAutoInstrumentations({
        '@opentelemetry/instrumentation-fs': {
          enabled: false,
        },
      }),
    ],
  });

  sdkInstance.start();
  return sdkInstance;
}

export async function shutdownTelemetry(): Promise<void> {
  if (sdkInstance) {
    await sdkInstance.shutdown();
    sdkInstance = null;
  }
}
