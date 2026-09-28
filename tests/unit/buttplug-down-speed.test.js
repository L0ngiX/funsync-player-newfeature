/** @vitest-environment node */
import { describe, it, expect } from 'vitest';
import {
  strokesPerSecondToOscillatePercent,
  selectOscillateSpeed,
  selectUpSpeedOverride,
} from '../../renderer/js/buttplug-sync.js';

describe('Buttplug fixed Oscillate up-speed override', () => {
  it('maps 3 strokes/s to 100% and 1.5 strokes/s to 50%', () => {
    expect(strokesPerSecondToOscillatePercent(3)).toBe(100);
    expect(strokesPerSecondToOscillatePercent(1.5)).toBe(50);
    expect(strokesPerSecondToOscillatePercent(0)).toBe(0);
  });

  it('overrides only an upward 0→100 movement', () => {
    const override = { strokesPerSecond: 2, direction: 'up' };
    expect(selectOscillateSpeed(25, 80, 60, override)).toBeCloseTo(66.6667, 4);
    expect(selectOscillateSpeed(25, 60, 80, override)).toBe(25);
    expect(selectOscillateSpeed(25, 60, 60, override)).toBe(25);
  });

  it('allows 0 strokes/s to stop the upward stroke', () => {
    const override = { strokesPerSecond: 0, direction: 'up' };
    expect(selectOscillateSpeed(70, 80, 60, override)).toBe(0);
    expect(selectOscillateSpeed(70, 60, 80, override)).toBe(70);
  });

  it('applies to Vibe/Scalar/Rotate speed paths because they share the derived speed calculation', () => {
    const override = { strokesPerSecond: 1.5, direction: 'up' };
    expect(selectUpSpeedOverride(20, 80, 60, override)).toBeCloseTo(50, 4);
    expect(selectUpSpeedOverride(20, 60, 80, override)).toBe(20);
  });

  it('leaves script-derived speed untouched when override is absent', () => {
    expect(selectOscillateSpeed(42, 60, 80, null)).toBe(42);
  });

  it('allows 0 strokes/s as a real override', () => {
    const override = { strokesPerSecond: 0, direction: 'up' };
    expect(selectUpSpeedOverride(70, 80, 60, override)).toBe(0);
    expect(selectUpSpeedOverride(70, 60, 80, override)).toBe(70);
  });
});
