import type { Generated, ColumnType } from 'kysely';

export type GeneratedDate = Generated<Date>;
export type NullableDate = Date | string | null;
export type Timestamp = Date | string;

export type UserLocale = 'id' | 'en';
export type AuthProvider = 'google' | 'apple' | 'email';
export type ContentItemType =
  'vocab' | 'kanji' | 'grammar' | 'kana' | 'sentence' | 'passage' | 'listening' | 'test';
export type ContentItemStatus = 'draft' | 'published' | 'retired';
export type ContentPackKind = 'core' | 'audio' | 'strokes' | 'passages' | 'tests';
export type SubscriptionPlatform = 'apple' | 'google';

export interface UsersTable {
  id: string;
  email: string | null;
  email_verified_at: NullableDate;
  display_name: string | null;
  locale: Generated<UserLocale>;
  timezone: Generated<string>;
  target_level: number | null;
  is_guest: Generated<boolean>;
  created_at: GeneratedDate;
  deleted_at: NullableDate;
}

export interface AuthIdentitiesTable {
  id: string;
  user_id: string;
  provider: AuthProvider;
  provider_subject: string;
  created_at: GeneratedDate;
}

export interface DevicesTable {
  id: string;
  user_id: string;
  platform: string;
  app_version: string | null;
  os_version: string | null;
  push_token: string | null;
  last_seen_at: NullableDate;
}

export interface RefreshTokensTable {
  id: string;
  user_id: string;
  device_id: string;
  family_id: string;
  token_hash: Buffer;
  expires_at: Timestamp;
  revoked_at: NullableDate;
  replaced_by: string | null;
  created_at: GeneratedDate;
}

export interface ContentItemsTable {
  id: string;
  external_key: string;
  type: ContentItemType;
  jlpt_level: number;
  payload: ColumnType<
    Record<string, unknown>,
    Record<string, unknown> | string,
    Record<string, unknown> | string
  >;
  content_version: number;
  status: Generated<ContentItemStatus>;
  updated_at: GeneratedDate;
}

export interface LessonsTable {
  id: string;
  jlpt_level: number;
  unit_no: number;
  lesson_no: number;
  kind: string;
  title: ColumnType<
    Record<string, unknown>,
    Record<string, unknown> | string,
    Record<string, unknown> | string
  >;
}

export interface LessonItemsTable {
  lesson_id: string;
  item_id: string;
  position: number;
}

export interface ContentPacksTable {
  id: string;
  jlpt_level: number;
  kind: ContentPackKind;
  version: number;
  sha256: string;
  size_bytes: string | number | bigint;
  storage_key: string;
  min_app_version: string;
  is_premium: Generated<boolean>;
  published_at: NullableDate;
}

export interface UserSyncStateTable {
  user_id: string;
  last_seq: Generated<string | number | bigint>;
}

export interface UserCardsTable {
  user_id: string;
  card_id: string;
  item_external_key: string;
  facet: string;
  state: number; // 0 New, 1 Learning, 2 Review, 3 Relearning
  due: Timestamp;
  stability: number;
  difficulty: number;
  elapsed_days: Generated<number>;
  scheduled_days: Generated<number>;
  reps: number;
  lapses: number;
  step: number | null;
  last_review_at: NullableDate;
  suspended: Generated<boolean>;
  buried_until: string | null;
  updated_at: Timestamp;
  user_seq: string | number | bigint;
  origin_device_id: string;
}

export interface ReviewLogsTable {
  user_id: string;
  id: string;
  card_id: string;
  rating: number; // 1 Again, 2 Hard, 3 Good, 4 Easy
  state_before: number;
  reviewed_at: Timestamp;
  duration_ms: number | null;
  scheduled_days: number | null;
  elapsed_days: number | null;
  stability_before: number | null;
  difficulty_before: number | null;
  exercise_type: string | null;
  device_id: string;
  user_seq: string | number | bigint;
  received_at: GeneratedDate;
}

export interface UserSettingsTable {
  user_id: string;
  data: ColumnType<
    Record<string, unknown>,
    Record<string, unknown> | string,
    Record<string, unknown> | string
  >;
  version: number;
  updated_at: Timestamp;
  user_seq: string | number | bigint;
}

export interface LessonProgressTable {
  user_id: string;
  lesson_key: string;
  status: string;
  best_score: number | null;
  completed_at: NullableDate;
  updated_at: Timestamp;
  user_seq: string | number | bigint;
}

export interface TestAttemptsTable {
  user_id: string;
  id: string;
  test_key: string;
  started_at: Timestamp;
  finished_at: NullableDate;
  score: ColumnType<
    Record<string, unknown> | null,
    Record<string, unknown> | string | null,
    Record<string, unknown> | string | null
  >;
  user_seq: string | number | bigint;
}

export interface SubscriptionsTable {
  user_id: string;
  platform: SubscriptionPlatform;
  product_id: string;
  original_txn_id: string;
  status: string;
  expires_at: NullableDate;
  last_verified_at: NullableDate;
}

export interface Database {
  users: UsersTable;
  auth_identities: AuthIdentitiesTable;
  devices: DevicesTable;
  refresh_tokens: RefreshTokensTable;
  content_items: ContentItemsTable;
  lessons: LessonsTable;
  lesson_items: LessonItemsTable;
  content_packs: ContentPacksTable;
  user_sync_state: UserSyncStateTable;
  user_cards: UserCardsTable;
  review_logs: ReviewLogsTable;
  user_settings: UserSettingsTable;
  lesson_progress: LessonProgressTable;
  test_attempts: TestAttemptsTable;
  subscriptions: SubscriptionsTable;
}
