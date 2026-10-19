import { Global, Module } from '@nestjs/common';
import { CLOCK } from './clock.interface.js';
import { SystemClock } from './system-clock.js';

@Global()
@Module({
  providers: [
    {
      provide: CLOCK,
      useClass: SystemClock,
    },
    SystemClock,
  ],
  exports: [CLOCK, SystemClock],
})
export class ClockModule {}
