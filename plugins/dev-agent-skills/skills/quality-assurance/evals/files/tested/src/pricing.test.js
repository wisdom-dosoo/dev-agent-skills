import { describe, expect, it } from 'vitest';
import { total } from '../src/pricing.js';

describe('total', () => {
  it('sums line totals', () => {
    expect(total([{ qty: 2, price: 10 }])).toBe(20);
  });
});
