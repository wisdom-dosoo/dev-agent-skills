export function total(lines) {
  return lines.reduce((sum, l) => sum + l.qty * l.price, 0);
}
