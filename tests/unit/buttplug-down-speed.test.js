/** @vitest-environment node */
import { describe, it, expect } from 'vitest';
import { selectUpSpeedOverride, updateUpSpeedOverrideState } from '../../renderer/js/buttplug-sync.js';

describe('Buttplug upward script-speed modifier', () => {
  it('uses a percentage of the script speed on upward motion', () => {
    const override = { upSpeedPercent: 50 };
    expect(selectUpSpeedOverride(80, 80, 60, override)).toBe(40);
    expect(selectUpSpeedOverride(35, 60, 80, override)).toBe(35);
  });

  it('supports 0% as a real upward override', () => {
    const override = { upSpeedPercent: 0 };
    expect(selectUpSpeedOverride(70, 80, 60, override)).toBe(0);
    expect(selectUpSpeedOverride(70, 60, 80, override)).toBe(70);
  });

  it('keeps script speed during the post-down grace period', () => {
    const override = { upSpeedPercent: 25, scriptGraceUntilMs: 1200 };
    expect(selectUpSpeedOverride(80, 80, 60, override, 1000)).toBe(80);
    expect(selectUpSpeedOverride(80, 80, 60, override, 1200)).toBe(20);
  });

  it('starts the grace timer exactly when downward motion ends', () => {
    const override = { upSpeedPercent: 40, scriptGraceMs: 300, lastDirection: null, scriptGraceUntilMs: 0 };
    updateUpSpeedOverrideState(override, 40, 60, 1000);
    expect(override.lastDirection).toBe('down');
    updateUpSpeedOverrideState(override, 40, 40, 1040);
    expect(override.scriptGraceUntilMs).toBe(1340);
    expect(override.lastDirection).toBe('transition');
    expect(selectUpSpeedOverride(80, 60, 40, override, 1200)).toBe(80);
    expect(selectUpSpeedOverride(80, 60, 40, override, 1340)).toBe(32);
  });

  it('leaves script-derived speed untouched when override is absent', () => {
    expect(selectUpSpeedOverride(42, 80, 60, null)).toBe(42);
  });
});
