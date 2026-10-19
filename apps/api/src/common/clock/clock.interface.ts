export interface Clock {
  /**
   * Returns the current date and time as a Date object in UTC.
   */
  now(): Date;

  /**
   * Returns the current epoch timestamp in milliseconds.
   */
  nowEpochMs(): number;

  /**
   * Returns the current ISO-8601 UTC formatted date-time string.
   */
  nowIso(): string;
}

export const CLOCK = Symbol('CLOCK');
