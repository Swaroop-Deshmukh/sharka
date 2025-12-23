export function calculatePrice(distanceKm: number, category: string) {
  if (category === 'PRESTIGE') return distanceKm * 50;
  if (category === 'STANDARD') return distanceKm * 20;
  return distanceKm * 10;
}
