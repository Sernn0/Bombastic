const DEFAULT_BOMB_DURATION_SECONDS = 86400;

const parsedDurationSeconds = Number(process.env.BOMB_DEFAULT_DURATION_SECONDS);

export const bombDefaultDurationSeconds = Number.isFinite(parsedDurationSeconds)
  && parsedDurationSeconds > 0
  ? parsedDurationSeconds
  : DEFAULT_BOMB_DURATION_SECONDS;

export const bombDefaultDurationMs = bombDefaultDurationSeconds * 1000;
