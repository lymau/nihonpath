import type { Clock } from './clock.interface.js';

export class MockClock implements Clock {
  private currentTime: Date;

  constructor(initialTime: Date | string | number = new Date()) {
    this.currentTime = new Date(initialTime);
  }

  setTime(time: Date | string | number): void {
    this.currentTime = new Date(time);
  }

  advanceByMs(ms: number): void {
    this.currentTime = new Date(this.currentTime.getTime() + ms);
  }

  now(): Date {
    return new Date(this.currentTime);
  }

  nowEpochMs(): number {
    return this.currentTime.getTime();
  }

  nowIso(): string {
    return this.currentTime.toISOString();
  }
}
